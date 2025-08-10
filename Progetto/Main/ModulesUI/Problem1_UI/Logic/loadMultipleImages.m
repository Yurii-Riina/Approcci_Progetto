% ==============================================
% Carica una o più immagini da file, aggiorna la cronologia della GUI,
% e mostra la prima immagine caricata in anteprima. Evita duplicati e aggiorna anche info e log.
% ==============================================

function loadMultipleImages(fig)
    [files, path] = uigetfile({'*.png;*.jpg;*.bmp','Immagini'}, 'Seleziona immagini', 'MultiSelect', 'on');
    if isequal(files, 0), return; end
    if ischar(files), files = {files}; end

    ax = getappdata(fig, 'PreviewAxes');
    lbl = findobj(fig, 'Tag', 'ImgInfoLabel');
    history = getappdata(fig, 'ImageHistoryData');
    table = findobj(fig, 'Tag', 'HistoryTable');
    data = table.Data;

    newHistory = cell(1, length(files));
    newData = cell(length(files), 5);
    nAdded = 0;

    for i = 1:length(files)
        file = files{i};
        imgPath = fullfile(path, file);
        [~, onlyName, ext] = fileparts(file);
        if ~any(strcmp(history, imgPath))
            nAdded = nAdded + 1;
            newHistory{nAdded} = imgPath;
            newData(nAdded,:) = {[onlyName ext], char(datetime('now'), 'dd-MM-yyyy HH:mm'), ...
                                 getFileType(file), sprintf('%.1f', getFileSize(imgPath)), ''};
        end
    end

    newHistory = newHistory(1:nAdded);
    newData = newData(1:nAdded, :);
    history = [history, newHistory];
    data = [data; newData];
    set(table, 'Data', data);
    setappdata(fig, 'ImageHistoryData', history);

    imgPath = newHistory{1};
    setappdata(fig, 'CurrentImage', imread(imgPath));
    setappdata(fig, 'CurrentImagePath', imgPath);

    imshow(imread(imgPath), 'Parent', ax);
    lbl.Text = sprintf('%s | %s | %.1f KB', files{1}, getFileType(files{1}), getFileSize(imgPath));
    logMessage(fig, sprintf('Caricate %d immagini.', nAdded));
end