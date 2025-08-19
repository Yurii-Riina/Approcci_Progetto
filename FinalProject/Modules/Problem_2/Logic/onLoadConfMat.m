function onLoadConfMat(fig)
% ONLOADCONFMAT  Carica una matrice di confusione da .mat/.csv, valida e visualizza.
% =====================================================================================
% PURPOSE
%   Seleziona un file contenente una matrice di confusione (NxN) e, se valido:
%     - aggiorna lo stato corrente (AppData: C, labels, sorgente)
%     - ridisegna la heatmap in Tab2 con le opzioni correnti
%     - registra un log sintetico dell’operazione
%
% INPUT
%   fig : handle della uifigure principale (richiesto).
%
% DEPENDENCIES (deleghe)
%   importConfMat(fullpath)  -> [C, labels, meta]
%   validateConfMat(C,labels)-> struct esito/diagnostica (Core)
%   plotConfusionMatrix(ax, C, labels, opts)
%   logP2(fig, msg), setSessionStatus(fig, ...)
%
% BEHAVIOR
%   - Dialogo file: accetta .mat e .csv
%   - Validazione difensiva (no crash): uialert + log in caso d’errore
%   - Non usa 'cla(...,"reset")'; non altera proprietà degli axes
% =====================================================================================

    % --- 0) File picker --------------------------------------------------------------
    [file, path] = uigetfile({'*.mat;*.csv','MAT or CSV'}, 'Seleziona matrice di confusione');
    if isequal(file,0)
        logP2(fig,'Annullato.');
        return;
    end
    full = fullfile(path, file);

    try
        % --- 1) Import + validazione -------------------------------------------------
        [C, labels, meta] = importConfMat(full);      % delega parsing/IO
        S = validateConfMat(C, labels);               % delega logica "Core"
        if ~S.ok
            uialert(fig, S.msg, 'Input non valido');
            logP2(fig, ['ERRORE: ' S.msg]);
            return;
        end

        % --- 2) Stato corrente -------------------------------------------------------
        setappdata(fig,'CurrentConfMat', C);
        setappdata(fig,'CurrentLabels',  labels);
        % opzionale: salva info sorgente se esiste questo appdata altrove nel progetto
        try setappdata(fig,'CurrentSourceName', meta.name); catch, end

        % --- 3) Recupero opzioni e axes target --------------------------------------
        opts = getappdata(fig,'CurrentOpts');
        if isempty(opts)
            % default coerenti con la UI
            opts = struct('normalizeRows',false,'showCounts',true,'showPerc',false,'cmap','parula','highlightDiag',true);
        end

        ax = getappdata(fig,'AxesCMHandle');
        if isempty(ax) || ~isvalid(ax)
            % fallback: cerca l’axes per Tag
            axAll = findobj(fig,'Type','uiaxes','-and','Tag','AxesCM');
            if isempty(axAll)
                uialert(fig,'Axes della matrice non trovato. Apri la Tab "Matrice" e riprova.','UI non pronta');
                logP2(fig,'ERRORE: AxesCM non trovato per il render.');
                return;
            end
            ax = axAll(1);
            setappdata(fig,'AxesCMHandle', ax);
        end

        % --- 4) Render ---------------------------------------------------------------
        plotConfusionMatrix(ax, C, labels, opts);

        % --- 5) Log/Status -----------------------------------------------------------
        % meta.note è opzionale; gestisci assenza senza rompere il formato
        noteStr = '';
        try
            if isfield(meta,'note') && ~isempty(meta.note)
                noteStr = meta.note;
            end
        catch
        end
        msg = sprintf('Caricato: %s [%dx%d]%s', meta.name, size(C,1), size(C,2), noteStr);
        logP2(fig, msg);
        try setSessionStatus(fig,'Caricamento matrice',true,meta.name,'ok'); catch, end

    catch ME
        % Qualsiasi eccezione: alert non-bloccante + log + status
        try uialert(fig, ME.message, 'Errore caricamento'); catch, end
        logP2(fig, ['ERRORE caricamento: ' ME.message]);
        try setSessionStatus(fig,'Caricamento matrice',false,[], 'error'); catch, end
    end
end
