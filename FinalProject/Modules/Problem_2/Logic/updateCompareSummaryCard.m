function updateCompareSummaryCard(fig, Cl, labelsL, Cr, labelsR, nameL, nameR)
% UPDATECOMPARESUMMARYCARD  Aggiorna la "card" di riepilogo confronto A vs B (UI-only).
% =====================================================================================
% PURPOSE
%   Visualizza un confronto tra due matrici di confusione:
%     - Nomi dei due scenari (A/B)
%     - Accuratezze globali (A, B) e Δ con segno e freccia di trend
%     - Tabella per-classe (Acc_A%, Acc_B%, Δ%)
%     - Top 3 guadagni e perdite per classe
%
% INPUT
%   fig     : handle uifigure principale.
%   Cl      : matrice NxN (numeric) per confronto "A" (left).
%   labelsL : etichette (cellstr/string) per Cl.
%   Cr      : matrice MxM (numeric) per confronto "B" (right).
%   labelsR : etichette (cellstr/string) per Cr.
%   nameL   : nome/descrizione scenario A (char/string).
%   nameR   : nome/descrizione scenario B (char/string).
%
% BEHAVIOR
%   - Allinea le classi sull’intersezione dei label (ordine 'stable').
%   - Calcola accuratezze per classe come diag(C)./sum(C,2) (NaN se riga vuota).
%   - Aggiorna testi, tabella e suggerimenti (top gains/losses).
%   - Tollerante: se i widget non sono presenti -> return silenzioso.
%
% NON-GOALS
%   - Nessun salvataggio stato, nessuna normalizzazione matrici, nessun I/O.
% =====================================================================================

    % --- Resolve controlli della card (tutti obbligatori per il render) --------------
    p    = findobj(fig,'Tag','CompareSummaryPanel');
    lblA = findobj(fig,'Tag','CmpNameA');
    lblB = findobj(fig,'Tag','CmpNameB');
    aA   = findobj(fig,'Tag','CmpAccA');
    aB   = findobj(fig,'Tag','CmpAccB');
    aD   = findobj(fig,'Tag','CmpAccDelta');
    tbl  = findobj(fig,'Tag','CmpTable');
    gns  = findobj(fig,'Tag','CmpTopGains');
    lss  = findobj(fig,'Tag','CmpTopLosses');

    if any([isempty(p), isempty(lblA), isempty(lblB), isempty(aA), isempty(aB), ...
            isempty(aD), isempty(tbl), isempty(gns), isempty(lss)])
        % UI non ancora costruita o tag non coerenti: uscita non bloccante
        return;
    end

    % --- Header nomi scenari ---------------------------------------------------------
    lblA.Text = sprintf('A: %s', strtrim(string(nameL)));
    lblB.Text = sprintf('B: %s', strtrim(string(nameR)));

    % --- Normalizzazione labels e allineamento classi --------------------------------
    Lleft  = cellstr(string(labelsL(:)).');   % row cellstr
    Lright = cellstr(string(labelsR(:)).');   % row cellstr

    % Nota: intersect stable preserva l'ordine del primo argomento
    [L, ia, ib] = intersect(string(Lleft), string(Lright), 'stable');

    if isempty(L)
        % Nessuna classe comune: svuota card con placeholder
        aA.Text='Acc A: n/d'; aB.Text='Acc B: n/d'; aD.Text='Δ: n/d';
        tbl.Data = {};
        gns.Text = '↑ Top guadagni: n/d';
        lss.Text = '↓ Top perdite: n/d';
        return;
    end

    % --- Accuratezze per classe (NaN-safe per righe a zero) --------------------------
    tpL   = diag(Cl);      rowL = sum(Cl, 2);  tpL = tpL(ia); rowL = rowL(ia);
    accL  = nan(size(L));  mL   = rowL > 0;    accL(mL) = tpL(mL) ./ rowL(mL);

    tpR   = diag(Cr);      rowR = sum(Cr, 2);  tpR = tpR(ib); rowR = rowR(ib);
    accR  = nan(size(L));  mR   = rowR > 0;    accR(mR) = tpR(mR) ./ rowR(mR);

    % --- Accuratezze globali e delta -------------------------------------------------
    accGL = sum(diag(Cl)) / max(sum(Cl, 'all'), 1);
    accGR = sum(diag(Cr)) / max(sum(Cr, 'all'), 1);
    dG    = 100 * (accGL - accGR);

    aA.Text = sprintf('Acc A: %.1f%%', 100*accGL);
    aB.Text = sprintf('Acc B: %.1f%%', 100*accGR);
    aD.Text = sprintf('Δ: %s%.1f%% %s', signChar(dG), abs(dG), trendArrow(dG));
    try
        if dG >= 0
            aD.FontColor = [0 0.5 0];
        else
            aD.FontColor = [0.7 0.1 0.1];
        end
    catch
        % ignora se proprietà non disponibile
    end

    % --- Tabella per-classe (A, B, Δ) ------------------------------------------------
    A = round(100*accL, 1);
    B = round(100*accR, 1);
    D = A - B;

    data    = [cellstr(L), num2cell(A), num2cell(B), num2cell(D)];
    tbl.Data = data;

    % Styling Δ: verde per positivo, rosso per negativo (best-effort)
    try
        removeStyle(tbl); % se definito nella tua env, pulisce stili precedenti
    catch
    end
    try
        sPos = uistyle('FontColor',[0 0.5 0]);
        sNeg = uistyle('FontColor',[0.7 0.1 0.1]);
        for r = 1:size(tbl.Data,1)
            if ~isnan(D(r))
                if D(r) > 0
                    addStyle(tbl, sPos, 'cell', [r 4]);
                elseif D(r) < 0
                    addStyle(tbl, sNeg, 'cell', [r 4]);
                end
            end
        end
    catch
        % opzionale/non bloccante
    end

    % --- Top 3 guadagni / perdite ----------------------------------------------------
    [~, ord] = sort(D, 'descend', 'MissingPlacement', 'last');
    gains = ord(D(ord) > 0);
    loses = ord(D(ord) < 0);

    gns.Text = sprintf('↑ Top guadagni: %s', topList(L, D, gains, +1));
    lss.Text = sprintf('↓ Top perdite: %s',  topList(L, D, loses, -1));
end

% ===== Helpers locali (senza dipendenze esterne) =====================================

function s = signChar(x)
% SIGNCHAR  Ritorna '+' per x>=0, '-' altrimenti (usata per il Δ globale).
    if x >= 0, s = '+'; else, s = '-'; end
end

function a = trendArrow(x)
% TRENARROW  Freccia di trend: ▲ per positivo, ▼ per negativo, — per neutro.
    if x > 0
        a = '▲';
    elseif x < 0
        a = '▼';
    else
        a = '—';
    end
end

function t = topList(L, D, idx, ~)
% TOPLIST  Format “NomeClasse (+/-Δ%)” per i top N indici forniti (N<=3).
% INPUT
%   L   : string array/cellstr etichette allineate
%   D   : vettore Δ in punti percentuali (NaN ammessi)
%   idx : indici già filtrati/ordinati per segno desiderato
%   ~   : placeholder non usato (firma compatibile col chiamante)
    if isempty(idx), t = '—'; return; end
    take = min(3, numel(idx)); idx = idx(1:take);
    parts = strings(1, take);
    for k = 1:take
        d = D(idx(k));
        parts(k) = sprintf('%s (%s%.1f%%)', L(idx(k)), iff(d>=0,'+',''), d);
    end
    t = strjoin(parts, ', ');
end

function s = iff(cond, a, ~)
% IFF  Ternario minimale: cond ? a : ''  (usato per il prefisso segno positivo).
    if cond, s = a; else, s = ''; end
end
