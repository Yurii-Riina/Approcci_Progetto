function exportHistoryCSV(fig)
% EXPORTHISTORYCSV - Esporta la cronologia completa (Tab 4) in un file CSV.
%
% Comportamento:
%   - Legge i dati dalla Tabella 'HistoryTableFull' (6 colonne attese).
%   - Normalizza i dati a cell-array, converte i valori in stringhe CSV-safe.
%   - Propone come default la cartella Data/Problem_1/exports (se disponibile via getProjectPaths).
%   - Scrive il file CSV in UTF-8 con header.
%
% Dipendenze consigliate:
%   - getProjectPaths (per proporre un default dir coerente col progetto)
%   - toCsvString (per quoting CSV corretto)
%   - writeFullLog, logMessage, setSessionStatus

    %% 1) Recupera tabella e valida contenuto
    tbl = findobj(fig, 'Tag', 'HistoryTableFull');
    if isempty(tbl) || ~isgraphics(tbl)
        uialert(fig, 'Tabella cronologia (Tab 4) non trovata.', 'Errore');
        setSessionStatus(fig, 'Export CSV fallito - UI non trovata', false, [], 'error');
        return;
    end
    if isempty(tbl.Data)
        uialert(fig, 'Nessun dato in cronologia da esportare.', 'Info');
        setSessionStatus(fig, 'Export CSV - nessun dato', true, [], 'warning');
        return;
    end

    %% 2) Normalizza i dati a cell-array
    data = tbl.Data;
    if istable(data), data = table2cell(data); end
    if ~iscell(data),  data = num2cell(data);   end

    % Header atteso (6 colonne)
    headers = {'Nome','Data','Tipo','Dim (KB)','Tag','Classe'};
    nCols   = numel(headers);

    %% 3) Scegli percorso di salvataggio (default: Data/Problem_1/exports)
    defName = ['stato_sessione_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.csv'];
    defDir  = pwd;  % fallback

    if exist('getProjectPaths','file') == 2
        P = getProjectPaths();
        if isfield(P,'data_problem1_exports') && ~isempty(P.data_problem1_exports)
            defDir = P.data_problem1_exports;
        end
    end
    if ~exist(defDir, 'dir')
        try 
            mkdir(defDir); 
        catch
            defDir = pwd;
        end
    end

    [f, p] = uiputfile('*.csv', 'Esporta cronologia (Tab 4) come CSV', fullfile(defDir, defName));
    if isequal(f, 0)
        setSessionStatus(fig, 'Export CSV annullato', true, [], 'warning');
        return;
    end
    outFile = fullfile(p, f);

    %% 4) Scrittura CSV (UTF-8)
    fid = fopen(outFile, 'w', 'n', 'UTF-8');
    if fid <= 0
        uialert(fig, sprintf('Impossibile creare il file CSV:\n%s', outFile), 'Errore');
        setSessionStatus(fig, 'Export CSV fallito', false, [], 'error');
        return;
    end

    % Header
    fprintf(fid, '%s\n', strjoin(headers, ','));

    % Righe
    nRows = size(data, 1);
    for r = 1:nRows
        row = data(r, :);

        % Pad/trim alla forma 1×6
        if numel(row) < nCols, row(end+1:nCols) = {''}; end
        if numel(row) > nCols, row = row(1:nCols);      end

        % Dimensione KB: forza a numero → stringa
        dimVal = row{4};
        if ischar(dimVal) || isstring(dimVal)
            dimNum = str2double(dimVal);
        elseif isnumeric(dimVal) && isscalar(dimVal)
            dimNum = dimVal;
        else
            dimNum = NaN;
        end
        if isnan(dimNum), dimNum = 0; end

        % Costruisci la riga CSV-safe
        parts = cell(1, nCols);
        parts{1} = toCsvString(row{1}); % Nome
        parts{2} = toCsvString(row{2}); % Data
        parts{3} = toCsvString(row{3}); % Tipo
        parts{4} = toCsvString(sprintf('%.4f', dimNum)); % Dim (KB) formattata
        parts{5} = toCsvString(row{5}); % Tag
        parts{6} = toCsvString(row{6}); % Classe

        fprintf(fid, '%s\n', strjoin(parts, ','));
    end

    fclose(fid);

    %% 5) Feedback utente + stato sessione
    if exist('writeFullLog','file') == 2
        writeFullLog(fig, sprintf('Esportato CSV (Tab 4): %s', outFile));
    end
    if exist('logMessage','file') == 2
        logMessage(fig, sprintf('Export CSV completato: %s', outFile));
    end
    setSessionStatus(fig, 'Export CSV (stato cronologia)', true, outFile, 'ok');
end