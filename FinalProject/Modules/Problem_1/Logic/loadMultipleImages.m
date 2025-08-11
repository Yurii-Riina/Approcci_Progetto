function loadMultipleImages(fig)
    %LOADMULTIPLEIMAGES Carica una o più immagini e aggiorna la GUI.
    %
    % Comportamento:
    %   1) Apre un file picker (PNG/JPG/BMP, multiselezione).
    %   2) Aggiunge alla cronologia (Tab 2) solo i file **non** già presenti
    %      (confronto per path assoluto).
    %   3) Mostra l’anteprima della **prima** nuova immagine caricata
    %      e aggiorna la label informativa.
    %   4) Aggiorna Tab 4 (storico completo) aggiungendo una riga per ciascun
    %      file caricato, con tag "loaded" e classe vuota.
    %   5) Scrive messaggi su log (Tab 2/Tab 4) e aggiorna lo stato sessione.
    %
    % Dipendenze:
    %   - getFileType.m, getFileSize.m
    %   - addHistoryRowSession.m, writeFullLog.m, logMessage.m
    %   - setSessionStatus.m
    %
    % Note:
    %   - Nessun salvataggio su disco; non usa path relativi.
    %   - Resiliente ad anteprime fallite: eventuali errori di imread non
    %     bloccano l’inserimento in cronologia.
    
    %% === 1) Dialog di selezione ===
    [files, path] = uigetfile( ...
        {'*.png;*.jpg;*.jpeg;*.bmp','Immagini (PNG/JPG/BMP)'}, ...
        'Seleziona immagini', 'MultiSelect', 'on');
    
    if isequal(files, 0)
        setSessionStatus(fig, 'Caricamento annullato', true, [], 'warning');
        return;
    end
    
    % Normalizza in cell array
    if ischar(files)
        files = {files};
    end
    
    %% === 2) Riferimenti GUI + modello ===
    ax  = getappdata(fig, 'PreviewAxes');
    lbl = findobj(fig, 'Tag', 'ImgInfoLabel');
    
    history = getappdata(fig, 'ImageHistoryData');
    if isempty(history), history = {}; end
    
    tbl = findobj(fig, 'Tag', 'HistoryTable');
    if isempty(tbl) || ~isgraphics(tbl)
        uialert(fig, 'Tabella cronologia (Tab 2) non trovata.', 'Errore');
        setSessionStatus(fig, 'Caricamento fallito - UI non trovata', false, [], 'error');
        return;
    end
    
    if isempty(tbl.Data)
        data = {};
    else
        data = tbl.Data;
    end
    
    %% === 3) Filtra duplicati e prepara righe da aggiungere ===
    nSel       = numel(files);
    newHistory = cell(1, nSel);
    newData    = cell(nSel, 5);
    nAdded     = 0;
    
    for i = 1:nSel
        file = files{i};
        imgPath = fullfile(path, file);             % path assoluto
        [~, onlyName, ext] = fileparts(file);
    
        % Evita duplicati: confronto su path assoluto
        if ~any(strcmp(history, imgPath))
            nAdded = nAdded + 1;
            newHistory{nAdded} = imgPath;
    
            % Riga per Tab 2 (Tabella "HistoryTable")
            newData(nAdded, :) = { ...
                [onlyName ext], ...                                       % Nome
                char(datetime('now','Format','dd-MM-yyyy HH:mm')), ...    % Data
                getFileType(file), ...                                    % Tipo (PNG/JPG/…)
                sprintf('%.1f', getFileSize(imgPath)), ...                % Dim (KB)
                '' ...                                                    % Tag (vuoto in Tab 2)
            };
        end
    end
    
    if nAdded == 0
        % Nulla di nuovo
        logMessage(fig, 'Nessuna nuova immagine (duplicati).');
        writeFullLog(fig, 'Nessuna nuova immagine (duplicati).');
        setSessionStatus(fig, 'Nessuna nuova immagine (duplicati)', true, [], 'warning');
        return;
    end
    
    % Troncamento alle righe effettive
    newHistory = newHistory(1:nAdded);
    newData    = newData(1:nAdded, :);
    
    %% === 4) Aggiorna modello (history) e Tab 2 (tabella parziale) ===
    history = [history, newHistory];
    data    = [data; newData];
    set(tbl, 'Data', data);
    setappdata(fig, 'ImageHistoryData', history);
    
    %% === 5) Anteprima e label sulla PRIMA nuova immagine ===
    firstPath = newHistory{1};
    setappdata(fig, 'CurrentImagePath', firstPath);  % importante per classificazioni successive
    
    try
        img = imread(firstPath);
        setappdata(fig, 'CurrentImage', img);
        if ~isempty(ax) && isgraphics(ax)
            imshow(img, 'Parent', ax);
            axis(ax, 'off');
        end
    catch
        % Non bloccare il flusso se l’anteprima fallisce (file corrotto, ecc.)
    end
    
    if isgraphics(lbl)
        [~, nm, ex] = fileparts(firstPath);
        lbl.Text = sprintf('%s%s | %s | %.1f KB', nm, ex, ...
            upper(strrep(ex, '.', '')), getFileSize(firstPath));
    end
    
    %% === 6) Aggiorna Tab 4 (storico completo) per ogni file caricato ===
    for k = 1:nAdded
        [~, nn, ee] = fileparts(newHistory{k});
        addHistoryRowSession( ...
            fig, [nn ee], upper(strrep(ee,'.','')), getFileSize(newHistory{k}), ...
            'loaded', '' );   % Tag "loaded", Classe vuota
    end
    
    %% === 7) Log e stato sessione ===
    logMessage(fig, sprintf('Caricate %d immagini.', nAdded));
    writeFullLog(fig, sprintf('Caricate %d immagini.', nAdded));
    setSessionStatus(fig, sprintf('Immagini caricate (%d)', nAdded), true, [], 'ok');

end
