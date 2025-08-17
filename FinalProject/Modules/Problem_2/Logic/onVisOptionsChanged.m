function onVisOptionsChanged(fig)
% Legge i valori dei controlli del pannello "Opzioni visuali"
% (dai loro handle salvati in appdata) e ridisegna la heatmap.

    if ~ishandle(fig), return; end

    % --- 1) Recupera gli handle dei controlli salvati dalla UI ---
    H = getappdata(fig,'P2Controls');
    if isempty(H) || ~isstruct(H)
        % fallback robusto (se non è stato salvato per qualche motivo)
        pnl = findall(fig,'Type','uipanel','Title','Opzioni visuali');
        if isempty(pnl), return; end
        ch  = allchild(pnl(1));
        H.chkNorm = findobj(ch,'Type','matlab.ui.control.CheckBox','-regexp','Text','Normalizza');
        H.chkDiag = findobj(ch,'Type','matlab.ui.control.CheckBox','-regexp','Text','Evidenzia');
        H.bg      = findobj(ch,'Type','uibuttongroup','Title','Valori da mostrare');
        H.ddCMap  = findobj(ch,'Type','matlab.ui.control.DropDown');
    end

    % --- 2) Stato corrente delle opzioni ---
    opts = getappdata(fig,'CurrentOpts');
    if isempty(opts), opts = struct; end

    if isfield(H,'chkNorm') && isvalid(H.chkNorm)
        opts.normalizeRows = logical(H.chkNorm.Value);
    else
        if ~isfield(opts,'normalizeRows'), opts.normalizeRows = false; end
    end

    if isfield(H,'chkDiag') && isvalid(H.chkDiag)
        opts.highlightDiag = logical(H.chkDiag.Value);
    else
        if ~isfield(opts,'highlightDiag'), opts.highlightDiag = true; end
    end

    if isfield(H,'bg') && isvalid(H.bg) && ~isempty(H.bg.SelectedObject)
        tg = get(H.bg.SelectedObject,'Tag');        % 'counts' | 'perc'
        opts.showCounts = strcmp(tg,'counts');
        opts.showPerc   = strcmp(tg,'perc');
    else
        if ~isfield(opts,'showCounts'), opts.showCounts = true; end
        if ~isfield(opts,'showPerc'),   opts.showPerc   = false; end
    end

    if isfield(H,'ddCMap') && isvalid(H.ddCMap)
        opts.cmap = char(H.ddCMap.Value);
    else
        if ~isfield(opts,'cmap'), opts.cmap = 'parula'; end
    end

    setappdata(fig,'CurrentOpts',opts);

    % --- 3) Se non c'è matrice caricata, finiamo qui ---
    C = getappdata(fig,'CurrentConfMat');
    labels = getappdata(fig,'CurrentLabels');
    if isempty(C) || isempty(labels), return; end

    % --- 4) Replot sull'axes corretto ---
    ax = getappdata(fig,'AxesCMHandle');
    if isempty(ax) || ~isvalid(ax)
        axAll = findall(fig,'Type','uiaxes','-and','Tag','AxesCM');
        if isempty(axAll), return; end
        if numel(axAll)>1, delete(axAll(2:end)); end
        ax = axAll(1);
        setappdata(fig,'AxesCMHandle', ax);
    end

    cla(ax,'reset');
    ax.CLimMode = 'auto';
    plotConfusionMatrix(ax, C, labels, opts);
    drawnow;
end
