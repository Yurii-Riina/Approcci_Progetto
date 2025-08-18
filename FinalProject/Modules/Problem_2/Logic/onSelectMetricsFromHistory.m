function onSelectMetricsFromHistory(fig)
% Aggiorna la Tab 3 (badge, tabella, barre, note) in base alla voce selezionata.
    
    H = getappdata(fig,'HistoryP2');
    dd = findobj(fig,'Tag','MetricsHistoryDropdown');
    if isempty(dd) || ~isvalid(dd) || isempty(H), return; end
    pick = string(dd.Value);
    if pick=="-- storico vuoto --", return; end
    
    % risolvi indice
    idx = localFindHistoryIndex(H, pick);
    if isnan(idx), return; end
    
    % dati
    C      = H(idx).C;
    labels = H(idx).labels;
    
    % metriche: usa quelle salvate se presenti, altrimenti calcola
    TP       = getfieldOr(H(idx),'TP',[]);
    support  = getfieldOr(H(idx),'support',[]);
    acc_i    = getfieldOr(H(idx),'accPerClass',[]);
    accG     = getfieldOr(H(idx),'accGlobal',NaN);
    
    if isempty(TP) || isempty(support) || isempty(acc_i) || isnan(accG)
        rowSum  = sum(C,2);
        TP      = diag(C);
        support = rowSum;
        acc_i   = zeros(size(TP));
        nz = rowSum>0; acc_i(~nz) = NaN; acc_i(nz) = TP(nz)./rowSum(nz);
        accG = sum(diag(C)) / max(sum(C,'all'),1);
    end
    
    % aggiorna UI
    updateMetricsUI(fig, labels, TP, support, acc_i, accG);
    
    % note/suggerimenti
    txt = findobj(fig,'Tag','MetricsNotesBox');
    if ~isempty(txt) && isvalid(txt)
        if exist('generateHintsFromMetrics','file')==2
            notes = generateHintsFromMetrics(labels, acc_i, accG);
        else
            notes = defaultHints(labels, acc_i, accG);
        end
        txt.Value = notes;
    end
end

function idx = localFindHistoryIndex(H, label)
    idx = NaN;
    for k = 1:numel(H)
        accG = getfieldOr(H(k),'accGlobal',NaN);
        this = sprintf('%s | %s | acc %.1f%%', H(k).name, H(k).time, 100*accG);
        if strcmp(this, label)
            idx = k;
            break;
        end
    end
end

function v = getfieldOr(S, fname, def)
    if isfield(S,fname)
        v = S.(fname); 
    else
        v = def; 
    end
end

function lines = defaultHints(labels, acc_i, accG)
    lines = {sprintf('Accuratezza globale: %.1f%%', 100*accG), '— — —'};
    thrLow = 0.60; thrHigh = 0.90;
    for i=1:numel(labels)
        a = acc_i(i);
        if isnan(a)
            lines{end+1} = sprintf('%s: n/d (nessun campione).', labels{i}); 
        continue; 
        end
        if a < thrLow
            lines{end+1} = sprintf('%s: %.1f%% — molto bassa, verifica dataset o confusione con classi vicine.', labels{i}, 100*a);
        elseif a > thrHigh
            lines{end+1} = sprintf('%s: %.1f%% — ottima.', labels{i}, 100*a);
        else
            lines{end+1} = sprintf('%s: %.1f%% — nella media.', labels{i}, 100*a);
        end
    end
end
