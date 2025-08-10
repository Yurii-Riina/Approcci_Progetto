% ==============================================
% Gestisce la selezione di una riga nella cronologia dei file (HistoryTable).
% Ricarica l'immagine selezionata, aggiorna l'anteprima, l'etichetta info e il log.
% ==============================================

function onHistorySelect(fig, event)
    if isempty(event.Indices), return; end
    row = event.Indices(1);
    data = get(findobj(fig, 'Tag', 'HistoryTable'), 'Data');
    filename = data{row, 1};
    history = getappdata(fig, 'ImageHistoryData');

    for i = 1:length(history)
        [~, name, ext] = fileparts(history{i});
        if strcmp([name ext], filename)
            img = imread(history{i});
            ax = getappdata(fig, 'PreviewAxes');
            imshow(img, 'Parent', ax);
            setappdata(fig, 'CurrentImage', img);
            setappdata(fig, 'CurrentImagePath', history{i});

            lbl = findobj(fig, 'Tag', 'ImgInfoLabel');
            lbl.Text = sprintf('%s | %s | %.1f KB', filename, upper(getFileType(filename)), getFileSize(history{i}));

            logMessage(fig, ['Ricaricata immagine da cronologia: ' filename]);
            return;
        end
    end
end