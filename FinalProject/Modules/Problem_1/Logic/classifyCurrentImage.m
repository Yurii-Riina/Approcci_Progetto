% ==============================================
% Scopo: Classifica l'immagine attualmente selezionata nella GUI
% usando una pipeline esterna (estrazione + classificazione).
% Aggiorna la UI con il risultato e il vettore di feature.
% ==============================================

function classifyCurrentImage(fig)
    currentPath = getappdata(fig, 'CurrentImagePath');
    if isempty(currentPath) || ~isfile(currentPath)
        uialert(fig, 'Caricare prima un''immagine.', 'Errore');
        setSessionStatus(fig, 'Classificazione fallita - Nessuna immagine', false, [], 'error');
        return;
    end
    
    try
        gesture = classifyGestureFromImage(currentPath);
        [c, pr, feat] = extractFeatures(currentPath);
    
        % Mostra vettore delle feature
        tbl = findobj(fig, 'Tag', 'FeatureTable');
        if isgraphics(tbl)
            tbl.Data = [c; pr; feat(:)];
        end
    
        % Aggiorna etichetta con il risultato
        lbl = findobj(fig, 'Tag', 'ResultLabel');
        if isgraphics(lbl)
            lbl.Text = ['Risultato: ', char(gesture)];
        end
    
        logMessage(fig, ['Classificazione da immagine: ', char(gesture)]);
    
        % → aggiorna Tab 4
        [~, n, e] = fileparts(currentPath);
        addHistoryRowSession(fig, [n e], upper(strrep(e,'.','')), getFileSize(currentPath), '', gesture);
        writeFullLog(fig, sprintf('Classificata immagine "%s" → %s', [n e], char(gesture)));
        setSessionStatus(fig, 'Classificazione immagine', true, []);

    catch ME
        uialert(fig, ['Errore classificazione: ' ME.message], 'Errore');
        setSessionStatus(fig, 'Classificazione fallita', false, [], 'error');
    end
end