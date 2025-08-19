function P = resolvePathsP2()
% RESOLVEPATHSP2  Utility percorsi per il Modulo 2 (Confusion Matrices).
% =====================================================================================
% PURPOSE
%   Determina i percorsi standard del progetto a partire dalla posizione di questo file
%   (atteso in: <root>/Modules/Problem_2/Logic) e garantisce l’esistenza della
%   gerarchia dati "Data/Problem_2/Sessions[/demoMatrices]". Inoltre migra in modo
%   opportunistico eventuali asset legacy collocati in cartelle obsolete.
%
% OUTPUT (struct P)
%   .projectDir   : <root> del progetto
%   .modulesDir   : <root>/Modules
%   .moduleDir    : <root>/Modules/Problem_2
%   .logicDir     : <root>/Modules/Problem_2/Logic
%   .dataRoot     : <root>/Data/Problem_2
%   .sessionsDir  : <root>/Data/Problem_2/Sessions
%   .demoDir      : <root>/Data/Problem_2/Sessions/demoMatrices
%   .demoDirOld   : <root>/Modules/Problem_2/demoMatrices          (legacy)
%
% BEHAVIOR
%   - Crea le directory mancanti (best-effort, con warning non bloccanti).
%   - Effettua migrazioni da:
%       * <root>/Modules/Problem_2/demoMatrices
%       * <root>/Modules/Data/Problem_2/Sessions/demoMatrices   (errata)
%     verso la posizione corretta: <root>/Data/Problem_2/Sessions/demoMatrices
%
% NON-GOALS
%   - Nessuna cancellazione di file sorgente post-migrazione oltre a quanto
%     effettua `movefile` con flag 'f' (overwrite). Nessuna validazione contenuti.
%
% DEPENDENCIES
%   - Richiede permessi di scrittura nelle destinazioni per mkdir/movefile.
% =====================================================================================

    % Posizione di partenza: questo file (atteso in .../Modules/Problem_2/Logic)
    logicDir   = fileparts(mfilename('fullpath'));      % .../Modules/Problem_2/Logic
    moduleDir  = fileparts(logicDir);                   % .../Modules/Problem_2
    modulesDir = fileparts(moduleDir);                  % .../Modules
    projectDir = fileparts(modulesDir);                 % <root>

    % Gerarchia dati CORRETTA (già presente nel repo)
    dataRoot    = fullfile(projectDir,'Data','Problem_2');
    sessionsDir = fullfile(dataRoot,'Sessions');
    demoDir     = fullfile(sessionsDir,'demoMatrices');

    % Posizioni legacy/errate da migrare
    demoDirOld      = fullfile(moduleDir,'demoMatrices');                                 % legacy
    demoDirWrongMod = fullfile(modulesDir,'Data','Problem_2','Sessions','demoMatrices'); % errata

    % Creazione struttura corretta (best-effort; non interrompe in caso di errore)
    i_mkdir_silent(dataRoot);
    i_mkdir_silent(sessionsDir);
    i_mkdir_silent(demoDir);

    % Migrazione automatica (opportunistica) di file demo_*.*
    migrateIfNeeded(demoDirOld,      demoDir);
    migrateIfNeeded(demoDirWrongMod, demoDir);

    % Ritorna struct dei percorsi risolti
    P = struct( ...
        'projectDir',  projectDir, ...
        'modulesDir',  modulesDir, ...
        'moduleDir',   moduleDir, ...
        'logicDir',    logicDir, ...
        'dataRoot',    dataRoot, ...
        'sessionsDir', sessionsDir, ...
        'demoDir',     demoDir, ...
        'demoDirOld',  demoDirOld ...
    );
end

% ------- helpers locali --------------------------------------------------------------

function migrateIfNeeded(srcDir, dstDir)
% MIGRATEIFNEEDED  Sposta (overwrite) i file demo_*.* da srcDir a dstDir, se esistono.
%   - Non solleva errori fatali; in caso di problemi emette un warning.
    if exist(srcDir,'dir') && exist(dstDir,'dir')
        try
            movefile(fullfile(srcDir,'demo_*.*'), dstDir, 'f');  % overwrite permissivo
        catch ME
            warning('[P2] Migrazione da "%s" a "%s" parziale: %s', srcDir, dstDir, ME.message);
        end
    end
end

function i_mkdir_silent(d)
% I_MKDIR_SILENT  Crea directory se mancante. Warning non bloccante in caso di errore.
    if ~exist(d,'dir')
        try
            mkdir(d);
        catch ME
            warning('[P2] Impossibile creare directory "%s": %s', d, ME.message);
        end
    end
end
