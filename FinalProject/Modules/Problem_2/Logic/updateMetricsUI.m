function updateMetricsUI(fig, labels, TP, support, acc_i, accG)
% UPDATEMETRICSUI  Aggiorna badge, tabella e grafico barre in Tab3 (UI-only).
% =====================================================================================
% PURPOSE
%   Effettua il *render* dei risultati di metrica per-classe e globale nella
%   sezione "📈 Metriche" della UI:
%     - Badge Accuratezza Globale
%     - Tabella per-classe (Classe, TP, Totale, Acc %)
%     - Grafico a barre (Accuratezza per classe %)
%
% CONTRACT (Input)
%   fig     : handle della uifigure principale.
%   labels  : 1xN cellstr/string – etichette classe (verranno forzate a cellstr,row).
%   TP      : 1xN o Nx1 numerico – True Positives per classe.
%   support : 1xN o Nx1 numerico – Totale campioni per classe.
%   acc_i   : 1xN o Nx1 numerico – accuratezza per classe in [0..1] (non %).
%   accG    : scalare numerico – accuratezza globale in [0..1] (non %). Può essere NaN.
%
% BEHAVIOR
%   - Non effettua calcoli; si limita a formattare e proiettare i dati su UI.
%   - Tollerante: se i controlli non esistono o gli input sono incoerenti, registra
%     un warning e *ritorna* senza interrompere l’app.
%
% SIDE EFFECTS
%   - Aggiorna widget identificati dai Tag: 'LabelGlobalAcc', 'TablePerClass', 'BarAxes'.
%
% NON‑GOALS
%   - Nessuna normalizzazione, nessuna ricomputazione di metriche.
%   - Nessun salvataggio di stato (History/AppData) qui dentro.
% =====================================================================================

    % -------- Normalizzazione leggera input (difensivo, non intrusivo) ---------------
    try
        labels  = cellstr(labels(:).');         % row cellstr
        TP      = TP(:).';                       % row
        support = support(:).';                  % row
        acc_i   = acc_i(:).';                    % row
    catch
        warning('[P2][updateMetricsUI] Formato input non valido o non coerente. Abort UI update.');
        return;
    end

    % Allineamento lunghezze (fail-closed per coerenza UI)
    n = numel(labels);
    if any([numel(TP), numel(support), numel(acc_i)] ~= n)
        warning('[P2][updateMetricsUI] Dimensioni incoerenti: labels=%d, TP=%d, support=%d, acc_i=%d. Nessun aggiornamento eseguito.', ...
            n, numel(TP), numel(support), numel(acc_i));
        return;
    end

    %% --- Badge accuratezza globale ---------------------------------------------------
    hBadge = findobj(fig,'Tag','LabelGlobalAcc');
    if ~isempty(hBadge) && isvalid(hBadge)
        if isnan(accG)
            hBadge.Text = '–';
        else
            hBadge.Text = sprintf('%.1f%%', 100*accG);
        end
    end

    %% --- Tabella per-classe ----------------------------------------------------------
    hTbl = findobj(fig,'Tag','TablePerClass');
    if ~isempty(hTbl) && isvalid(hTbl)
        % Intestazioni verbose per chiarezza
        hTbl.ColumnName = {'Classe','True Positives','Totale','Accuratezza %'};

        % Accuratezze in percentuale con 1 decimale (NaN -> stringa vuota)
        accPct  = round(100*acc_i, 1);
        accDisp = cell(size(accPct));                  % prealloc
        for k = 1:numel(accPct)
            if isnan(accPct(k)), accDisp{k} = '';
            else,               accDisp{k} = sprintf('%.1f', accPct(k));
            end
        end

        % Dati riga: tipo coerente con uITable (mix cell/num/char ok)
        data = [labels(:), num2cell(TP(:)), num2cell(support(:)), accDisp(:)];
        hTbl.Data = data;

        % ColumnFormat (best-effort: non essenziale alla sola visualizzazione)
        try
            hTbl.ColumnFormat = {'char','numeric','numeric','numeric'};
        catch
        end

        % Centratura celle (tollerante a release prive di uistyle/addStyle)
        try
            sCenter = uistyle('HorizontalAlignment','center');
            addStyle(hTbl, sCenter, 'column', 1:size(hTbl.Data,2));
        catch
            % opzionale: ignorare su versioni che non supportano uistyle
        end

        % Rendi non editabile per tutte le colonne (se supportato)
        try hTbl.ColumnEditable = [false false false false]; catch, end
    end

    %% --- Grafico barre (Acc per classe) ---------------------------------------------
    % Recupera axes da AppData (primario) o per Tag (fallback)
    hAx = getappdata(fig,'BarAxesHandle');
    if isempty(hAx) || ~isvalid(hAx)
        hAx = findobj(fig,'Type','uiaxes','-and','Tag','BarAxes');
        if isempty(hAx), return; end
        hAx = hAx(1);
    end

    % Importante: NON usare 'cla(hAx,"reset")' per non perdere Tag/Style
    cla(hAx);
    hAx.Toolbar.Visible = 'off';
    box(hAx,'on');

    vals = 100*acc_i(:);       % colonna in percentuale
    labs = cellstr(labels(:)); % etichette sicure

    bar(hAx, vals, 'BarWidth', 0.8);

    % Y fisso 0..100 per coerenza visiva
    hAx.YLimMode = 'manual';
    hAx.YLim     = [0 100];
    hAx.YTick    = 0:10:100;

    xticks(hAx, 1:numel(labs));
    xticklabels(hAx, labs);
end