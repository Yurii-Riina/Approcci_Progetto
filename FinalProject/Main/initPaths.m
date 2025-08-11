function P = initPaths()
% INITPATHS  Inizializza i percorsi (path) del progetto e crea le cartelle dati.
%
% SCOPO
%   - Aggiunge al MATLAB path **solo** le directory contenenti codice eseguibile
%     (Main, SharedUtils, ThirdParty, Modules).
%   - NON aggiunge al path le directory dei dati (Data), perché contengono file
%     prodotti/consumati dall’applicazione e non funzioni.
%   - Garantisce l’esistenza delle cartelle dati target per ogni problema:
%       Data/Problem_N/Sessions   (salvataggi di sessione .mat)
%       Data/Problem_N/Exports    (esportazioni .csv, ecc.)
%
% POSIZIONE
%   Questo file deve risiedere in:  <root>/Main/initPaths.m
%
% UTILIZZO
%   Richiamare una sola volta all’avvio, ad es. come prima riga in createApp().
%   [P] = initPaths();              % opzionale: ritorna struttura con percorsi utili
%
% NOTE
%   - La funzione è idempotente: può essere richiamata più volte senza
%     duplicare i path.
%   - Non modifica il *current folder*; lavora solo con percorsi assoluti.

    %% === 1) Individuazione radice del progetto ===
    % 'mainDir' è la cartella in cui si trova questo file (Main).
    % La radice del progetto è il livello superiore rispetto a Main.
    mainDir = fileparts(mfilename('fullpath'));  % ...\Progetto\Main
    rootDir = fileparts(mainDir);                % ...\Progetto

    %% === 2) Elenco delle directory di CODICE da mettere sul path ===
    % Inseriamo Main (solo top-level), le utility condivise e di terze parti
    % con tutte le sottocartelle, gli asset globali (immagini per UI) e
    % l'intero albero Modules (Problem_1, Problem_2, ...).
    codeDirs = { ...
        fullfile(rootDir, 'Main'), ...
        fullfile(rootDir, 'Main', 'SharedUtils'), ...
        fullfile(rootDir, 'Main', 'ThirdParty'), ...
        fullfile(rootDir, 'Main', 'Assets'), ...
        fullfile(rootDir, 'Modules') ...
    };

    % Opzionale: ripristina il path “pulito” di MATLAB prima di aggiungere il nostro.
    % Scommenta le tre righe seguenti se vuoi evitare eredità di vecchi path.
    % restoredefaultpath;
    % rehash toolboxcache;
    % savepath;

    % Aggiunta al path in modo selettivo:
    % - Main: solo la cartella (non le eventuali sottocartelle private)
    addpath(codeDirs{1});

    % - SharedUtils e ThirdParty: intero albero (potrebbero contenere pacchetti)
    addpath(genpath(codeDirs{2}));
    addpath(genpath(codeDirs{3}));

    % - Assets: solo la cartella (contiene immagini/icone usate da UI)
    addpath(codeDirs{4});

    % - Modules: intero albero (tutto il codice dei problemi)
    addpath(genpath(codeDirs{5}));

    %% === 3) Preparazione delle directory DATI (non vengono messe sul path) ===
    % Struttura dati target per output dell’applicazione.
    dataRoot = fullfile(rootDir, 'Data');
    ensureDir(dataRoot);

    % Per i problemi 1..5 creiamo sempre le due sottocartelle standard.
    for k = 1:5
        pK = fullfile(dataRoot, sprintf('Problem_%d', k));
        ensureDir(pK);
        ensureDir(fullfile(pK, 'Sessions'));  % .mat di sessione
        ensureDir(fullfile(pK, 'Exports'));   % .csv, eventuali .xlsx, ecc.
    end

    %% === 4) Messaggio finale e (opzionale) struct di ritorno ===
    fprintf('[initPaths] Percorsi inizializzati. Root: %s\n', rootDir);

    if nargout
        % La struct P è utile per funzioni che desiderano path assoluti
        % senza ricostruirli ogni volta.
        P.Root       = rootDir;
        P.Main       = mainDir;
        P.Modules    = fullfile(rootDir, 'Modules');
        P.Data       = dataRoot;
        P.Assets     = fullfile(rootDir, 'Main', 'Assets');
        P.Shared     = fullfile(rootDir, 'Main', 'SharedUtils');
        P.ThirdParty = fullfile(rootDir, 'Main', 'ThirdParty');
    end
end

%% ========== Funzioni locali di servizio ==========

function ensureDir(d)
% ENSUREDIR  Crea la directory 'd' se non esiste (no error se già presente).
    if ~exist(d, 'dir')
        mkdir(d);
    end
end