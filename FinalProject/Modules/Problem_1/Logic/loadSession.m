function loadSession(fig)
    [f,p] = uigetfile('*.mat','Carica sessione');
    if isequal(f,0)
        return; 
    end

    tmp = load(fullfile(p,f));
    if ~isfield(tmp,'S')
        uialert(fig,'File non valido.','Errore');
        setSessionStatus(fig,'Caricamento fallito - File non valido', false, [], 'error');
        return; 
    end
    S = tmp.S;

    % Ripristino AppData
    if isfield(S,'ImageHistoryData')
        setappdata(fig,'ImageHistoryData',S.ImageHistoryData); 
    end
    if isfield(S,'CurrentImagePath')
        setappdata(fig,'CurrentImagePath',S.CurrentImagePath); 
    end

    % Ripristino Tabelle
    T2 = findobj(fig,'Tag','HistoryTable');       if isgraphics(T2), T2.Data = safeCell(S,'HistoryTable'); end
    T4 = findobj(fig,'Tag','HistoryTableFull');   if isgraphics(T4), T4.Data = safeCell(S,'HistoryTableFull'); end

    % Log e Stato
    logFull = findobj(fig,'Tag','FullLogBox');
    if isgraphics(logFull)
        L = safeCell(S,'FullLog');
        if isempty(L), L = {''}; end     % <-- evita errore: uitextarea.Value non può essere {}
        logFull.Value = L;
    end
    
    stLab = findobj(fig,'Tag','SessionStatusLabel');
    if isgraphics(stLab) && isfield(S,'SessionStatusText')
        stLab.Text = S.SessionStatusText;
    end
    setSessionStatus(fig,'Carica sessione',true,[]);

    % Aggiorna anteprima se c'è un'immagine valida
    if isfield(S,'CurrentImagePath') && isfile(S.CurrentImagePath)
        try
            ax = getappdata(fig,'PreviewAxes');
            imshow(imread(S.CurrentImagePath),'Parent',ax);
            infoLbl = findobj(fig,'Tag','ImgInfoLabel');
            if isgraphics(infoLbl)
                [~,nm,ex] = fileparts(S.CurrentImagePath);
                infoLbl.Text = sprintf('%s%s | %s | %.1f KB',nm,ex,upper(strrep(ex,'.','')),getFileSize(S.CurrentImagePath));
            end
        catch 
        end
    end

    writeFullLog(fig, sprintf('Caricata sessione: %s', fullfile(p,f)));
    setSessionStatus(fig,'Caricamento sessione', true, []);
end
