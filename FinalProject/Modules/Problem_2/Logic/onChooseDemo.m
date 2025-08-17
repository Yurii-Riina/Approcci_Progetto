function onChooseDemo(fig)
% Mostra un elenco di demo, garantisce la presenza dei file
% (creandoli o migrandoli se necessario), carica e plotta.

    % --- Path: nuova posizione + retrocompatibilità ---
    P = resolvePathsP2();                 % deve restituire .demoDir e .demoDirOld
    demoDir    = P.demoDir;               % Data/Problem_2/Sessions/demoMatrices
    demoDirOld = P.demoDirOld;            % Problem_2/demoMatrices (vecchia)

    if ~exist(demoDir,'dir'), mkdir(demoDir); end

    % --- Assicurati che le 3 demo ci siano ---
    req = {'demo_base.mat','demo_unbalanced.mat','demo_cross.mat'};
    needCreate = any(~cellfun(@(f) isfile(fullfile(demoDir,f)), req));

    % Se mancano e c'è la vecchia cartella → prova a migrare/copiare
    if needCreate && exist(demoDirOld,'dir')
        try
            for k = 1:numel(req)
                src = fullfile(demoDirOld, req{k});
                if isfile(src), copyfile(src, demoDir, 'f'); end
                csvsrc = strrep(src,'.mat','.csv');
                if isfile(csvsrc), copyfile(csvsrc, demoDir, 'f'); end
            end
            needCreate = any(~cellfun(@(f) isfile(fullfile(demoDir,f)), req));
        catch
            % se qualcosa va storto, lasciamo needCreate=true e creiamo da zero
        end
    end

    % Se ancora mancano → crea ex-novo
    if needCreate
        try
            createP2Demos();   % scrive già in P.demoDir
        catch ME
            warning('%s - [P2] createP2Demos fallita: %s. Uso fallback sintetico.', ...
                    ME.identifier, ME.message);
            % --- Fallback sintetico 6x6 ---
            C = [45 2 3 0 1 0; 3 40 2 1 4 0; 2 3 42 5 3 1; ...
                 0 2 3 47 2 1; 1 4 2 2 44 3; 0 1 2 1 2 46];
            labels = {'Anger','Disgust','Fear','Happiness','Sadness','Surprise'};
            meta.name = 'fallback_sintetico.mat';

            % stato corrente
            setappdata(fig,'CurrentConfMat',C);
            setappdata(fig,'CurrentLabels',labels);
            setappdata(fig,'CurrentSourceName', meta.name);

            % plot sul SOLO axes corretto
            ax = localGetAxes(fig);
            cla(ax,'reset'); ax.CLimMode = 'auto';
            opts = getappdata(fig,'CurrentOpts');
            plotConfusionMatrix(ax, C, labels, opts);

            % titolo + log
            base = 'Confusion Matrix';
            if isfield(opts,'normalizeRows') && opts.normalizeRows
                base = 'Confusion Matrix (rows %)';
            end
            title(ax, sprintf('%s — %s', base, strrep(meta.name,'_','\_')));
            logP2(fig, sprintf('Demo caricata: %s | checksum=%.0f', meta.name, sum(C(:))));
            drawnow;
            return;
        end
    end

    % --- Elenco demo “umane” ---
    displayNames = { ...
        'Demo base (realistica)', ...
        'Demo sbilanciata (supporto)', ...
        'Demo incrociata (Fear↔Sadness)'};
    files = { ...
        fullfile(demoDir,'demo_base.mat'), ...
        fullfile(demoDir,'demo_unbalanced.mat'), ...
        fullfile(demoDir,'demo_cross.mat')};

    % --- Dialog selezione ---
    [idx, ok] = listdlg('PromptString','Seleziona una demo:', ...
                        'SelectionMode','single', ...
                        'ListString',displayNames, ...
                        'ListSize',[380 250]);
    if ~ok
        logP2(fig,'Demo annullata.');
        return;
    end
    chosen = files{idx};

    % --- Carica/valida/plotta ---
    try
        [C, labels, meta] = importConfMat(chosen);
        S = validateConfMat(C, labels);
        if ~S.ok
            uialert(fig,S.msg,'Demo non valida');
            logP2(fig, ['ERRORE demo: ' S.msg]);
            return;
        end

        % Stato corrente
        setappdata(fig,'CurrentConfMat', C);
        setappdata(fig,'CurrentLabels',  labels);
        setappdata(fig,'CurrentSourceName', meta.name);

        % Recupera axes unico + reset hard
        ax = localGetAxes(fig);
        cla(ax,'reset'); ax.CLimMode = 'auto';

        % Plot
        opts = getappdata(fig,'CurrentOpts');
        plotConfusionMatrix(ax, C, labels, opts);

        % Titolo con nome demo
        base = 'Confusion Matrix';
        if isfield(opts,'normalizeRows') && opts.normalizeRows
            base = 'Confusion Matrix (rows %)';
        end
        title(ax, sprintf('%s — %s', base, strrep(meta.name,'_','\_')));

        % Log + refresh
        logP2(fig, sprintf('Demo caricata: %s | checksum=%.0f', meta.name, sum(C(:))));
        drawnow;

    catch ME
        uialert(fig, ME.message, 'Errore demo');
        logP2(fig, ['ERRORE demo: ' ME.message]);
    end
end

% ================= helpers locali =================
function ax = localGetAxes(fig)
    % prova a riusare handle persistente
    ax = getappdata(fig,'AxesCMHandle');
    if ~isempty(ax) && isvalid(ax), return; end

    % fallback: trova tutti gli axes con Tag e tieni il primo, elimina duplicati
    axAll = findall(fig,'Type','uiaxes','-and','Tag','AxesCM');
    if isempty(axAll)
        error('AxesCM non trovato nella UI.');
    end
    if numel(axAll) > 1
        delete(axAll(2:end));
    end
    ax = axAll(1);
    setappdata(fig,'AxesCMHandle', ax);
end
