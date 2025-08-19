function onCompare(fig)
% ONCOMPARE  Confronto Tab4: heatmap L/R + pannello riepilogo (KPI, Δ per classe, insight).
% =====================================================================================
% PURPOSE
%   Esegue il confronto tra due matrici di confusione:
%     - Sorgente LEFT: matrice corrente oppure scelta A (dropdown)
%     - Sorgente RIGHT: scelta B (dropdown, obbligatoria)
%     - Render heatmap sincronizzate (stessa CLim/colormap)
%     - Report "card": KPI globali, tabella Δ e top gains/losses
%
% UI CONTRACT (Tag richiesti nella Tab "🆚 Confronto")
%   Axes : 'CompareAxesLeft', 'CompareAxesRight'
%   Drops: 'CompareDropLeft', 'CompareDropRight'
%   Legacy: 'CompareSummaryBox' (verrà nascosto)
%
% DEPENDENCIES
%   - AppData: 'HistoryP2', 'CurrentConfMat', 'CurrentLabels', 'CurrentOpts', 'CurrentSourceName'
%   - Helpers esterni: plotConfusionMatrix, logP2 (opz.), setSessionStatus (opz.)
%
% BEHAVIOR
%   - Non usa 'cla(...,"reset")' per non perdere Tag/stili; pulizia children-only.
%   - Matching voci storico coerente con refreshP2History (gestione NaN -> "acc n/d").
% =====================================================================================

    %% --- Recupera storico e controlli ---
    H = getappdata(fig,'HistoryP2');
    if isempty(H)
        localAlert(fig,'Storico vuoto. Aggiungi almeno una matrice.');
        return;
    end

    ddL = findobj(fig,'Tag','CompareDropLeft');
    ddR = findobj(fig,'Tag','CompareDropRight');

    axL = findobj(fig,'Tag','CompareAxesLeft');
    axR = findobj(fig,'Tag','CompareAxesRight');
    if isempty(axL) || isempty(axR)
        localLog(fig,'[P2] onCompare: axes non trovati.');
        return;
    end
    axL = axL(1); axR = axR(1);    % in caso di duplicati, usa il primo

    % Parent corretto (la uitab "Confronto")
    tabParent = axL.Parent;

    % 🔧 Pulisci heatmap senza perdere il Tag (niente 'reset')
    cla(axL); cla(axR);
    axL.CLimMode = 'auto'; axR.CLimMode = 'auto';
    axL.NextPlot = 'replacechildren'; axR.NextPlot = 'replacechildren';
    axL.Tag = 'CompareAxesLeft';      axR.Tag = 'CompareAxesRight';

    % 🔧 Rimuovi eventuale report precedente (solo in questa tab)
    oldRpt = findobj(tabParent,'Tag','CompareReportPanel');
    delete(oldRpt(ishghandle(oldRpt)));

    % 🔧 Nascondi la vecchia textarea legacy per evitare sovrapposizioni
    oldTxt = findobj(tabParent,'Tag','CompareSummaryBox');
    if ~isempty(oldTxt) && isvalid(oldTxt), oldTxt.Visible = 'off'; end

    %% --- RIGHT (obbligatorio: storico) ---
    pickR = localGetDropValue(ddR);
    idxR  = localFindHistoryIndex(H, pickR);
    if isnan(idxR)
        localAlert(fig,'Seleziona una voce valida per B (destra).');
        localLog(fig,'[P2] onCompare: selezione B non trovata.');
        return;
    end
    Cr      = H(idxR).C;   
    labelsR = H(idxR).labels;   
    nameR   = H(idxR).name;

    %% --- LEFT (corrente se disponibile, altrimenti storico/Scelta A) ---
    useCurrent = true;
    pickL = localGetDropValue(ddL);
    if strlength(pickL)>0 && pickL ~= "-- storico vuoto --"
        idxL = localFindHistoryIndex(H, pickL);
        if ~isnan(idxL)
            Cl = H(idxL).C; labelsL = H(idxL).labels; nameL = H(idxL).name;
            useCurrent = false;
        end
    end
    if useCurrent
        Ccur = getappdata(fig,'CurrentConfMat');
        Lcur = getappdata(fig,'CurrentLabels');
        if ~isempty(Ccur)
            Cl = Ccur; labelsL = Lcur;
            nameL = localGetWithDefault(getappdata(fig,'CurrentSourceName'),'corrente');
        else
            % fallback: ultima voce diversa dalla right (o la stessa se unica)
            idxL = find((1:numel(H))~=idxR, 1, 'last'); 
            if isempty(idxL), idxL = idxR; end
            Cl = H(idxL).C; labelsL = H(idxL).labels; nameL = H(idxL).name;
        end
    end

    %% --- Opzioni visuali correnti (coerenza Tab "Matrice") ---
    opts = getappdata(fig,'CurrentOpts');
    if isempty(opts)
        opts = struct('normalizeRows',false,'showCounts',true,'showPerc',false, ...
                      'cmap','parula','highlightDiag',true);
    end

    %% --- Heatmap L/R + stessa scala colore ---
    plotConfusionMatrix(axL, Cl, labelsL, opts);
    plotConfusionMatrix(axR, Cr, labelsR, opts);
    baseTitle = 'Confusion Matrix';
    if isfield(opts,'normalizeRows') && opts.normalizeRows
        baseTitle = 'Confusion Matrix (rows %)';
    end
    title(axL, sprintf('%s — %s', baseTitle, strrep(nameL,'_','\_')));
    title(axR, sprintf('%s — %s', baseTitle, strrep(nameR,'_','\_')));

    % Sincronizza CLim fra i due axes
    clim = [min(axL.CLim(1), axR.CLim(1))  max(axL.CLim(2), axR.CLim(2))];
    axL.CLim = clim; axR.CLim = clim;

    % Assicurati che le Position siano aggiornate prima del layout report
    drawnow;

    %% --- Riepilogo elegante (pannello, no textarea) ---
    localRenderCompareReport(tabParent, Cl, labelsL, Cr, labelsR, nameL, nameR);

    localLog(fig, sprintf('[P2] Confronto eseguito: LEFT=%s, RIGHT=%s', nameL, nameR));
end

%% ===== Report renderer ===============================================================
function localRenderCompareReport(parent, Cl, labelsL, Cr, labelsR, nameL, nameR)
    % parent = uitab "Confronto"

    % ---------- spazio sotto le heatmap (senza sovrapposizioni) ----------
    parPos = parent.InnerPosition;
    axL    = findobj(parent,'Tag','CompareAxesLeft');
    pad = 20;  gap = 32;
    if ~isempty(axL)
        axPos = axL(1).Position;
        topOfReportY = axPos(2) - gap;
    else
        topOfReportY = parPos(4) - 240;
    end
    availH = max(80, topOfReportY - 10);
    pH     = min(240, availH);
    pW     = parPos(3) - 2*pad;  pX = pad;  pY = 20;

    % ---------- pannello contenitore ----------
    p = uipanel(parent,'Position',[pX pY pW pH], ...
        'Title','Riepilogo confronto', ...
        'BackgroundColor',[1 1 1], ...
        'FontName','Segoe UI','FontSize',12, ...
        'Tag','CompareReportPanel');

    % ---------- allineamento classi ----------
    [L, ia, ib] = intersect(string(labelsL), string(labelsR),'stable');
    if isempty(L)
        uilabel(p,'Text','Le etichette delle classi non coincidono. Impossibile confrontare.', ...
            'Position',[12 12 pW-24 24],'FontSize',13,'WordWrap','on');
        return;
    end

    % metriche per classe/globali
    tpL  = diag(Cl); rowL = sum(Cl,2); accL = nan(size(tpL)); mL = rowL>0; accL(mL)=tpL(mL)./rowL(mL); accL = accL(ia);
    tpR  = diag(Cr); rowR = sum(Cr,2); accR = nan(size(tpR)); mR = rowR>0; accR(mR)=tpR(mR)./rowR(mR); accR = accR(ib);
    accGL = sum(diag(Cl))/max(sum(Cl,'all'),1);
    accGR = sum(diag(Cr))/max(sum(Cr,'all'),1);
    dG    = accGL - accGR;
    dV    = 100*(accL - accR);

    % ---------- grid 3x2 ----------
    g = uigridlayout(p,[3 2]);
    g.RowHeight     = {'fit','fit','1x'};
    g.ColumnWidth   = {'3.2x','2x'};
    g.Padding       = [12 6 12 8];
    g.RowSpacing    = 6;
    g.ColumnSpacing = 10;

    % Titoli
    tA = uilabel(g,'Text',['A: ' char(nameL)], 'FontSize',14,'FontWeight','bold','FontColor',[0.09 0.37 0.70]); 
    tA.Layout.Row=1; tA.Layout.Column=1;
    tB = uilabel(g,'Text',['B: ' char(nameR)], 'FontSize',14,'FontWeight','bold','FontColor',[0.85 0.45 0.00], 'HorizontalAlignment','right'); 
    tB.Layout.Row=1; tB.Layout.Column=2;

    % KPI
    kpiL = uilabel(g,'Text',sprintf('Acc A: %.1f%%',100*accGL), 'FontSize',12);
    kpiL.Layout.Row=2; kpiL.Layout.Column=1;
    kpiR = uilabel(g,'Text',sprintf('Acc B: %.1f%%',100*accGR), 'FontSize',12, 'HorizontalAlignment','right');
    kpiR.Layout.Row=2; kpiR.Layout.Column=2;
    delta = uilabel(g,'Text',sprintf('Δ: %+.1f%%',100*dG), 'FontSize',13,'FontWeight','bold','FontColor',ternColor(dG), 'HorizontalAlignment','center');
    delta.Layout.Row=2; delta.Layout.Column=[1 2];

    % ---- TAB ELLA a sinistra (adattiva) ----
    rowH  = 22; headH = 24; hdrKpiH = 60;
    freeH = max(60, pH - hdrKpiH);
    rowsShown = floor((freeH - headH) / rowH);
    rowsShown = max(3, min(numel(L), rowsShown));
    pixH = headH + rowH * rowsShown;

    tbl = uitable(g, ...
        'Data',        buildTableData(L,accL,accR,dV), ...
        'ColumnName',  {'Classe','A %','B %','Δ %'}, ...
        'ColumnEditable',[false false false false], ...
        'RowName',[], ...
        'FontName','Segoe UI', 'FontSize',12);
    tbl.Layout.Row = 3; 
    tbl.Layout.Column = 1;

    % Stile Δ colorato
    try
        sCenter = uistyle('HorizontalAlignment','center'); 
        addStyle(tbl,sCenter,'column',2:4);
        for i=1:numel(L)
            if ~isnan(dV(i))
                addStyle(tbl, uistyle('FontColor', ternColor(dV(i))), 'cell', [i 4]);
            end
        end
    catch
    end

    % ---- INSIGHTS a destra ----
    boxR = uipanel(g,'BackgroundColor',[1 1 1],'BorderType','none');
    boxR.Layout.Row = 3; boxR.Layout.Column = 2;

    gb = uigridlayout(boxR,[4 1]); 
    gb.RowHeight   = {'fit','fit','fit','fit'}; 
    gb.ColumnWidth = {'1x'}; 
    gb.Padding     = [0 0 0 0]; 
    gb.RowSpacing  = 4;

    [~, gIdx] = sort(dV,'descend','MissingPlacement','last');
    [~, lIdx] = sort(dV,'ascend' ,'MissingPlacement','last');
    topGainTxt = insightList(L, gIdx, dV, +1);
    topLossTxt = insightList(L, lIdx, dV, -1);

    uilabel(gb,'Text','↑ Top guadagni','FontSize',13,'FontWeight','bold','FontColor',[0.16 0.55 0.18]); 
    uilabel(gb,'Text',topGainTxt,'FontSize',12,'FontColor',[0.16 0.55 0.18],'WordWrap','on');  
    uilabel(gb,'Text','↓ Top perdite','FontSize',13,'FontWeight','bold','FontColor',[0.78 0.13 0.15]); 
    uilabel(gb,'Text',topLossTxt,'FontSize',12,'FontColor',[0.78 0.13 0.15],'WordWrap','on');  

    % Fissa altezza della riga 3 del grid in base allo spazio calcolato
    g.RowHeight = {'fit','fit', pixH};
end

%% ===== Utilities locali ==============================================================
function idx = localFindHistoryIndex(H, label)
% Matching coerente con refreshP2History:
%   label = sprintf('%s | %s | acc %s'), dove %s è '%.1f%%' oppure 'n/d' se NaN.
    idx = NaN;
    if isempty(H) || strlength(label)==0, return; end
    target = char(label);
    for k = 1:numel(H)
        accG = localGetFieldOr(H(k),'accGlobal',NaN);
        if isnan(accG), accStr = 'n/d'; else, accStr = sprintf('%.1f%%',100*accG); end
        nameStr = char(string(localGetFieldOr(H(k),'name','(sconosciuto)')));
        timeStr = char(string(localGetFieldOr(H(k),'time','')));
        lab = sprintf('%s | %s | acc %s', nameStr, timeStr, accStr);
        if strcmp(lab, target), idx = k; break; end
    end
end

function v = localGetFieldOr(S,f,def)
    if isfield(S,f), v = S.(f); else, v = def; end
end

function out = localGetWithDefault(v,def)
    if isempty(v), out = def; else, out = v; end
end

function s = localGetDropValue(dd)
    if ~isempty(dd) && all(isvalid(dd))
        s = string(dd(1).Value);
    else
        s = "";
    end
end

function localAlert(fig,msg)
    try uialert(fig,msg,'Confronto'); catch, end
end

function localLog(fig,msg)
    if exist('logP2','file')==2
        try logP2(fig,msg); catch, end
    end
end

function c = ternColor(x)
    if isnan(x) || x==0, c = [0.25 0.25 0.25]; % neutro
    elseif x>0,          c = [0.16 0.55 0.18]; % verde
    else,                c = [0.78 0.13 0.15]; % rosso
    end
end

function s = insightList(labels, idx, dV, signWanted)
    % labels: string array (classi allineate)
    
    maxN  = numel(idx);              % upper bound
    items = strings(maxN,1);         % preallocazione
    n     = 0;                       % contatore effettivi

    for k = 1:maxN
        v = dV(idx(k));

        if signWanted>0 && v<=0, continue; end
        if signWanted<0 && v>=0, continue; end
        if isnan(v), continue; end

        n = n+1;
        items(n) = sprintf('%s (%+.1f%%)', labels(idx(k)), v);
        
        if numel(items)==3, break; end
    end

    if isempty(items)
        s = '—'; 
    else
        s = strjoin(items, ', ');
    end
end

function data = buildTableData(L,accL,accR,dV)
    n = numel(L);
    data = cell(n,4);
    for i=1:n
        data{i,1} = char(L(i));
        data{i,2} = sprintf('%.1f', 100*accL(i));
        data{i,3} = sprintf('%.1f', 100*accR(i));
        if isnan(dV(i))
            data{i,4} = 'n/d'; 
        else
            data{i,4} = sprintf('%+.1f', dV(i));
        end
    end
end
