function lines = buildCompareSummary(Cl, labelsL, Cr, labelsR, nameL, nameR)
% Riepilogo confronto tra due matrici: globale e per classe.

lines = {};

% allinea le classi per nome (intersezione)
[L, ia, ib] = intersect(string(labelsL), string(labelsR),'stable');
if isempty(L)
    lines = {'Le etichette delle classi non coincidono. Impossibile confrontare.'};
    return;
end

% per-classe
tpL = diag(Cl);   tpL = tpL(ia);
rowL = sum(Cl,2); rowL = rowL(ia);
accL = nan(size(L)); mL = rowL>0; accL(mL) = tpL(mL)./rowL(mL);

tpR = diag(Cr);   tpR = tpR(ib);
rowR = sum(Cr,2); rowR = rowR(ib);
accR = nan(size(L)); mR = rowR>0; accR(mR) = tpR(mR)./rowR(mR);

% globale
accGL = sum(diag(Cl))/max(sum(Cl,'all'),1);
accGR = sum(diag(Cr))/max(sum(Cr,'all'),1);

lines{end+1} = sprintf('Confronto:  %s   vs   %s', nameL, nameR);
lines{end+1} = sprintf('Accuratezza globale:  %.1f%%   vs   %.1f%%   →  Δ %.1f%%', ...
    100*accGL, 100*accGR, 100*(accGL-accGR));
lines{end+1} = '— — —';

for i = 1:numel(L)
    aL = 100*accL(i); aR = 100*accR(i);
    if isnan(aL) || isnan(aR)
        lines{end+1} = sprintf('%s:  %s  vs  %s', L(i), dispNaN(aL), dispNaN(aR));
    else
        lines{end+1} = sprintf('%s:  %.1f%%  vs  %.1f%%   →  Δ %.1f%%', ...
            L(i), aL, aR, aL-aR);
    end
end
end

function s = dispNaN(x)
if isnan(x), s = 'n/d'; else, s = sprintf('%.1f%%', x); end
end
