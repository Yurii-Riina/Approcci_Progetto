function exportSessionCSV(fig)
%EXPORTSESSIONCSV Esporta la “cronologia completa” (Tab 4) in CSV.
%
%  - Legge i dati dalla tabella 'HistoryTableFull' (Tab 4).
%  - Scrive un file CSV UTF‑8 nella cartella PROGETTO/Data/Problem_1/Exports.
%  - Nome file proposto: sessione_YYYYMMDD_HHMMSS.csv
%  - Aggiorna log dettagliato e stato sessione.
%
% Note d’implementazione
% ----------------------
% 1) Niente path relativi: la cartella di output è risolta risalendo
%    al root del progetto e puntando a Data/Problem_1/Exports.
% 2) Se la directory non esiste viene creata (idempotente).
% 3) Se in futuro useremo una utility condivisa, spostare getProblemDataDir
%    dentro Main/SharedUtils e sostituire la subfunction locale.

    %% === Lettura dati dalla GUI ===
    tbl = findobj(fig,'Tag','HistoryTableFull');
    if isempty(tbl) || ~isgraphics(tbl) || isempty(tbl.Data)
        uialert(fig,'Nessun dato da esportare.','Info');
        return;
    end

    data = tbl.Data;
    if istable(data), data = table2cell(data); end
    if ~iscell(data),  data = num2cell(data);   end

    headers = {'Nome','Data','Tipo','Dim (KB)','Tag','Classe'};

    %% === Risoluzione cartella di output (Data/Problem_1/Exports) ===
    outDir = getProblemDataDir(1,'Exports');   % <-- sempre qui salviamo
    ensureDir(outDir);

    defName = ['sessione_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.csv'];
    outFile = fullfile(outDir, defName);

    %% === Scrittura CSV (UTF-8) ===
    fid = fopen(outFile,'w','n','UTF-8');
    if fid <= 0
        uialert(fig, sprintf('Impossibile creare il file:\n%s', outFile),'Errore');
        return;
    end

    % intestazione
    fprintf(fid, '%s\n', strjoin(headers, ','));

    % righe
    nRows = size(data,1);
    nCols = numel(headers); % attese 6 colonne
    for r = 1:nRows
        row = data(r,:);
        % allinea numero di colonne
        if numel(row) < nCols, row(end+1:nCols) = {''}; end
        if numel(row) > nCols, row = row(1:nCols);      end

        parts = cell(1,nCols);
        for c = 1:nCols
            parts{c} = toCsvString(row{c});  % tua utility esistente
        end
        fprintf(fid, '%s\n', strjoin(parts, ','));
    end

    fclose(fid);

    %% === Feedback UI / Log ===
    writeFullLog(fig, sprintf('Esportato CSV (stato sessione): %s', outFile));
    logMessage(fig, sprintf('Export CSV completato: %s', outFile));
    setSessionStatus(fig, 'Export CSV (stato corrente)', true, outFile, 'ok');
end

%% ======= Utility locali (spostabili in SharedUtils) =====================

function ensureDir(d)
%ENSUREDIR Crea la directory 'd' se non esiste (silenzioso se già presente).
    if ~exist(d,'dir'), mkdir(d); end
end

function outDir = getProblemDataDir(problemIdx, subfolder)
% GETPROBLEMDATADIR Restituisce il path assoluto:
%   <root>/Data/Problem_<idx>/<subfolder>
%
% La funzione risale dal path di QUESTO file (che sta in
% Modules/Problem_1/Logic/...) fino alla radice del progetto.
%
% Esempio:
%   getProblemDataDir(1,'Exports') -> .../Data/Problem_1/Exports

    thisFileDir = fileparts(mfilename('fullpath'));

    % Risali: Logic -> Problem_1 -> Modules -> <root>
    rootDir = fileparts(fileparts(fileparts(thisFileDir)));

    % Se per qualsiasi motivo la risalita non è corretta,
    % prova a cercare 'Modules' più in alto (fallback robusto).
    if ~exist(fullfile(rootDir,'Modules'),'dir')
        tmp = thisFileDir;
        found = false;
        for k = 1:6
            tmp = fileparts(tmp);
            if exist(fullfile(tmp,'Modules'),'dir')
                rootDir = tmp; found = true; break;
            end
        end
        if ~found
            % ultimo fallback: usa la cwd (non ideale, ma evita crash)
            rootDir = pwd;
        end
    end

    outDir = fullfile(rootDir, 'Data', sprintf('Problem_%d', problemIdx), subfolder);
end