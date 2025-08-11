function onDoubleClickRow(jTable, evt, fig)
    if evt.getClickCount() == 2
        rowIdx = jTable.getSelectedRow() + 1; % Java index parte da 0
        if rowIdx <= 0, return; end

        % Recupera i dati della riga
        tbl = findobj(fig,'Tag','HistoryTableFull');
        data = tbl.Data;
        if rowIdx > size(data,1), return; end

        fileName = data{rowIdx, 1}; % Prima colonna = Nome file
        if isempty(fileName), return; end

        % Trova percorso completo in ImageHistoryData (se immagine)
        history = getappdata(fig,'ImageHistoryData');
        fullPath = '';

        % Cerca per nome (senza path)
        for i = 1:numel(history)
            [~, name, ext] = fileparts(history{i});
            if strcmpi([name ext], fileName)
                fullPath = history{i};
                break;
            end
        end

        % Se non trovato, prova a vedere se esiste nella cartella corrente
        if isempty(fullPath) && isfile(fileName)
            fullPath = which(fileName);
        end

        % Se trovato, apri; altrimenti avviso
        if ~isempty(fullPath) && isfile(fullPath)
            try
                if ispc
                    winopen(fullPath);
                elseif ismac
                    system(['open "', fullPath, '"']);
                else
                    system(['xdg-open "', fullPath, '"']);
                end
                logMessage(fig, sprintf('Aperto file: %s', fullPath));
            catch ME
                uialert(fig, sprintf('Impossibile aprire il file:\n%s', ME.message), 'Errore');
            end
        else
            uialert(fig, sprintf('File non trovato:\n%s', fileName), 'Errore');
        end
    end
end