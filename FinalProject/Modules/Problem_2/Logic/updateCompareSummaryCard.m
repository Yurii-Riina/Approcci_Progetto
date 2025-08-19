function updateCompareSummaryCard(fig, Cl, labelsL, Cr, labelsR, nameL, nameR)

    p   = findobj(fig,'Tag','CompareSummaryPanel');
    lblA= findobj(fig,'Tag','CmpNameA');
    lblB= findobj(fig,'Tag','CmpNameB');
    aA  = findobj(fig,'Tag','CmpAccA');
    aB  = findobj(fig,'Tag','CmpAccB');
    aD  = findobj(fig,'Tag','CmpAccDelta');
    tbl = findobj(fig,'Tag','CmpTable');
    gns = findobj(fig,'Tag','CmpTopGains');
    lss = findobj(fig,'Tag','CmpTopLosses');
    if any([isempty(p) isempty(lblA) isempty(lblB) isempty(aA) isempty(aB) isempty(aD) isempty(tbl) isempty(gns) isempty(lss)])
        return;
    end

    lblA.Text = sprintf('A: %s', nameL);
    lblB.Text = sprintf('B: %s', nameR);

    % allineamento classi
    [L, ia, ib] = intersect(string(labelsL), string(labelsR),'stable');
    if isempty(L)
        aA.Text='Acc A: n/d'; aB.Text='Acc B: n/d'; aD.Text='Δ: n/d';
        tbl.Data = {};
        gns.Text = '↑ Top guadagni: n/d';
        lss.Text = '↓ Top perdite: n/d';
        return;
    end

    % acc per classe
    tpL = diag(Cl); rowL = sum(Cl,2); tpL=tpL(ia); rowL=rowL(ia);
    accL = nan(size(L)); mL = rowL>0; accL(mL)=tpL(mL)./rowL(mL);

    tpR = diag(Cr); rowR = sum(Cr,2); tpR=tpR(ib); rowR=rowR(ib);
    accR = nan(size(L)); mR = rowR>0; accR(mR)=tpR(mR)./rowR(mR);

    % globali
    accGL = sum(diag(Cl))/max(sum(Cl,'all'),1);
    accGR = sum(diag(Cr))/max(sum(Cr,'all'),1);
    dG    = 100*(accGL-accGR);

    aA.Text = sprintf('Acc A: %.1f%%', 100*accGL);
    aB.Text = sprintf('Acc B: %.1f%%', 100*accGR);
    aD.Text = sprintf('Δ: %s%.1f%% %s', signChar(dG), abs(dG), trendArrow(dG));
    try
        if dG>=0, aD.FontColor=[0 0.5 0]; else, aD.FontColor=[0.7 0.1 0.1]; end
    catch
    end

    % tabella per classe
    A = round(100*accL,1); B = round(100*accR,1); D = A - B;
    data = [cellstr(L) num2cell(A) num2cell(B) num2cell(D)];
    tbl.Data = data;
    try
        % style Δ: verde positivo, rosso negativo
        removeStyle(tbl); % pulisci stili precedenti, se definito in tua env
    catch
    end
    try
        sPos = uistyle('FontColor',[0 0.5 0]); sNeg = uistyle('FontColor',[0.7 0.1 0.1]);
        for r=1:size(tbl.Data,1)
            if ~isnan(D(r))
                if D(r) > 0, addStyle(tbl,sPos,'cell',[r 4]);
                elseif D(r) < 0, addStyle(tbl,sNeg,'cell',[r 4]);
                end
            end
        end
    catch
    end

    % top 3 guadagni / perdite
    [~, ord] = sort(D,'descend','MissingPlacement','last');
    gains = ord(D(ord) > 0);
    loses = ord(D(ord) < 0);
    gns.Text = sprintf('↑ Top guadagni: %s', topList(L, D, gains, +1));
    lss.Text = sprintf('↓ Top perdite: %s', topList(L, D, loses, -1));
end

function s = signChar(x), if x>=0, s='+'; else, s='-'; end, end
function a = trendArrow(x), if x>0, a='▲'; elseif x<0, a='▼'; else, a='—'; end, end
function t = topList(L, D, idx, ~)
    if isempty(idx), t='—'; return; end
    take = min(3, numel(idx)); idx = idx(1:take);
    parts = strings(1,take);
    for k=1:take
        d = D(idx(k));
        parts(k) = sprintf('%s (%s%.1f%%)', L(idx(k)), iff(d>=0,'+', ''), d);
    end
    t = strjoin(parts, ', ');
end
function s = iff(cond,a,~), if cond, s=a; else, s=''; end, end
