function updateMetricsUI(fig, labels, TP, support, acc_i, accG)
% Aggiorna badge, tabella e grafico barre in Tab3 (solo UI).

    % --- badge accuratezza globale
    hBadge = findobj(fig,'Tag','LabelGlobalAcc');
    if ~isempty(hBadge) && isvalid(hBadge)
        if isnan(accG)
            hBadge.Text = '–';
        else
            hBadge.Text = sprintf('%.1f%%', 100*accG);
        end
    end

    % --- tabella per-classe
    hTbl = findobj(fig,'Tag','TablePerClass');
    if ~isempty(hTbl) && isvalid(hTbl)
        accPct = round(100*acc_i,1);
        % mostra NaN come vuoto
        accDisp = arrayfun(@(x) iff(isnan(x),'',sprintf('%.1f',x)), accPct, 'UniformOutput', false);
        data = [labels(:), num2cell(TP(:)), num2cell(support(:)), accDisp(:)];
        hTbl.Data = data;
        try
            hTbl.ColumnFormat = {'char','numeric','numeric','numeric'};
        catch
        end
    end

    % --- grafico barre (Acc per classe)
    hAx = findobj(fig,'Tag','BarAxes');
    if ~isempty(hAx) && isvalid(hAx)
        cla(hAx,'reset'); hAx.Toolbar.Visible = 'off'; box(hAx,'on');
        vals = 100*acc_i;   % NaN rimane NaN e bar lo mostra vuoto
        bar(hAx, vals);
        ylim(hAx,[0 100]);
        xticks(hAx, 1:numel(labels));
        xticklabels(hAx, labels);
        try
            hAx.XTickLabelRotation = 25;
        catch
        end
        title(hAx, 'Accuratezza per classe (%)');
        xlabel(hAx,'Classe'); ylabel(hAx,'Acc %');
    end
end

function o = iff(cond, a, b)
    if cond, o = a; else, o = b; end
end
