function onDoubleClickRow(jTable, evt, fig)
    % ONDOUBLECLICKROW - Gestisce il doppio click su una riga della tabella
    % "HistoryTableFull" (Tab 4). Prova ad aprire il file associato alla riga.
    %
    % Comportamento
    %   - Se la riga rappresenta un file immagine presente nella cronologia,
    %     ne ricava il percorso completo e tenta di aprirlo con l’app di sistema.
    %   - Se il file non è più disponibile (spostato/cancellato), mostra un
    %     messaggio chiaro con il nome del file.
    %
    % Strategie di lookup del percorso:
    %   1) ImageHistoryData (appdata) — match per nome file (name+ext).
    %   2) Cartelle di provenienza dei file in ImageHistoryData (scan folder).
    %   3) Cartella corrente del processo MATLAB.
    %   4) Qualsiasi cartella nel MATLAB path (via WHICH).
    %
    % Requisiti
    %   - La prima colonna della HistoryTableFull è il “Nome” (name+ext).
    %   - ImageHistoryData contiene percorsi assoluti ai file immagine caricati.
    %
    % Note
    %   - La callback è pensata per essere invocata da un jTable (via findjobj).
    %   - È tollerante a Data come cell array / table / numerico vuoto.
    
    %% ==== 0) Guard-clauses su evento e tabella target ====
    try
        % Solo doppio click (indipendente dal tasto del mouse)
        if isempty(evt) || evt.getClickCount() < 2
            return;
        end
    catch
        % Se evt non è un oggetto Java valido, esci silenziosamente
        return;
    end
    
    tbl = findobj(fig,'Tag','HistoryTableFull');
    if isempty(tbl) || ~isgraphics(tbl), return; end
    
    % Normalizza i dati della tabella in cell array
    D = tbl.Data;
    if isempty(D), return; end
    if istable(D), D = table2cell(D); end
    if isnumeric(D), D = num2cell(D); end
    if ~iscell(D) || isempty(D), return; end
    
    %% ==== 1) Determina la riga selezionata (Java index → MATLAB index) ====
    rowIdx = [];
    try
        rowIdx = jTable.getSelectedRow() + 1;   % Java parte da 0
    catch
        % fallback via proprietà MATLAB (se disponibile)
        if isprop(tbl,'UserData') && isfield(tbl.UserData,'LastSelectedRow')
            rowIdx = tbl.UserData.LastSelectedRow;
        end
    end
    if isempty(rowIdx) || rowIdx <= 0 || rowIdx > size(D,1)
        return;
    end
    
    %% ==== 2) Ricava il nome file dalla prima colonna ====
    fileName = D{rowIdx,1};
    if isstring(fileName), fileName = char(fileName); end
    if ~ischar(fileName) || isempty(fileName)
        % Riga non riferita a file “apri-bile” (es. Feature Vector)
        uialert(fig, 'Voce non associata a un file apribile.', 'Info');
        return;
    end
    
    %% ==== 3) Prova a ricostruire il percorso completo ====
    fullPath = '';
    
    % 3.1) Lookup diretto nella cronologia immagini
    history = getappdata(fig,'ImageHistoryData');
    if ~isempty(history) && iscell(history)
        for i = 1:numel(history)
            [~, n, e] = fileparts(history{i});
            if strcmpi([n e], fileName)
                fullPath = history{i};
                break;
            end
        end
    end
    
    % 3.2) Se serve, prova a cercare nelle cartelle delle immagini note
    if isempty(fullPath) && ~isempty(history)
        folders = unique(cellfun(@fileparts, history, 'UniformOutput', false));
        for k = 1:numel(folders)
            cand = fullfile(folders{k}, fileName);
            if isfile(cand)
                fullPath = cand; break;
            end
        end
    end
    
    % 3.3) Cartella corrente
    if isempty(fullPath)
        cand = fullfile(pwd, fileName);
        if isfile(cand), fullPath = cand; end
    end
    
    % 3.4) MATLAB path (which)
    if isempty(fullPath)
        cand = which(fileName);
        if ~isempty(cand) && isfile(cand), fullPath = cand; end
    end
    
    %% ==== 4) Apri o avvisa ====
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
            try uialert(fig, sprintf('Impossibile aprire il file:\n%s', ME.message), 'Errore'); catch, end
        end
    else
        uialert(fig, sprintf('File non trovato:\n%s', fileName), 'Errore');
    end
end