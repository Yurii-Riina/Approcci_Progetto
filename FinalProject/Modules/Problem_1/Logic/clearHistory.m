% ==============================================
% Reset completo della cronologia caricata, risultati e feature.
% Svuota tabella, azzera label e anteprima immagine. Aggiorna log.
% ==============================================

function clearHistory(fig)
    % Conferma
    choice = uiconfirm(fig, 'Cancellare cronologia, log e stato della sessione?', ...
        'Conferma', 'Options', {'Sì','No'}, 'DefaultOption', 2, 'CancelOption', 2);

    if ~strcmp(choice,'Sì')
        setSessionStatus(fig,'Pulisci cronologia annullato', true, [], 'warning');
        return; 
    end

    % ==== TAB 2 ====
    imgLbl = findobj(fig,'Tag','ImgInfoLabel');     
        if isgraphics(imgLbl), imgLbl.Text = ''; end

    resLbl = findobj(fig,'Tag','ResultLabel');      
        if isgraphics(resLbl), resLbl.Text = 'Risultato: –'; end

    featTb = findobj(fig,'Tag','FeatureTable');     
    if isgraphics(featTb), featTb.Data = {}; featTb.RowName = {}; end

    logBox = findobj(fig,'Tag','LogBox');           
        if isgraphics(logBox), logBox.Value = {''}; end

    ax     = getappdata(fig,'PreviewAxes');         
        if ~isempty(ax) && isgraphics(ax), cla(ax); axis(ax,'off'); end

    hist2  = findobj(fig,'Tag','HistoryTable');     
        if isgraphics(hist2), hist2.Data = {}; end

    % ==== TAB 3 ====
    t3Tbl = getappdata(fig,'FeatureTableVector');   
        if isgraphics(t3Tbl), t3Tbl.Data = {}; t3Tbl.RowName = {}; end

    t3Lbl = getappdata(fig,'ResultLabelVector');    
        if isgraphics(t3Lbl), t3Lbl.Text = 'Risultato: –'; end

    % ==== TAB 4 ====
    histFull = findobj(fig,'Tag','HistoryTableFull'); 
        if isgraphics(histFull), histFull.Data = {}; end

    fullLog  = findobj(fig,'Tag','FullLogBox');       
        if isgraphics(fullLog), fullLog.Value = {''}; end

    % ==== AppData / Stato ====
    setappdata(fig,'ImageHistoryData', {});
    setappdata(fig,'CurrentImagePath', '');
    setSessionStatus(fig,'Cronologia pulita', false, [], 'warning');

    % ==== Feedback ====
    logMessage(fig,'Feature e risultato azzerati.');
    writeFullLog(fig,'Cronologia e log della sessione cancellati.');
end