function lines = buildCompareSummary(Cl, labelsL, Cr, labelsR, nameL, nameR)
% BUILDCOMPARESUMMARY  Riepilogo confronto tra due matrici di confusione (L vs R).
% =====================================================================================
% PURPOSE
%   Produce un elenco di righe testuali (cell array) che riassumono:
%     - accuratezza globale dei due modelli/matrici
%     - differenze per classe (Δ in punti percentuali)
%
% INPUT
%   Cl, Cr   : matrici NxN (conteggi) "Left" e "Right"
%   labelsL  : 1xN etichette per Cl (cellstr/string/char)
%   labelsR  : 1xN etichette per Cr (cellstr/string/char)
%   nameL    : descrizione/nome sorgente L (string/char, opzionale)
%   nameR    : descrizione/nome sorgente R (string/char, opzionale)
%
% OUTPUT
%   lines    : cell array di char, pronto per essere visualizzato in UI (textarea, ecc.)
%
% BEHAVIOR
%   - Allinea le classi per nome (intersezione "stable"); se non c’è overlap → messaggio.
%   - Accuratezze per classe calcolate come diag(C)./sum(C,2), con NaN per righe vuote.
%   - Formattazione coerente: "n/d" quando non disponibile.
%   - Nessun throw: sempre ritorna almeno una riga significativa.
% =====================================================================================

    % --------- Normalizzazioni di ingresso ------------------------------------------
    labelsL = i_toCellRow(labelsL);
    labelsR = i_toCellRow(labelsR);
    nameL   = i_orDefault(nameL, 'A');
    nameR   = i_orDefault(nameR, 'B');

    % --------- Allineamento classi (per nome) ---------------------------------------
    [L, ia, ib] = intersect(string(labelsL), string(labelsR), 'stable');
    if isempty(L)
        lines = {'Le etichette delle classi non coincidono. Impossibile confrontare.'};
        return;
    end

    % --------- Accuratezze per classe ------------------------------------------------
    % Left
    tpL  = diag(Cl);    tpL  = tpL(ia);
    rowL = sum(Cl,2);   rowL = rowL(ia);
    accL = nan(size(L)); mL = rowL>0; accL(mL) = tpL(mL)./rowL(mL);

    % Right
    tpR  = diag(Cr);    tpR  = tpR(ib);
    rowR = sum(Cr,2);   rowR = rowR(ib);
    accR = nan(size(L)); mR = rowR>0; accR(mR) = tpR(mR)./rowR(mR);

    % --------- Accuratezze globali ---------------------------------------------------
    accGL = sum(diag(Cl)) / max(sum(Cl,'all'), 1);
    accGR = sum(diag(Cr)) / max(sum(Cr,'all'), 1);
    dG    = 100*(accGL - accGR);

    % ---- Preallocazione del vettore di righe ----
    nFixed = 3;                % 3 righe fisse di header
    nVar   = numel(L);         % 1 riga per ogni classe
    lines  = cell(1, nFixed + nVar);

    % --------- Header riepilogo ------------------------------------------------------
    lines{end+1} = sprintf('Confronto:  %s   vs   %s', char(nameL), char(nameR));
    lines{end+1} = sprintf('Accuratezza globale:  %s   vs   %s   →  Δ %s', ...
        i_pctOrNd(accGL), i_pctOrNd(accGR), i_deltaFmt(dG));
    lines{end+1} = '— — —';

    % --------- Dettaglio per classe --------------------------------------------------
    for i = 1:numel(L)
        idx = nFixed + i;   % posizione già preallocata
        aL = 100*accL(i); 
        aR = 100*accR(i);
        if isnan(aL) || isnan(aR)
            lines{idx} = sprintf('%s:  %s  vs  %s', char(L(i)), i_pctOrNd(aL,true), i_pctOrNd(aR,true));
        else
            lines{idx} = sprintf('%s:  %.1f%%  vs  %.1f%%   →  Δ %s', ...
                char(L(i)), aL, aR, i_deltaFmt(aL - aR));
        end
    end
end

% =====================================================================================
% Local helpers
% =====================================================================================
function L = i_toCellRow(labels)
% Converte labels a cell array riga di char, con trim e fallback "Class k".
    if isstring(labels), L = cellstr(labels(:).');
    elseif ischar(labels), L = {labels};
    elseif iscell(labels), L = labels(:).';
    else, L = cellstr(string(labels(:).'));
    end
    for k = 1:numel(L)
        L{k} = strtrim(char(L{k}));
        if isempty(L{k}), L{k} = sprintf('Class %d', k); end
    end
end

function s = i_orDefault(x, def)
% Ritorna x come stringa non vuota, altrimenti default.
    if nargin<2, def = ''; end
    if isempty(x), s = def; else, s = char(string(x)); end
end

function s = i_pctOrNd(x, isPctAlready)
% Formatta percentuali o "n/d" (x può essere NaN). 
% Se isPctAlready=true, x è già in punti percentuali; altrimenti è frazione [0..1].
    if nargin<2, isPctAlready = false; end
    if isnan(x)
        s = 'n/d';
    else
        if ~isPctAlready, x = 100*x; end
        s = sprintf('%.1f%%', x);
    end
end

function s = i_deltaFmt(d)
% Formatta Δ con segno e un decimale; d è sempre in punti percentuali.
    if isnan(d), s = 'n/d'; return; end
    s = sprintf('%+.1f%%', d);
end
