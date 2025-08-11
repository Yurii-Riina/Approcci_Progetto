function saveSession(fig)
% SAVESESSION - Serializza lo stato corrente del Modulo 1 in un file .mat.
%
% Scopo
%   Salvare su disco: cronologia immagini, selezione corrente, tabelle delle
%   schede, log dettagliato e stato della sessione (Tab 4). Il salvataggio
%   propone come cartella predefinita "Data/Problem_1/sessions" del progetto.
%
% Comportamento
%   1) Raccoglie in una struct S tutti i dati necessari (version, timestamp,
%      appdata, tabelle, log e testo “stato sessione”).
%   2) Normalizza i dati tabellari in cell array (no table/dataset) per massima
%      compatibilità.
%   3) Chiede il percorso di salvataggio (predef. nella cartella “sessions”).
%   4) Scrive il file .mat e aggiorna stato/log nell’UI.
%
% Dipendenze “soft”
%   - setSessionStatus(fig, ...)
%   - writeFullLog(fig, ...)
%   - (opzionale) getProjectPaths('problem1','sessions'): se presente, usa tale
%     funzione per ottenere la cartella di default del salvataggio.
%
% Note
%   - Il salvataggio è atomico lato utente (se fallisce, mostra un uialert).
%   - I campi vuoti vengono salvati come {} / '' per evitare tipi incoerenti.

%% ===== 1) Metadati sessione =====
S = struct();
S.version = 1;
S.module  = 'Problem_1_StaticGestures';
S.savedAt = datetime('now');

%% ===== 2) AppData principali =====
S.ImageHistoryData = getOr(fig, 'ImageHistoryData', {});
S.CurrentImagePath = getOr(fig, 'CurrentImagePath', '');

%% ===== 3) Contenuti Tab 2/4 (tabelle) =====
% Tab 2: HistoryTable (cronologia parziale)
T2 = findobj(fig,'Tag','HistoryTable');
S.HistoryTable = normalizeTableData(T2);

% Tab 4: HistoryTableFull (cronologia completa)
T4 = findobj(fig,'Tag','HistoryTableFull');
S.HistoryTableFull = normalizeTableData(T4);

%% ===== 4) Log dettagliato + Stato sessione (Tab 4) =====
logFull = findobj(fig,'Tag','FullLogBox');
if isgraphics(logFull) && ~isempty(logFull.Value)
    S.FullLog = logFull.Value;
else
    S.FullLog = {};
end

stLab = findobj(fig,'Tag','SessionStatusLabel');
if isgraphics(stLab)
    S.SessionStatusText = stLab.Text;
else
    S.SessionStatusText = '';
end

%% ===== 5) Percorso di default: Data/Problem_1/sessions =====
sessionsDir = '';
try
    % Se esiste un helper centralizzato, usalo
    if exist('getProjectPaths','file') == 2
        sessionsDir = getProjectPaths('problem1','sessions'); 
        sessionsDir = getProjectPaths('problem1','sessions'); % doppia per workspace
    end
catch
    % Ignora errori del resolver
end

% Se non valorizzato o non esiste, costruisci fallback relativo al progetto
if isempty(sessionsDir) || ~isfolder(sessionsDir)
    % Individua root progetto dalla posizione di questo file
    here = fileparts(mfilename('fullpath'));
    % sali di due livelli: Problem_1/Logic -> Problem_1 -> Modules
    projRoot = here;
    for k = 1:3, projRoot = fileparts(projRoot); end
    % Data/Problem_1/sessions
    sessionsDir = fullfile(projRoot, 'Data', 'Problem_1', 'sessions');
end
if ~exist(sessionsDir,'dir'), mkdir(sessionsDir); end

% Nome file predefinito
ts      = char(datetime('now','Format','yyyyMMdd_HHmmss'));
defName = sprintf('sessione_%s.mat', ts);

%% ===== 6) Dialog di salvataggio e scrittura su disco =====
try
    [f,p] = uiputfile('*.mat', 'Salva sessione', fullfile(sessionsDir, defName));
    if isequal(f,0)
        setSessionStatus(fig,'Salvataggio annullato', true, [], 'warning');
        return;
    end

    outFile = fullfile(p,f);
    save(outFile, 'S');  % salvataggio “semplice”: compatibile e veloce

    % Feedback UI
    writeFullLog(fig, sprintf('Sessione salvata: %s', outFile));
    setSessionStatus(fig,'Salvataggio sessione', true, outFile, 'ok');

catch ME
    % Error handling centralizzato
    try uialert(fig, ['Errore nel salvataggio: ' ME.message], 'Errore'); catch, end
    setSessionStatus(fig,'Salvataggio fallito', false, [], 'error');
end

end

%% =======================================================================
%% ===============        FUNZIONI DI SUPPORTO        ====================
%% =======================================================================

function val = getOr(fig, key, defaultVal)
%GETOR  Ritorna appdata 'key' se esiste, altrimenti defaultVal.
    if isappdata(fig, key)
        val = getappdata(fig, key);
        if isempty(val), val = defaultVal; end
    else
        val = defaultVal;
    end
end

function C = normalizeTableData(tbl)
%NORMALIZETABLEDATA  Estrae i dati da un uitable e li normalizza in cell array.
%   - Se l'oggetto non esiste o non ha Data → {}
%   - Se Data è table → table2cell
%   - Se Data è numerico → num2cell
%   - Se Data è già cell → lo ritorna invariato
    C = {};
    if isempty(tbl) || ~isgraphics(tbl)
        return;
    end
    D = tbl.Data;
    if isempty(D)
        C = {};
        return;
    end
    if istable(D)
        C = table2cell(D);
    elseif isnumeric(D)
        C = num2cell(D);
    elseif iscell(D)
        C = D;
    else
        % fallback prudente
        try
            C = cellstr(string(D));
            C = reshape(C, numel(C), 1);
        catch
            C = {};
        end
    end
end