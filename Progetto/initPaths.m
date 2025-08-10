% initPaths.m
% Inizializza tutti i percorsi utili per il progetto Approcci e Sistemi
% Da richiamare UNA VOLTA a inizio esecuzione (es. in createApp.m)

function initPaths()
    base = fileparts(mfilename('fullpath'));

    % === Path principali ===
    addpath(genpath(fullfile(base, 'Main')));
    addpath(genpath(fullfile(base, 'Modules')));
    addpath(genpath(fullfile(base, 'Documentation')));
    addpath(genpath(fullfile(base, 'Data')));

    % === Path UI separati ===
    addpath(genpath(fullfile(base, 'Main', 'ModulesUI')));

    % === Immagini globali (es. logo) ===
    addpath(fullfile(base, 'Main'));

    % === Cartelle per ogni problema ===
    problems = dir(fullfile(base, 'Modules', 'Problem*'));
    for i = 1:length(problems)
        if problems(i).isdir
            addpath(genpath(fullfile(problems(i).folder, problems(i).name)));
        end
    end

    % === Cartelle immagini (per ogni problema) ===
    imageDirs = dir(fullfile(base, 'Modules', 'Problem*', 'Images'));
    for i = 1:length(imageDirs)
        if imageDirs(i).isdir
            addpath(imageDirs(i).folder);
        end
    end

    % === CSV e file di test ===
    testDirs = dir(fullfile(base, 'Modules', 'Problem*', 'Test*'));
    for i = 1:length(testDirs)
        if testDirs(i).isdir
            addpath(testDirs(i).folder);
        end
    end

    % === Output ===
    disp('[initPaths] Percorsi inizializzati con successo.');
end