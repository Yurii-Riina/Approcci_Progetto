function pushEffect(btn, actionFcn, src, evt)
% PUSHEFFECT  Applica un breve effetto visivo "pressed" a un pulsante e poi
%             esegue la callback logica reale, con gestione errori.
%
% Sintassi
%   pushEffect(btn, actionFcn, src, evt)
%
% Input
%   btn       : handle del pulsante (uibutton) a cui applicare l'effetto.
%   actionFcn : function handle della callback "vera" da eseguire dopo l'effetto.
%               Deve accettare la firma (src, evt).
%   src, evt  : argomenti da inoltrare ad actionFcn (coerenti con la firma di MATLAB UI).
%
% Descrizione
%   Cambia temporaneamente il colore di sfondo del pulsante per ~80 ms, per dare
%   un feedback tattile/visivo all'utente. Ripristina *sempre* il colore originale
%   e poi invoca la callback logica, proteggendola con try/catch per evitare che
%   errori rompano il flusso dell'app. In caso di eccezione, emette un warning.
%
% Note
%   - L’effetto è sincrono e molto breve, pensato per UI semplici.
%   - Se btn non è (più) valido, la funzione salta l’effetto ma prova comunque
%     a chiamare actionFcn.

    % --- Validazioni leggere ---
    if ~ishandle(btn) || ~isprop(btn,'BackgroundColor')
        % Pulsante non valido: esegui direttamente la callback logica.
        safeInvoke(actionFcn, src, evt);
        return;
    end

    % --- Effetto "pressed" con ripristino garantito ---
    origColor      = btn.BackgroundColor;
    highlightColor = [0.80 0.87 1.00];  % azzurrino tenue

    try
        btn.BackgroundColor = highlightColor;
        drawnow;
        pause(0.08);  % durata breve dell’effetto
    catch
        % Se qualcosa va storto nell’UI, prosegui comunque
    end

    % Ripristino colore (in finally‑style)
    try
        if ishandle(btn)
            btn.BackgroundColor = origColor;
            drawnow;
        end
    catch
        % Ignora eventuali errori grafici
    end

    % --- Esecuzione della callback logica reale ---
    safeInvoke(actionFcn, src, evt);
end

% ========== Helper interno ==========

function safeInvoke(fcn, src, evt)
% Chiama actionFcn(src,evt) con gestione degli errori.
    try
        fcn(src, evt);
    catch ME
        warning('%s - Errore nella callback del bottone: %s', ME.identifier, ME.message);
    end
end
