function onSelectMetricsFromHistory(fig)
% ONSELECTMETRICSFROMHISTORY  Aggiorna la Tab 3 in base alla voce di storico selezionata.
% =====================================================================================
% PURPOSE
%   Dalla selezione corrente del dropdown 'MetricsHistoryDropdown' (Tab3), recupera
%   la voce corrispondente in 'HistoryP2' e aggiorna:
%     - Badge accuratezza globale
%     - Tabella per-classe (Classe, TP, Totale, Acc %)
%     - Grafico a barre (Acc per classe %)
%     - Mini-report (pannello "Report metriche")
%
% CONTRACT
%   AppData 'HistoryP2' atteso come array struct con campi:
%     .name, .time (char/string/datetime), .C (NxN), .labels (1xN)
%     .TP, .support, .accPerClass, .accGlobal  (opzionali; se assenti -> calcolo on-the-fly)
%
% ROBUSTEZZA
%   - Se dropdown o storico non sono disponibili: return silenzioso.
%   - Matching item dropdown ↔ storico coerente con refreshP2History (gestione NaN = 'n/d').
% =====================================================================================

    H  = getappdata(fig,'HistoryP2');
    dd = findobj(fig,'Tag','MetricsHistoryDropdown');
    if isempty(dd) || ~isvalid(dd) || isempty(H), return; end

    pick = string(dd.Value);
    if pick == "-- storico vuoto --", return; end

    % --- Risolvi indice della voce selezionata nello storico -------------------------
    idx = localFindHistoryIndex(H, pick);
    if isnan(idx), return; end

    % --- Dati base -------------------------------------------------------------------
    C      = H(idx).C;
    labels = H(idx).labels;

    % --- Metriche: usa quelle salvate se presenti, altrimenti calcola ----------------
    TP       = getfieldOr(H(idx),'TP',[]);
    support  = getfieldOr(H(idx),'support',[]);
    acc_i    = getfieldOr(H(idx),'accPerClass',[]);
    accG     = getfieldOr(H(idx),'accGlobal',NaN);

    if isempty(TP) || isempty(support) || isempty(acc_i) || isnan(accG)
        rowSum  = sum(C,2);
        TP      = diag(C);
        support = rowSum;
        acc_i   = nan(size(TP));
        nz      = rowSum > 0; 
        acc_i(nz) = TP(nz)./rowSum(nz);
        accG    = sum(diag(C)) / max(sum(C,'all'),1);
    end

    % --- Aggiorna UI principale (badge + tabella + barre) ----------------------------
    updateMetricsUI(fig, labels, TP, support, acc_i, accG);

    % --- Aggiorna il mini-report (card) nella Tab 3 ---------------------------------
    updateMetricsReportCard(fig, labels, acc_i, accG);
end

%% ===== helpers locali ===============================================================

function idx = localFindHistoryIndex(H, labelStr)
% LOCALFINDHISTORYINDEX  Risolve l'indice nello storico a partire dalla label del dropdown.
%   La stringa del dropdown è formata come in refreshP2History:
%     sprintf('%s | %s | acc %s', nameStr, timeStr, accStr)
%   dove accStr = '%.1f%%' oppure 'n/d' se accGlobal è NaN.

    idx = NaN;
    target = char(labelStr);

    for k = 1:numel(H)
        accG = getfieldOr(H(k),'accGlobal',NaN);
        if isnan(accG)
            accStr = 'n/d';
        else
            accStr = sprintf('%.1f%%', 100*accG);
        end

        % Nome e tempo robusti (supporta char/string/datetime)
        nameStr = toCharSafe(getfieldOr(H(k),'name','(sconosciuto)'));
        timeRaw = getfieldOr(H(k),'time','');
        if isa(timeRaw,'datetime')
            timeStr = char(timeRaw);
        else
            timeStr = toCharSafe(timeRaw);
        end

        this = sprintf('%s | %s | acc %s', nameStr, timeStr, accStr);
        if strcmp(this, target)
            idx = k; 
            break;
        end
    end
end

function v = getfieldOr(S, fname, def)
% GETFIELDR  Ritorna S.(fname) se esiste, altrimenti def.
    if isfield(S,fname), v = S.(fname); else, v = def; end
end

function s = toCharSafe(x)
% TOCHARSAFE  Converte in char con fallback (string/char/datetime/others).
    if ischar(x)
        s = x;
    elseif isstring(x)
        s = char(x);
    elseif isa(x,'datetime')
        s = char(x);
    else
        s = char(string(x));
    end
end

function updateMetricsReportCard(fig, labels, acc_i, accG)
% UPDATEMETRICSREPORTCARD  Aggiorna le etichette del pannello "Report metriche" (Tab 3).
% =====================================================================================
% INPUT
%   labels : 1xN cellstr/string – etichette per classe
%   acc_i  : 1xN double in [0..1] (NaN ammessi)
%   accG   : double scalare in [0..1] (NaN ammesso)
%
% BEHAVIOR
%   - Popola: RptGlobal, RptBest, RptWorst, RptTip
%   - Ignora gracefully se il pannello non è presente (UI legacy)
% =====================================================================================

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
        labs  = cellstr(string(labs));

        [bestVal,iBest]   = max(vals);
        [worstVal,iWorst] = min(vals);

        bL.Text           = sprintf('Migliore: %s (%.1f%%)', labs{iBest}, bestVal);
        wL.Text           = sprintf('Peggiore: %s (%.1f%%)', labs{iWorst}, worstVal);

        % Colori: best verde scuro, worst rosso, tip grigio (best-effort)
        try
            bL.FontColor = [0.00 0.50 0.00];
            wL.FontColor = [0.70 0.10 0.10];
            gL.FontColor = [0.00 0.45 0.00];
            tL.FontColor = [0.35 0.35 0.35];
        catch
        end

        % Suggerimento minimale
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
