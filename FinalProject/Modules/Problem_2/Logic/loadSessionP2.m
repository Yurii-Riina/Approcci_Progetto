function loadSessionP2(fig)
% LOADSESSIONP2  Ripristina una sessione salvata del Modulo 2 (file .mat con struct S).
% =====================================================================================
% PURPOSE
%   Carica da disco una sessione P2 serializzata (variabile S dentro al .mat) e
%   reinstaura:
%     - AppData principali (HistoryP2, matrice/labels correnti, opzioni…)
%     - Snapshot UI della Tab 5 (tabella storico, log esteso, stato)
%     - Valori dei dropdown Tab3/Tab4
%     - Rendering heatmap corrente (Tab2) e, se possibile, confronto immediato (Tab4)
%
% INPUT
%   fig : handle della uifigure principale.
%
% DEPENDENCIES (best-effort; funzioni opzionali gestite in try/catch)
%   - setSessionStatus, refreshP2History, plotConfusionMatrix, writeFullLog, logP2
%
% BEHAVIOR
%   - UX: uigetfile su *.mat; messaggi chiari in caso di I/O/format error.
%   - Robust: nessun throw fatale; la UI non deve mai “rompersi”.
%   - Non usa 'cla(...,"reset")' sugli axes (evita perdita di Tag/props).
% =====================================================================================

    % --- Selezione file --------------------------------------------------------------
    [f,p] = uigetfile('*.mat','Carica sessione (P2)');
    if isequal(f,0), return; end

    % --- Caricamento robusto (.mat deve contenere 'S') -------------------------------
    try
        tmp = load(fullfile(p,f));
    catch ME
        try uialert(fig, ['Errore I/O: ' ME.message],'Errore'); catch, end
        try setSessionStatus(fig,'Caricamento fallito - I/O',false,[],'error'); catch, end
        return;
    end
    if ~isfield(tmp,'S')
        try uialert(fig,'File non valido: manca la struct S.','Errore'); catch, end
        try setSessionStatus(fig,'Caricamento fallito - Formato',false,[],'error'); catch, end
        return;
    end
    S = tmp.S;

    % --- Ripristino AppData principali ----------------------------------------------
    if isfield(S,'HistoryP2'),         setappdata(fig,'HistoryP2',S.HistoryP2); end
    if isfield(S,'CurrentConfMat'),    setappdata(fig,'CurrentConfMat',S.CurrentConfMat); end
    if isfield(S,'CurrentLabels'),     setappdata(fig,'CurrentLabels',S.CurrentLabels); end
    if isfield(S,'CurrentSourceName'), setappdata(fig,'CurrentSourceName',S.CurrentSourceName); end
    if isfield(S,'CurrentOpts') && ~isempty(S.CurrentOpts)
        setappdata(fig,'CurrentOpts',S.CurrentOpts);
    end

    % --- UI Tab5: tabella storico, log esteso, stato --------------------------------
    tbl = findobj(fig,'Tag','HistoryTableP2');
    if ~isempty(tbl) && isgraphics(tbl)
        tbl.Data = safeGet(S,'HistoryTableP2',{});
    end
    logBox = findobj(fig,'Tag','FullLogBoxP2');
    if ~isempty(logBox) && isgraphics(logBox)
        L = safeGet(S,'FullLogP2',{});
        if isempty(L), L = {''}; end
        logBox.Value = L;
    end
    stLab = findobj(fig,'Tag','SessionStatusLabel');
    if ~isempty(stLab) && isgraphics(stLab)
        stLab.Text = safeGet(S,'SessionStatusText','');
    end

    % --- Ripopola storico e reimposta dropdown (Tab3/Tab4) --------------------------
    try
        refreshP2History(fig);  % popola MetricsHistoryDropdown / CompareDropLeft / CompareDropRight

        ddM = findobj(fig,'Tag','MetricsHistoryDropdown');
        ddL = findobj(fig,'Tag','CompareDropLeft');
        ddR = findobj(fig,'Tag','CompareDropRight');

        i_setDropValue(ddM, safeGet(S,'MetricsHistoryDropdownValue',''));
        i_setDropValue(ddL, safeGet(S,'CompareDropLeftValue',''));
        i_setDropValue(ddR, safeGet(S,'CompareDropRightValue',''));
    catch
        % best-effort: i dropdown potranno essere scelti dall’utente
    end

    % --- Ridisegna subito la heatmap corrente in Tab2 (se presente) -----------------
    try
        C  = getappdata(fig,'CurrentConfMat');
        lb = getappdata(fig,'CurrentLabels');
        if ~isempty(C) && ~isempty(lb)
            ax = getappdata(fig,'AxesCMHandle');
            if isempty(ax) || ~isgraphics(ax)
                ax = findall(fig,'Type','uiaxes','-and','Tag','AxesCM');
                if ~isempty(ax), ax = ax(1); setappdata(fig,'AxesCMHandle',ax); end
            end
            if ~isempty(ax)
                opts = getappdata(fig,'CurrentOpts');
                if isempty(opts)
                    opts = struct('normalizeRows',false,'showCounts',true,'showPerc',false,'cmap','parula','highlightDiag',true);
                end
                cla(ax); plotConfusionMatrix(ax,C,lb,opts);
            end
        end
    catch
    end

    % --- Confronto auto: seleziona Tab4, stabilizza layout, poi onCompare -----------
    try
        % focus sulla tab "🆚 Confronto"
        tg = findobj(fig,'Type','uitabgroup');
        tabCompare = [];
        if ~isempty(tg)
            tabs = findobj(tg,'Type','uitab');
            tabCompare = findobj(tabs,'Title','🆚 Confronto');
            if ~isempty(tabCompare)
                tg.SelectedTab = tabCompare(1);
            end
        end

        % rimuovi un eventuale pannello riepilogo precedente
        if ~isempty(tabCompare)
            oldRpt = findobj(tabCompare(1),'Tag','CompareReportPanel');
            if ~isempty(oldRpt)
                try delete(oldRpt(ishghandle(oldRpt))); catch, end
            end
        end

        % stabilizza layout (posizioni calcolate) e attiva confronto se sensato
        drawnow; pause(0.01);
        ddR = findobj(fig,'Tag','CompareDropRight');
        valR = ""; if ~isempty(ddR) && isgraphics(ddR), valR = string(ddR.Value); end
        if ~contains(valR,"storico vuoto")
            onCompare(fig);  % dentro fa un ulteriore drawnow prima del pannello
        end
    catch
        % opzionale/silenzioso: utente potrà premere "Confronta"
    end

    % --- Log + stato finale ----------------------------------------------------------
    try writeFullLog(fig, sprintf('Caricata sessione: %s', fullfile(p,f))); catch, end
    logP2(fig, sprintf('[P2] Caricata sessione: %s', fullfile(p,f)));
    try setSessionStatus(fig,'Caricamento sessione',true,[],'ok'); catch, end
end

%% ===== Helpers locali ===============================================================
function v = safeGet(S,f,def)
% SAFEGET  Ritorna S.(f) se presente/non vuoto, altrimenti def.
    if isfield(S,f) && ~isempty(S.(f)), v = S.(f); else, v = def; end
end

function i_setDropValue(h, val)
% I_SETDROPVALUE  Setta Value del dropdown se handle valido e val non vuoto.
    if isempty(h) || ~isgraphics(h) || isempty(val), return; end
    try
        h.Value = val;
    catch
    end
end
