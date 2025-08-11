function classifyAllImages(fig)
% CLASSIFYALLIMAGES - Classifica in batch tutte le immagini caricate e salva un CSV.
%
% Flusso:
%   1) Legge la lista immagini da 'ImageHistoryData'
%   2) Per ciascuna immagine: estrae le feature e classifica
%   3) Scrive una riga nel CSV + aggiorna Tab 4 (cronologia + log dettagliato)
%   4) Aggiorna lo stato sessione a fine operazione
%
% Note:
%   - Il CSV include: Nome file, Compattezza, ProtrusionRatio, AltreFeature, Esito, Data
%   - Il campo "AltreFeature" è convertito con toCsvString: regge scalari/vettori.
%   - La directory di export è risolta da resolveExportDir (vedi funzione locale).
%     Attualmente replica il comportamento originario; puoi instradarla a Data/Problem_1/exports.

    %% 1) Recupero cronologia immagini
    history = getappdata(fig, 'ImageHistoryData');
    if isempty(history)
        uialert(fig, 'Nessuna immagine caricata.', 'Errore');
        setSessionStatus(fig, 'Batch interrotto - Nessuna immagine', false, [], 'warning');
        return;
    end
    n = numel(history);

    %% 2) Risolvi cartella di export
    outDir = resolveExportDir(fig);
    if ~exist(outDir, 'dir')
        try
            mkdir(outDir);
        catch ME
            uialert(fig, ['Impossibile creare la cartella di export: ' ME.message], 'Errore');
            setSessionStatus(fig, 'Export CSV fallito (mkdir)', false, [], 'error');
            return;
        end
    end

    %% 3) Prepara file CSV
    timestamp = char(datetime('now','Format','yyyyMMdd_HHmmss'));
    outFile   = fullfile(outDir, ['classificazioni_' timestamp '.csv']);

    fid = fopen(outFile, 'w', 'n', 'UTF-8');
    if fid <= 0
        uialert(fig, sprintf('Impossibile creare il file CSV:\n%s', outFile), 'Errore');
        setSessionStatus(fig, 'Export CSV fallito (apertura file)', false, outFile, 'error');
        return;
    end

    % intestazione
    fprintf(fid, 'Nome file,Compattezza,ProtrusionRatio,AltreFeature,Esito,Data\n');

    %% 4) Classifica tutte le immagini (robusto a errori per singolo file)
    numOk = 0;
    numErr = 0;

    try
        for i = 1:n
            imgPath = history{i};
            [~, name, ext] = fileparts(imgPath);
            filename = [name ext];

            try
                % Estrazione feature + classificazione
                [c, pr, feat] = extractFeatures(imgPath);           % numerici
                gesture       = classifyGestureFromImage(imgPath);   % string/char

                % AltreFeature → stringa CSV-safe (gestisce scalare/vettore)
                featStr = toCsvString(feat);

                % Scrivi riga CSV
                nowStr = char(datetime('now','Format','dd-MM-yyyy HH:mm'));
                fprintf(fid, '"%s",%.6f,%.6f,%s,"%s","%s"\n', ...
                    filename, c, pr, featStr, toCsvString(string(gesture)), nowStr);

                % → TAB 4: aggiungi riga cronologia e log dettagliato
                addHistoryRowSession(fig, filename, upper(strrep(ext,'.','')), ...
                                     getFileSize(imgPath), 'batch', gesture);
                writeFullLog(fig, sprintf('Batch: "%s" → %s', filename, char(gesture)));

                % Log breve in GUI
                logMessage(fig, sprintf('%s \x2192 %s', filename, string(gesture)));

                numOk = numOk + 1;

            catch MEi
                % Non bloccare l’intero batch per un errore su un file
                numErr = numErr + 1;
                logMessage(fig, sprintf('ERRORE con "%s": %s', filename, MEi.message));
                writeFullLog(fig, sprintf('ERRORE batch con "%s": %s', filename, MEi.message));
            end
        end

    catch ME
        % Eccezione "esterna" al loop: segnala e chiudi file
        writeFullLog(fig, ['Errore durante il batch/export CSV: ' ME.message]);
        fclose(fid);
        uialert(fig, ['Errore durante l''export CSV: ' ME.message], 'Errore');
        setSessionStatus(fig, 'Export CSV fallito (batch)', false, outFile, 'error');
        return;
    end

    % chiusura file garantita
    fclose(fid);

    %% 5) Stato finale + log
    if numOk > 0 && numErr == 0
        setSessionStatus(fig, 'Export CSV (batch)', true, outFile, 'ok');
        writeFullLog(fig, sprintf('Classificazione batch completata (%d/%d). CSV: %s', numOk, n, outFile));
        logMessage(fig, sprintf('Classificazione batch completata. File CSV: %s', outFile));
    elseif numOk > 0 && numErr > 0
        setSessionStatus(fig, sprintf('Batch completato con errori (%d ok, %d err)', numOk, numErr), true, outFile, 'warning');
        writeFullLog(fig, sprintf('Batch completato con errori (%d/%d). CSV: %s', numOk, n, outFile));
        logMessage(fig, sprintf('Batch completato con errori. File CSV: %s', outFile));
    else
        % niente andato a buon fine
        setSessionStatus(fig, 'Batch fallito (nessuna immagine classificata)', false, outFile, 'error');
        writeFullLog(fig, 'Batch fallito: nessuna immagine classificata');
        logMessage(fig, 'Batch fallito: nessuna immagine classificata');
    end
end

%% ==== Funzioni locali di supporto =======================================

function outDir = resolveExportDir(fig)
% RESOLVEEXPORTDIR - Determina la cartella dove salvare il CSV.
% Mantiene la logica “storica”:
%   1) Se esiste feature_vector_test.mat → usa sua cartella
%   2) altrimenti, cartella di extractFeatures.m
%   3) in fallback, pwd (con avviso nel Full Log)
%
% NB: se in futuro vuoi usare Data/Problem_1/exports, sostituisci qui:
%    paths = getProjectPaths(); outDir = paths.p1_exports;

    fvMat = which('feature_vector_test.mat');
    if ~isempty(fvMat)
        outDir = fileparts(fvMat);
        return;
    end

    logicFile = which('extractFeatures');
    if ~isempty(logicFile)
        outDir = fileparts(logicFile);
        return;
    end

    outDir = pwd;
    % avviso non bloccante
    if exist('writeFullLog','file') == 2
        writeFullLog(fig, 'ATTENZIONE: export CSV in cartella corrente (fallback).');
    end
end