% ==============================================
% Scopo: Classifica l'immagine attualmente selezionata nella GUI
% usando una pipeline esterna (estrazione + classificazione).
% Aggiorna la UI con il risultato e il vettore di feature.
% ==============================================

function classifyCurrentImage(fig)
    currentPath = getappdata(fig, 'CurrentImagePath');
    if isempty(currentPath) || ~isfile(currentPath)
        uialert(fig, 'Caricare prima un''immagine.', 'Errore'); return;
    end

    gesture = classifyGestureFromImage(currentPath);
    [c, pr, feat] = extractFeatures(currentPath);

    % Mostra vettore delle feature
    tbl = findobj(fig, 'Tag', 'FeatureTable');
    tbl.Data = [c; pr; feat];

    % Aggiorna etichetta con il risultato
    lbl = findobj(fig, 'Tag', 'ResultLabel');
    lbl.Text = ['Risultato: ', char(gesture)];

    logMessage(fig, ['Classificazione da immagine: ', char(gesture)]);

    % → aggiorna Tab 4
    [~, n, e] = fileparts(currentPath);
    addHistoryRowTab4(fig, [n e], upper(strrep(e,'.','')), getFileSize(currentPath), '', gesture);
    writeFullLog(fig, sprintf('Classificata immagine "%s" → %s', [n e], char(gesture)));
    setSessionStatus(fig, 'Classificazione immagine', true, []);
end