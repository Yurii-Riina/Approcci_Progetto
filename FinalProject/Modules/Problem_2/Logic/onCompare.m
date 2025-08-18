function onCompare(fig)
% Confronto (Tab 4) con due dropdown:
%  - LEFT  = CompareDropLeft  (se '--' usa la matrice corrente)
%  - RIGHT = CompareDropRight (obbligatorio: voce dallo storico)
% Mostra due heatmap affiancate e aggiorna il riepilogo numerico in basso.

    %% --- recupera storico ---
    H = getappdata(fig,'HistoryP2');

    %% --- dropdown sinistra/destra ---
    ddL = findobj(fig,'Tag','CompareDropLeft');
    ddR = findobj(fig,'Tag','CompareDropRight');

    if isempty(ddR) || ~isvalid(ddR)
        logP2(fig,'[P2] onCompare: dropdown destro mancante.');
        try uialert(fig,'Dropdown destro non trovato.','Confronto'); catch, end
        return;
    end

    pickR = string(ddR.Value);
    if isempty(H) || pickR=="-- storico vuoto --"
        try uialert(fig,'Storico vuoto o selezione destra non valida.','Confronto'); catch, end
        logP2(fig,'[P2] onCompare: storico vuoto o pick destro non valido.');
        return;
    end

    % RIGHT dallo storico (obbligatorio)
    [idxR, nameR] = localResolvePick(H, pickR);
    if isnan(idxR)
        try uialert(fig,'Elemento destro non trovato nello storico.','Confronto'); catch, end
        logP2(fig,'[P2] onCompare: selezione destra non risolta.');
        return;
    end
    Cr      = H(idxR).C;
    labelsR = H(idxR).labels;

    % LEFT: se non scelto, usa "corrente"; altrimenti storico
    Cl = []; labelsL = []; nameL = '';
    useCurrent = true;
    if ~isempty(ddL) && isvalid(ddL)
        pickL = string(ddL.Value);
        if ~isempty(H) && pickL~="-- storico vuoto --"
            [idxL, nameL] = localResolvePick(H, pickL);
            if ~isnan(idxL)
                Cl      = H(idxL).C;
                labelsL = H(idxL).labels;
                useCurrent = false;
            end
        end
    end
    if useCurrent
        Cl      = getappdata(fig,'CurrentConfMat');
        labelsL = getappdata(fig,'CurrentLabels');
        nameL   = getappdata(fig,'CurrentSourceName');
        if isempty(nameL), nameL = 'corrente'; end
        if isempty(Cl)
            try uialert(fig,'Matrice sinistra assente (corrente non caricata).','Confronto'); catch, end
            logP2(fig,'[P2] onCompare: matrice corrente assente.');
            return;
        end
    end

    %% --- opzioni visuali correnti (coerenza con Tab 2) ---
    opts = getappdata(fig,'CurrentOpts');
    if isempty(opts)
        opts = struct('normalizeRows',false,'showCounts',true,'showPerc',false, ...
                      'cmap','parula','highlightDiag',true);
    end

    %% --- trova AXES di confronto (nuovi -> fallback vecchi) ---
    [axL, axR] = localGetCompareAxes(fig);
    if isempty(axL) || isempty(axR)
        logP2(fig,'[P2] onCompare: axes di confronto non trovati.');
        try uialert(fig,'Axes di confronto non trovati.','Confronto'); catch, end
        return;
    end

    % reset hard
    cla(axL,'reset'); cla(axR,'reset');
    axL.CLimMode = 'auto'; axR.CLimMode = 'auto';

    %% --- plot heatmap LEFT/RIGHT ---
    plotConfusionMatrix(axL, Cl, labelsL, opts);
    plotConfusionMatrix(axR, Cr, labelsR, opts);

    % titoli coerenti con "normalizza righe"
    base = 'Confusion Matrix';
    if isfield(opts,'normalizeRows') && opts.normalizeRows
        base = 'Confusion Matrix (rows %)';
    end
    title(axL, sprintf('%s — %s', base, strrep(nameL,'_','\_')));
    title(axR, sprintf('%s — %s', base, strrep(nameR,'_','\_')));

    % scala colore comune per confronto onesto
    clim = [ min(axL.CLim(1), axR.CLim(1)), max(axL.CLim(2), axR.CLim(2)) ];
    axL.CLim = clim;  axR.CLim = clim;

    %% --- riepilogo numerico nel box in basso ---
    box = findobj(fig,'Tag','CompareSummaryBox');
    if ~isempty(box) && isvalid(box)
        try
            lines = buildCompareSummary(Cl, labelsL, Cr, labelsR, nameL, nameR);
        catch
            % se non hai ancora messo buildCompareSummary.m, mostra info minime
            accGL = sum(diag(Cl))/max(sum(Cl,'all'),1);
            accGR = sum(diag(Cr))/max(sum(Cr,'all'),1);
            lines = {
                sprintf('Confronto: %s  vs  %s', nameL, nameR)
                sprintf('Accuratezza globale: %.1f%%  vs  %.1f%%   →  Δ %.1f%%', ...
                        100*accGL, 100*accGR, 100*(accGL-accGR))
            };
        end
        box.Value = lines;
    end

    drawnow;
    logP2(fig, sprintf('[P2] Confronto eseguito: LEFT=%s, RIGHT=%s', nameL, nameR));
end

%% ===== helpers locali =====
function [axL, axR] = localGetCompareAxes(fig)
    % Nuovi tag (Tab Confronto compattata)
    axL = findobj(fig,'Tag','CompareAxesLeft');
    axR = findobj(fig,'Tag','CompareAxesRight');
    if ~isempty(axL) && ~isempty(axR) && isvalid(axL) && isvalid(axR)
        axL = axL(1); axR = axR(1); return;
    end
    % Fallback ai "BIG" (versione precedente)
    axL = findobj(fig,'Tag','CompareAxesLeftBig');
    axR = findobj(fig,'Tag','CompareAxesRightBig');
    if ~isempty(axL) && ~isempty(axR) && isvalid(axL) && isvalid(axR)
        axL = axL(1); axR = axR(1); return;
    end
    % Se non trovati, restituisci vuoti
    axL = []; axR = [];
end

function [idx, name] = localResolvePick(H, pick)
    idx = NaN; name = '';
    for k = 1:numel(H)
        accG = localGetFieldOr(H(k),'accGlobal',NaN);
        lab  = sprintf('%s | %s | acc %.1f%%', H(k).name, H(k).time, 100*accG);
        if strcmp(lab, pick)
            idx = k; name = H(k).name; return;
        end
    end
end

function v = localGetFieldOr(S, fname, def)
    if isfield(S,fname), v = S.(fname); else, v = def; end
end
