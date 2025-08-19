function onVisOptionsChanged(fig)
% ONVISOPTIONSCHANGED  Legge le opzioni del pannello e ridisegna la heatmap.
% =====================================================================================
% PURPOSE
%   Sincronizza lo stato 'CurrentOpts' con i controlli del pannello "Opzioni visuali"
%   e, se presente una matrice corrente, ne aggiorna il rendering in Tab2.
%
% INPUT
%   fig : handle della uifigure principale.
%
% BEHAVIOR
%   1) Recupera gli handle dei controlli (da AppData 'P2Controls' o via fallback).
%   2) Aggiorna/normalizza 'CurrentOpts' in AppData (senza toccare dati "core").
%   3) Se esiste 'CurrentConfMat' + 'CurrentLabels', richiama plotConfusionMatrix.
%
% ROBUSTEZZA
%   - Tollerante ad assenza/invalidità dei controlli (no error → return silenzioso).
%   - Non usa 'cla(...,"reset")' sugli axes per non perdere Tag/stili.
%
% NON-GOALS
%   - Nessuna validazione della matrice (delegata a validateConfMat/Core).
%   - Nessun I/O o persistenza esterna.
% =====================================================================================

    if ~ishandle(fig), return; end

    % --- 1) Recupero controlli del pannello "Opzioni visuali" ------------------------
    H = getappdata(fig,'P2Controls');
    if isempty(H) || ~isstruct(H)
        % Fallback: ricerca euristica nel pannello per rimanere resilienti
        pnl = findall(fig,'Type','uipanel','Title','Opzioni visuali');
        if isempty(pnl), return; end
        ch        = allchild(pnl(1));
        H.chkNorm = findobj(ch,'Type','matlab.ui.control.CheckBox','-regexp','Text','Normalizza');
        H.chkDiag = findobj(ch,'Type','matlab.ui.control.CheckBox','-regexp','Text','Evidenzia');
        H.bg      = findobj(ch,'Type','uibuttongroup','Title','Valori da mostrare');
        H.ddCMap  = findobj(ch,'Type','matlab.ui.control.DropDown');
    end

    % --- 2) Aggiornamento stato opzioni in AppData -----------------------------------
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
        tg = get(H.bg.SelectedObject,'Tag');               % 'counts' | 'perc'
        opts.showCounts = strcmp(tg,'counts');
        opts.showPerc   = strcmp(tg,'perc');
    else
        if ~isfield(opts,'showCounts'), opts.showCounts = true;  end
        if ~isfield(opts,'showPerc'),   opts.showPerc   = false; end
    end

    if isfield(H,'ddCMap') && isvalid(H.ddCMap)
        opts.cmap = char(H.ddCMap.Value);
    else
        if ~isfield(opts,'cmap'), opts.cmap = 'parula'; end
    end

    setappdata(fig,'CurrentOpts',opts);

    % --- 3) Replot solo se c'è una matrice corrente ----------------------------------
    C      = getappdata(fig,'CurrentConfMat');
    labels = getappdata(fig,'CurrentLabels');
    if isempty(C) || isempty(labels), return; end

    % --- 4) Individua axes target e ridisegna ----------------------------------------
    ax = getappdata(fig,'AxesCMHandle');
    if isempty(ax) || ~isvalid(ax)
        axAll = findall(fig,'Type','uiaxes','-and','Tag','AxesCM');
        if isempty(axAll), return; end
        if numel(axAll) > 1, delete(axAll(2:end)); end  % mantieni solo il primo
        ax = axAll(1);
        setappdata(fig,'AxesCMHandle', ax);
    end

    % Importante: evitare 'reset' per non perdere Tag/stili/limiti personalizzati
    cla(ax);
    ax.CLimMode = 'auto';
    plotConfusionMatrix(ax, C, labels, opts);
    drawnow;
end
