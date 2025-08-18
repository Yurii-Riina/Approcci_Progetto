function updateMetricsUI(fig, labels, TP, support, acc_i, accG)
% Aggiorna badge, tabella e grafico barre in Tab3 (solo UI).

    %% --- Badge accuratezza globale
    hBadge = findobj(fig,'Tag','LabelGlobalAcc');
    if ~isempty(hBadge) && isvalid(hBadge)
        if isnan(accG)
            hBadge.Text = '–';
        else
            hBadge.Text = sprintf('%.1f%%', 100*accG);
        end
    end

    %% --- Tabella per-classe
    hTbl = findobj(fig,'Tag','TablePerClass');
    if ~isempty(hTbl) && isvalid(hTbl)
        % intestazioni per esteso
        hTbl.ColumnName = {'Classe','True Positives','Totale','Accuratezza %'};

        % dati (Acc in % con 1 decimale; NaN mostrato vuoto)
        accPct  = round(100*acc_i,1);
        accDisp = arrayfun(@(x) iff(isnan(x),'',sprintf('%.1f',x)), accPct, 'UniformOutput', false);

        data = [labels(:), num2cell(TP(:)), num2cell(support(:)), accDisp(:)];
        hTbl.Data = data;

        % formati colonna (dove possibile)
        try
            hTbl.ColumnFormat = {'char','numeric','numeric','numeric'};
        catch
        end

        % centratura celle su tutte le colonne
        try
            sCenter = uistyle('HorizontalAlignment','center');
            addStyle(hTbl, sCenter, 'column', 1:size(hTbl.Data,2));
        catch
            % se uistyle non disponibile, si può ignorare
        end

        % non editabile
        try hTbl.ColumnEditable = [false false false false]; catch, end
    end

    % --- grafico barre (Acc per classe)
    hAx = getappdata(fig,'BarAxesHandle');
    if isempty(hAx) || ~isvalid(hAx)
        % fallback se non hai ancora messo l'appdata
        hAx = findobj(fig,'Type','uiaxes','-and','Tag','BarAxes');
        if isempty(hAx), return; end
        hAx = hAx(1);
    end
    
    % NON usare 'reset' o perdi il Tag!
    cla(hAx);                  % <- basta così
    hAx.Toolbar.Visible = 'off';
    box(hAx,'on');
    
    vals = 100*acc_i(:);       % vettore colonna
    labs = cellstr(labels(:)); % etichette sicure
    
    bar(hAx, vals, 'BarWidth',0.8);
    
    % Y fisso 0..100 per evitare scale strane 0..1
    hAx.YLimMode = 'manual';
    hAx.YLim     = [0 100];
    hAx.YTick    = 0:10:100;
    
    xticks(hAx, 1:numel(labs));
    xticklabels(hAx, labs);
    try, hAx.XTickLabelRotation = 25; end
    
    title(hAx, 'Accuratezza per classe (%)');
    xlabel(hAx,'Classe'); ylabel(hAx,'Acc %');
    
    drawnow limitrate;
end

function o = iff(cond, a, b)
    if cond, o = a; else, o = b; end
end
