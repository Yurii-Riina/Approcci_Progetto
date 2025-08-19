function logP2(fig, msg, kind)
% LOGP2  Appende (in cima) una riga di log nel box della Tab "Matrice".
% =====================================================================================
% PURPOSE
%   Scrive un log sintetico, già depurato da prefissi/tag tecnici, nel controllo
%   con Tag 'LogBoxP2'. Il formato della riga è:
%       [dd-mm-yyyy HH:MM] - Messaggio[ (avviso)|(errore)]
%
% SIGNATURE
%   logP2(fig, msg, kind)
%
% INPUT
%   fig  : handle della uifigure principale (richiesto).
%   msg  : testo del messaggio da loggare (char/string).
%   kind : (opzionale) severità: 'ok' (default) | 'warn' | 'err'
%
% BEHAVIOR
%   - Ricerca il controllo con Tag 'LogBoxP2' e, se presente/valido, inserisce
%     la nuova riga in cima (stile "most recent first").
%   - Esegue una sanificazione minima del messaggio in ingresso:
%       * rimozione di prefissi tra [] (es. "[P2]") e altri [TAG]
%       * rimozione di dettagli a fine riga (checksum, "AccGlobale=…%", timestamp tra ())
%       * normalizzazione spazi
%   - Non genera errori fatali: ogni eccezione viene ignorata (UI non va mai in crash).
%
% NON-GOALS
%   - Nessun trimming della lunghezza del log (politica demandata ad altre componenti).
%   - Nessuna persistenza su file.
% =====================================================================================

    % Guardie minime
    if nargin < 3 || isempty(kind), kind = 'ok'; end
    if isempty(fig) || ~ishandle(fig), return; end

    try
        % --- Trova la textarea di log ------------------------------------------------
        box = findobj(fig,'Tag','LogBoxP2');
        if isempty(box) || ~isvalid(box)
            return;
        end

        % --- Sanitize del messaggio in ingresso --------------------------------------
        % Rimuovi prefissi tecnici come "[P2]" o altri "[TAG]"
        msg = regexprep(msg, '^\s*\[P2\]\s*', '');    % toglie [P2]
        msg = regexprep(msg, '^\s*\[.*?\]\s*', '');   % toglie eventuali altri [QUALSIASI]

        % Rimuovi dettagli non desiderati a fine riga
        msg = regexprep(msg, '\s*\|\s*checksum=\d+(\.\d+)?', '');   % "| checksum=…"
        msg = regexprep(msg, '\s*AccGlobale=\s*[\d\.]+%','');       % "AccGlobale=…%"
        msg = regexprep(msg, '\s*\([^)]*\)\s*$', '');               % "(…)" finale
        msg = strtrim(regexprep(msg, '\s+', ' '));                  % spazi multipli → singolo

        % Etichetta severità (discreta)
        switch lower(kind)
            case 'warn'
                sev = ' (avviso)';
            case 'err'
                sev = ' (errore)';
            otherwise
                sev = '';
        end

        % --- Composizione riga finale ------------------------------------------------
        ts   = char(datetime('now','Format','dd-MM-yyyy HH:mm'));
        line = sprintf('[%s] - %s%s', ts, msg, sev);

        % --- Append in cima -----------------------------------------------------------
        old = box.Value;
        if ischar(old) || isstring(old)
            old = cellstr(old);
        end
        box.Value = [line; old(:)];
        drawnow limitrate;
        
        % Passo il messaggio già sanificato; writeFullLog aggiunge il suo timestamp.
        try
            writeFullLog(fig, msg);     
        catch
        end
    catch
        % Best-effort: silenzioso. Il logging non deve mai rompere la UI.
    end
end
