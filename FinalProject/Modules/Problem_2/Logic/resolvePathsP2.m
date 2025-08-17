function P = resolvePathsP2()
% Path utility per il Problema 2 (usa la Data esistente a livello progetto).

    % Questo file è in: <root>/Modules/Problem_2/Logic
    logicDir   = fileparts(mfilename('fullpath'));      % .../Modules/Problem_2/Logic
    moduleDir  = fileparts(logicDir);                   % .../Modules/Problem_2
    modulesDir = fileparts(moduleDir);                  % .../Modules
    projectDir = fileparts(modulesDir);                 % <root>   <-- QUI la differenza

    % Posizione CORRETTA (già esistente nel tuo repo)
    dataRoot    = fullfile(projectDir,'Data','Problem_2');
    sessionsDir = fullfile(dataRoot,'Sessions');
    demoDir     = fullfile(sessionsDir,'demoMatrices');

    % Retrocompatibilità:
    demoDirOld      = fullfile(moduleDir,'demoMatrices');                                 % vecchia sotto Modules/Problem_2
    demoDirWrongMod = fullfile(modulesDir,'Data','Problem_2','Sessions','demoMatrices'); % sbagliata creata sotto Modules/Data

    % Assicura struttura corretta
    if ~exist(dataRoot,'dir'),    mkdir(dataRoot);    end
    if ~exist(sessionsDir,'dir'), mkdir(sessionsDir); end
    if ~exist(demoDir,'dir'),     mkdir(demoDir);     end

    % Migrazione automatica da posizioni legacy/sbagliate
    migrateIfNeeded(demoDirOld,      demoDir);
    migrateIfNeeded(demoDirWrongMod, demoDir);

    % Ritorno struct
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

% ------- helper -------
function migrateIfNeeded(srcDir, dstDir)
    if exist(srcDir,'dir') && exist(dstDir,'dir')
        try
            % sposta tutti i demo_*.* nella posizione corretta
            movefile(fullfile(srcDir,'demo_*.*'), dstDir, 'f');
        catch ME
            warning('[P2] Migrazione da "%s" a "%s" parziale: %s', srcDir, dstDir, ME.message);
        end
    end
end
