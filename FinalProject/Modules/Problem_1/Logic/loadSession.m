function loadSession(fig)
% LOADSESSION - Carica una sessione salvata (.mat) e ripristina lo stato completo dell'applicazione.
%
% Comportamento:
%   - Richiede all’utente un file .mat da caricare.
%   - Controlla la validità della struttura dati salvata (deve contenere variabile `S`).
%   - Ripristina AppData, tabelle, log, stato sessione e anteprima immagine.
%
% Input:
%   fig (handle UIFigure) - Riferimento alla finestra principale.
%
% Output:
%   Nessuno (la GUI viene aggiornata direttamente).
%
% Robustezza:
%   - Controlla se ogni elemento esiste e se l’handle grafico è valido.
%   - Usa `safeCell` per garantire che i dati delle tabelle siano in formato cell array.
%   - Evita errori quando i log sono vuoti (uitextarea non accetta `{}` vuoto).
%
% Dipendenze:
%   - safeCell
%   - setSessionStatus
%   - writeFullLog
%   - getFileSize

    %% === 1) Selezione del file da caricare ===
    [f, p] = uigetfile('*.mat', 'Carica sessione');
    if isequal(f, 0)
        % Utente ha annullato
        return;
    end

    %% === 2) Caricamento e validazione struttura ===
    try
        tmp = load(fullfile(p, f));
    catch ME
        uialert(fig, sprintf('Errore nel caricamento del file:\n%s', ME.message), 'Errore');
        setSessionStatus(fig, 'Caricamento fallito - Errore I/O', false, [], 'error');
        return;
    end

    if ~isfield(tmp, 'S')
        % File .mat non valido per questa applicazione
        uialert(fig, 'File non valido: manca la struttura dati S.', 'Errore');
        setSessionStatus(fig, 'Caricamento fallito - File non valido', false, [], 'error');
        return;
    end
    S = tmp.S;

    %% === 3) Ripristino AppData ===
    if isfield(S, 'ImageHistoryData')
        setappdata(fig, 'ImageHistoryData', S.ImageHistoryData);
    end
    if isfield(S, 'CurrentImagePath')
        setappdata(fig, 'CurrentImagePath', S.CurrentImagePath);
    end

    %% === 4) Ripristino Tabelle ===
    T2 = findobj(fig, 'Tag', 'HistoryTable');
    if isgraphics(T2)
        T2.Data = safeCell(S, 'HistoryTable');
    end

    T4 = findobj(fig, 'Tag', 'HistoryTableFull');
    if isgraphics(T4)
        T4.Data = safeCell(S, 'HistoryTableFull');
    end

    %% === 5) Ripristino Log dettagliato ===
    logFull = findobj(fig, 'Tag', 'FullLogBox');
    if isgraphics(logFull)
        L = safeCell(S, 'FullLog');
        if isempty(L), L = {''}; end  % uitextarea non accetta {}
        logFull.Value = L;
    end

    %% === 6) Ripristino stato sessione ===
    stLab = findobj(fig, 'Tag', 'SessionStatusLabel');
    if isgraphics(stLab) && isfield(S, 'SessionStatusText')
        stLab.Text = S.SessionStatusText;
    end
    setSessionStatus(fig, 'Carica sessione', true, []);

    %% === 7) Ripristino anteprima immagine (se disponibile) ===
    if isfield(S, 'CurrentImagePath') && isfile(S.CurrentImagePath)
        try
            ax = getappdata(fig, 'PreviewAxes');
            if isgraphics(ax)
                imshow(imread(S.CurrentImagePath), 'Parent', ax);
            end

            infoLbl = findobj(fig, 'Tag', 'ImgInfoLabel');
            if isgraphics(infoLbl)
                [~, nm, ex] = fileparts(S.CurrentImagePath);
                infoLbl.Text = sprintf('%s%s | %s | %.1f KB', ...
                    nm, ex, upper(strrep(ex, '.', '')), ...
                    getFileSize(S.CurrentImagePath));
            end
        catch ME
            % Ignora errori grafici, ma registra comunque nel log
            writeFullLog(fig, sprintf('Errore caricando anteprima: %s', ME.message));
        end
    end

    %% === 8) Aggiorna log e stato finale ===
    writeFullLog(fig, sprintf('Caricata sessione: %s', fullfile(p, f)));
    setSessionStatus(fig, 'Caricamento sessione', true, []);

end