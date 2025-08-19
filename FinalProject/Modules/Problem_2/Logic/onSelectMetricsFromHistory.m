function onSelectMetricsFromHistory(fig)
% Aggiorna la Tab 3 (badge, tabella, barre, report) in base alla voce selezionata.

    H = getappdata(fig,'HistoryP2');
    dd = findobj(fig,'Tag','MetricsHistoryDropdown');
    if isempty(dd) || ~isvalid(dd) || isempty(H), return; end
    pick = string(dd.Value);
    if pick=="-- storico vuoto --", return; end

    % risolvi indice
    idx = localFindHistoryIndex(H, pick);
    if isnan(idx), return; end

    % dati base
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
        acc_i   = nan(size(TP));
        nz      = rowSum>0; acc_i(nz) = TP(nz)./rowSum(nz);
        accG    = sum(diag(C)) / max(sum(C,'all'),1);
    end

    % --- aggiorna UI principale (badge + tabella + barre) ---
    updateMetricsUI(fig, labels, TP, support, acc_i, accG);

    % --- aggiorna il mini-report (card) nella Tab 3 ---
    updateMetricsReportCard(fig, labels, acc_i, accG);
end

%% ===== helpers locali =====
function idx = localFindHistoryIndex(H, label)
    idx = NaN;
    for k = 1:numel(H)
        accG = getfieldOr(H(k),'accGlobal',NaN);
        this = sprintf('%s | %s | acc %.1f%%', H(k).name, H(k).time, 100*accG);
        if strcmp(this, label)
            idx = k; break;
        end
    end
end

function v = getfieldOr(S, fname, def)
    if isfield(S,fname), v = S.(fname); else, v = def; end
end

function updateMetricsReportCard(fig, labels, acc_i, accG)
% Aggiorna le etichette del pannello "Report metriche" in Tab 3.

    p  = findobj(fig,'Tag','MetricsReportPanel');
    gL = findobj(fig,'Tag','RptGlobal');
    bL = findobj(fig,'Tag','RptBest');
    wL = findobj(fig,'Tag','RptWorst');
    tL = findobj(fig,'Tag','RptTip');

    if isempty(p) || isempty(gL) || isempty(bL) || isempty(wL) || isempty(tL)
        return; % pannello non creato (es. vecchia UI)
    end

    % Global
    if isnan(accG)
        gL.Text = 'Accuratezza globale: n/d';
    else
        gL.Text = sprintf('Accuratezza globale: %.1f%%', 100*accG);
    end

    % Best/Worst (ignora NaN)
    vals = 100*acc_i;
    mask = ~isnan(vals);
    if any(mask)
        vals  = vals(mask);
        labs  = labels(mask);
        [bestVal,iBest]   = max(vals);
        [worstVal,iWorst] = min(vals);

        bL.Text           = sprintf('Migliore: %s (%.1f%%)', labs{iBest}, bestVal);
        wL.Text           = sprintf('Peggiore: %s (%.1f%%)', labs{iWorst}, worstVal);

        % Colori: best verde scuro, worst rosso, tip grigio
        try
            bL.FontColor = [0.00 0.50 0.00];
            wL.FontColor = [0.70 0.10 0.10];
            gL.FontColor = [0.00 0.45 0.00];
            tL.FontColor = [0.35 0.35 0.35];
        catch
        end

        % Suggerimento semplice
        if worstVal < 60
            tL.Text = sprintf('Suggerimento: la classe "%s" è critica (<60%%). Valuta più campioni o feature tuning.', labs{iWorst});
        elseif bestVal > 90
            tL.Text = sprintf('Ottimo: la classe "%s" supera il 90%%. Mantieni queste scelte di feature/modello.', labs{iBest});
        else
            tL.Text = 'Osservazione: distribuzione delle accuratezze nella media.';
        end
    else
        bL.Text = 'Migliore: n/d';
        wL.Text = 'Peggiore: n/d';
        tL.Text = 'Nessun campione per il calcolo delle accuratezze per classe.';
    end
end
