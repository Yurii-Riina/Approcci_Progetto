function onHistorySelect(fig, event)
    %ONHISTORYSELECT Gestisce il click sulla cronologia (Tab 2).
    %
    % Quando l’utente seleziona una riga della tabella "HistoryTable",
    % questa funzione:
    %   - recupera il nome file dalla riga selezionata,
    %   - risale al path assoluto tra quelli salvati in ImageHistoryData,
    %   - carica l’immagine, aggiorna l’anteprima e la label informativa,
    %   - imposta CurrentImage/CurrentImagePath per usi successivi,
    %   - scrive una riga di log.
    %
    % Robusto a:
    %   - indici fuori range / tabella vuota
    %   - file mancanti o non leggibili (anteprima in try/catch)
    %
    % Dipendenze: getFileSize.m, logMessage.m (facolt. setSessionStatus.m)
    
    %% === 1) Validazioni di base su evento/tabella ===
    if ~isstruct(event) || ~isfield(event, 'Indices') || isempty(event.Indices)
        return; % niente selezione utile
    end
    
    tbl = findobj(fig, 'Tag', 'HistoryTable');
    if isempty(tbl) || ~isgraphics(tbl) || isempty(tbl.Data)
        return;
    end
    
    row = event.Indices(1);
    data = tbl.Data;
    if row < 1 || row > size(data,1) || size(data,2) < 1
        return;
    end
    
    fileShown = data{row, 1};   % es. "Destra.png" (nome+estensione)
    
    %% === 2) Risali al path assoluto dalla history ===
    history = getappdata(fig, 'ImageHistoryData');
    if isempty(history), return; end
    
    % trova nel vettore history l’elemento con lo stesso nome file
    absPath = '';
    for i = 1:numel(history)
        [~, nm, ex] = fileparts(history{i});
        if strcmpi([nm ex], fileShown)
            absPath = history{i};
            break;
        end
    end
    if isempty(absPath), return; end
    
    %% === 3) Carica e mostra anteprima ===
    ax = getappdata(fig, 'PreviewAxes');
    try
        img = imread(absPath);
        if ~isempty(ax) && isgraphics(ax)
            imshow(img, 'Parent', ax);
            axis(ax, 'off');
        end
        setappdata(fig, 'CurrentImage', img);
    catch
        % Non blocco: aggiorno comunque il path per eventuali operazioni
    end
    setappdata(fig, 'CurrentImagePath', absPath);
    
    %% === 4) Aggiorna label informativa (nome | tipo | size) ===
    lbl = findobj(fig, 'Tag', 'ImgInfoLabel');
    if isgraphics(lbl)
        [~, nm, ex] = fileparts(absPath);
        tipo = upper(strrep(ex, '.', ''));   % "PNG", "JPG", ...
        lbl.Text = sprintf('%s%s | %s | %.1f KB', nm, ex, tipo, getFileSize(absPath));
    end
    
    %% === 5) Log (e facoltativo: stato sessione) ===
    logMessage(fig, sprintf('Ricaricata immagine da cronologia: %s', fileShown));
    setSessionStatus(fig, 'Selezione dalla cronologia', true, [], 'ok'); 
end
