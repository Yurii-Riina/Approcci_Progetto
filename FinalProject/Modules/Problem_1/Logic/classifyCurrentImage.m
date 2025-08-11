function classifyCurrentImage(fig)
% CLASSIFYCURRENTIMAGE - Classifica l'immagine attualmente selezionata nella GUI.
%
% Scopo:
%   - Utilizza la pipeline esterna (estrazione feature + classificazione)
%     per ottenere il risultato di riconoscimento del gesto.
%   - Aggiorna la GUI con:
%       1) Vettore di feature (Tab 2)
%       2) Etichetta con il risultato classificato
%       3) Cronologia della sessione (Tab 4)
%       4) Log sintetico e dettagliato
%
% Input:
%   fig - handle della figura principale della GUI
%
% Flusso:
%   1) Recupera il path dell'immagine corrente da AppData
%   2) Controlla che il file esista
%   3) Chiama le funzioni esterne:
%        - classifyGestureFromImage(filePath) → classe predetta
%        - extractFeatures(filePath) → compattezza, protrusion ratio, feature extra
%   4) Aggiorna UI (tabelle, etichette, log)
%   5) Gestisce eventuali errori con messaggi all’utente
%
% Note:
%   - Se non è stata caricata alcuna immagine, viene mostrato un avviso e interrotto il processo.
%   - Tutte le operazioni di UI sono protette da controlli di validità grafica (.isgraphics).
%
% Autore: [Tuo Nome]
% Data:   [Data]
% -------------------------------------------------------------------------

%% 1) Recupera immagine corrente
    currentPath = getappdata(fig, 'CurrentImagePath');

    % Nessuna immagine → avviso e stop
    if isempty(currentPath) || ~isfile(currentPath)
        uialert(fig, 'Caricare prima un''immagine.', 'Errore');
        setSessionStatus(fig, ...
            'Classificazione fallita - Nessuna immagine', ...
            false, [], 'error');
        return;
    end

%% 2) Elaborazione: classificazione e feature
    try
        % Classe predetta dal classificatore principale
        gesture = classifyGestureFromImage(currentPath);

        % Feature estratte (es. compattezza, protrusion ratio, vettore esteso)
        [c, pr, feat] = extractFeatures(currentPath);

    %% 3) Aggiorna Tabella delle feature (Tab 2)
        tbl = findobj(fig, 'Tag', 'FeatureTable');
        if isgraphics(tbl)
            % Metti compattezza (c), protrusion ratio (pr) e il resto delle feature in colonna
            tbl.Data = [c; pr; feat(:)];
        end

    %% 4) Aggiorna Etichetta risultato (Tab 2)
        lbl = findobj(fig, 'Tag', 'ResultLabel');
        if isgraphics(lbl)
            lbl.Text = ['Risultato: ', char(gesture)];
        end

    %% 5) Aggiorna log sintetico (Tab 2)
        logMessage(fig, ['Classificazione da immagine: ', char(gesture)]);

    %% 6) Aggiorna Cronologia completa (Tab 4)
        [~, n, e] = fileparts(currentPath);
        addHistoryRowSession(fig, ...
            [n e], ...
            upper(strrep(e, '.', '')), ...
            getFileSize(currentPath), ...
            '', gesture);

        % Log dettagliato
        writeFullLog(fig, sprintf( ...
            'Classificata immagine "%s" → %s', [n e], char(gesture)));

    %% 7) Stato sessione: operazione riuscita
        setSessionStatus(fig, ...
            'Classificazione immagine', ...
            true, [], 'ok');

    catch ME
    %% 8) Gestione errori
        uialert(fig, ['Errore classificazione: ' ME.message], 'Errore');
        setSessionStatus(fig, ...
            'Classificazione fallita', ...
            false, [], 'error');
    end
end