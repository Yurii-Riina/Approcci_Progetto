function saveSession(fig)
    S.version = 1;
    S.savedAt = datetime('now');

    % AppData
    S.ImageHistoryData = getappdata(fig,'ImageHistoryData');
    S.CurrentImagePath = getappdata(fig,'CurrentImagePath');

    % Tabelle
    T2 = findobj(fig,'Tag','HistoryTable');
    if isgraphics(T2) && ~isempty(T2.Data), S.HistoryTable = T2.Data; else, S.HistoryTable = {}; end

    T4 = findobj(fig,'Tag','HistoryTableFull');
    if isgraphics(T4) && ~isempty(T4.Data), S.HistoryTableFull = T4.Data; else, S.HistoryTableFull = {}; end

    % Log dettagliato
    logFull = findobj(fig,'Tag','FullLogBox');
    if isgraphics(logFull) && ~isempty(logFull.Value)
        S.FullLog = logFull.Value;
    else
        S.FullLog = {''};
    end

    % Stato
    stLab = findobj(fig,'Tag','SessionStatusLabel');
    if isgraphics(stLab), S.SessionStatusText = stLab.Text; else, S.SessionStatusText = ''; end

    ts = char(datetime('now','Format','yyyyMMdd_HHmmss'));
    [f,p] = uiputfile('*.mat','Salva sessione',sprintf('sessione_%s.mat',ts));
    if isequal(f,0)
        setSessionStatus(fig,'Salvataggio annullato', true, [], 'warning');
        return; 
    end

    try
        save(fullfile(p,f),'S');
        writeFullLog(fig, sprintf('Sessione salvata: %s', fullfile(p,f)));
        setSessionStatus(fig,'Salvataggio sessione', true, fullfile(p,f), 'ok');
    catch ME
        uialert(fig, ['Errore nel salvataggio: ' ME.message], 'Errore');
        setSessionStatus(fig,'Salvataggio fallito', false, [], 'error');
    end
end
