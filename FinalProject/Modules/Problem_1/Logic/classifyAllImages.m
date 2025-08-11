% ==============================================
% Classifica in batch tutte le immagini caricate
% e salva i risultati in un CSV vicino alla logica.
% ==============================================
function classifyAllImages(fig)

    % --- Recupero cronologia immagini
    history = getappdata(fig, 'ImageHistoryData');
    if isempty(history)
        uialert(fig, 'Nessuna immagine caricata.', 'Errore');
        setSessionStatus(fig, 'Batch interrotto - Nessuna immagine', false, [], 'warning');
        return;
    end
    n = numel(history);

    % --- Decidi DOVE salvare il CSV ---
    % 1) stessa cartella del .mat di test, se presente
    fvMat = which('feature_vector_test.mat');

    % 2) altrimenti nella cartella della logica (extractFeatures.m)
    if isempty(fvMat)
        logicFile = which('extractFeatures');
        if ~isempty(logicFile)
            outDir = fileparts(logicFile);
        else
            % 3) fallback: cartella corrente + avviso nel log
            outDir = pwd;
            logMessage(fig, 'ATTENZIONE: non trovo feature_vector_test.mat né extractFeatures.m; salvo il CSV nella cartella corrente.');
        end
    else
        outDir = fileparts(fvMat);
    end

    if ~exist(outDir, 'dir'), mkdir(outDir); end

    % --- Prepara file CSV ---
    timestamp = char(datetime('now','Format','yyyyMMdd_HHmmss'));
    outFile   = fullfile(outDir, ['classificazioni_' timestamp '.csv']);

    fid = fopen(outFile, 'w', 'n', 'UTF-8');
    if fid <= 0
        uialert(fig, sprintf('Impossibile creare il file CSV:\n%s', outFile), 'Errore');
        return;
    end

    % intestazione CSV
    fprintf(fid, 'Nome file,Compattezza,ProtrusionRatio,AltreFeature,Esito,Data\n');

    % --- Classifica tutte le immagini ---
    try
        for i = 1:n
            imgPath = history{i};
            [~, name, ext] = fileparts(imgPath);
            filename = [name ext];

            try
                % Estrazione feature + classificazione
                [c, pr, feat] = extractFeatures(imgPath);       % restituisce numerici
                gesture       = classifyGestureFromImage(imgPath); % string/char

                % → TAB 4: aggiungi riga cronologia e log dettagliato
                addHistoryRowSession(fig, filename, upper(strrep(ext,'.','')), getFileSize(imgPath), 'batch', gesture);
                writeFullLog(fig, sprintf('Batch: "%s" → %s', filename, char(gesture)));

                % Scrivi riga CSV
                fprintf(fid, '"%s",%.6f,%.6f,%.6f,"%s","%s"\n', ...
                    filename, c, pr, feat, string(gesture), ...
                    char(datetime('now'), 'dd-MM-yyyy HH:mm'));

                % Log in GUI
                logMessage(fig, sprintf('%s \x2192 %s', filename, string(gesture)));

            catch MEi
                % Non bloccare l’intero batch per un errore su un file
                logMessage(fig, sprintf('ERRORE con "%s": %s', filename, MEi.message));
            end
        end

    catch ME
        fclose(fid);
        uialert(fig, ['Errore durante l''export CSV: ' ME.message], 'Errore');
        setSessionStatus(fig, 'Batch interrotto - Nessuna immagine', false, [], 'warning');
        return;
    end

    fclose(fid);

    % → TAB 4: stato sessione e log finale
    setSessionStatus(fig, 'Export CSV (batch)', true, outFile);
    writeFullLog(fig, sprintf('Classificazione batch completata. CSV: %s', outFile));

    logMessage(fig, sprintf('Classificazione batch completata. File CSV: %s', outFile));
end
