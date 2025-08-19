function logP2(fig, msg, kind)
% logP2  Scrive una riga di log compatta nel box della Tab Matrice.
% Formato desiderato: [dd-mm-yyyy HH:MM] - Messaggio
% kind (opz.): 'ok' (default) | 'warn' | 'err'

    if nargin < 3 || isempty(kind)
        kind = 'ok';
    end

    try
        box = findobj(fig,'Tag','LogBoxP2');
        if isempty(box) || ~isvalid(box)
            return;
        end

        % --- Sanitize del messaggio in ingresso -------------------------
        % rimuovi prefissi tecnici
        msg = regexprep(msg, '^\s*\[P2\]\s*', '');      % toglie [P2]
        msg = regexprep(msg, '^\s*\[.*?\]\s*', '');     % eventuali altri [TAG]

        % rimuovi dettagli non desiderati a fine riga
        msg = regexprep(msg, '\s*\|\s*checksum=\d+(\.\d+)?', '');   % "| checksum=…"
        msg = regexprep(msg, '\s*AccGlobale=\s*[\d\.]+%','');       % "AccGlobale=…%"
        msg = regexprep(msg, '\s*\([^)]*\)\s*$', '');               % timestamp tra parentesi finali "(...)" 
        msg = strtrim(regexprep(msg, '\s+', ' '));                  % spazi multipli

        % etichetta severità (molto discreta)
        switch lower(kind)
            case 'warn'
                sev = ' (avviso)';
            case 'err'
                sev = ' (errore)';
            otherwise
                sev = '';
        end

        % --- Riga finale -------------------------------------------------
        ts   = char(datetime('now','Format','dd-MM-yyyy HH:mm'));
        line = sprintf('[%s] - %s%s', ts, msg, sev);

        % append in cima (nuovo sopra)
        old = box.Value;
        if ischar(old) || isstring(old), old = cellstr(old); end
        box.Value = [line; old(:)];
        drawnow limitrate;

    catch
        % silenzio: mai rompere la UI per il log :)
    end
end
