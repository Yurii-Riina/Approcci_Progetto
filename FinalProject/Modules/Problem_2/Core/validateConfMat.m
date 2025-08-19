function S = validateConfMat(C, labels)
% VALIDATECONFMAT  Validazione difensiva di una matrice di confusione NxN.
% =====================================================================================
% PURPOSE
%   Verifica che C sia una matrice di confusione valida (quadrata, numerica, finita,
%   non negativa) e che le etichette siano coerenti. Restituisce un esito booleano,
%   un messaggio descrittivo e metadati utili all’orchestrazione (dimensioni, righe
%   nulle, totale campioni, ecc.).
%
% USAGE
%   S = validateConfMat(C, labels)
%
% INPUT
%   C       : matrice NxN (numeric, non negativa). Può essere double/single/int/logical.
%   labels  : (opzionale) array di etichette di lunghezza N. Accetta:
%             - cell array di char
%             - string array
%             - []  -> verranno autogenerate come 'Class 1' ... 'Class N'
%
% OUTPUT
%   S.ok    : true/false esito validazione.
%   S.msg   : stringa esplicativa (vuota se ok=true).
%   S.info  : struct con metadati (stabile + estendibile):
%             .N           : dimensione (N)
%             .zeroRows    : indici di righe con somma zero (1xK)
%             .total       : somma di tutti gli elementi (scalare)
%             .rowSums     : somma per riga (Nx1)
%             .colSums     : somma per colonna (1xN)
%             .labels      : etichette normalizzate (1xN, cellstr)
%
% DESIGN NOTES
%   - Early-return per fallimenti veloci.
%   - Non effettua normalizzazioni/rounding: la natura intera è facoltativa.
%   - Non modifica C; normalizza solo le etichette in cellstr per coerenza a valle.
%   - Aggiunte in S.info sono backward-compatible (callers esistenti non si rompono).
%
% =====================================================================================

    %=== Init esito di default (fail-closed) ==========================================
    S = struct('ok', false, 'msg', '', 'info', struct());

    %=== Forma e tipo =================================================================
    if isempty(C) || ~ismatrix(C)
        S.msg = 'Matrice vuota o non bidimensionale.'; return;
    end
    if ~isnumeric(C) && ~islogical(C)
        S.msg = 'La matrice deve essere numerica (o logical).'; return;
    end

    % Per robustezza computazionale forziamo double “view” senza alterare C a valle
    % (cast locale per i soli controlli numerici; non restituiamo C modificata).
    Cnum = double(C);

    %=== Quadraticità =================================================================
    [r, c] = size(Cnum);
    if r ~= c
        S.msg = sprintf('La matrice deve essere quadrata (NxN). Trovato %dx%d.', r, c);
        return;
    end

    %=== Valori ammessi ================================================================
    % Finitezza + non negatività
    if ~all(isfinite(Cnum), 'all')
        S.msg = 'La matrice contiene NaN o Inf.'; return;
    end
    if any(Cnum(:) < 0)
        S.msg = 'Valori negativi non ammessi.'; return;
    end

    %=== Etichette ====================================================================
    % Normalizzazione: [] -> autogen; string -> cellstr; enforce lunghezza N
    if nargin < 2 || isempty(labels)
        labels = arrayfun(@(k) sprintf('Class %d', k), 1:r, 'UniformOutput', false);
    elseif isstring(labels)
        labels = cellstr(labels(:).'); % row cellstr
    elseif ischar(labels)
        % singola stringa non valida: deve essere 1xN; forziamo a cell array 1x1->fail size
        labels = {labels};
    elseif iscell(labels)
        % ok
    else
        S.msg = 'Formato labels non supportato (attesi cellstr/string).'; return;
    end

    if numel(labels) ~= r
        S.msg = sprintf('labels deve avere %d elementi.', r); return;
    end

    % Ensuring row-vector cellstr
    labels = labels(:).';
    % Sanitizzazione leggera: trim spazi; sostituisce vuoti con etichetta di fallback
    for k = 1:numel(labels)
        if isstring(labels{k}), labels{k} = char(labels{k}); end
        if ~ischar(labels{k}), labels{k} = char(string(labels{k})); end
        lbl = strtrim(labels{k});
        if isempty(lbl)
            labels{k} = sprintf('Class %d', k);
        else
            labels{k} = lbl;
        end
    end

    %=== Metadati utili ===============================================================
    rowSums = sum(Cnum, 2);
    colSums = sum(Cnum, 1);

    %=== Tutto ok ======================================================================
    S.ok = true;
    S.info.N        = r;
    S.info.zeroRows = find(rowSums == 0).';
    S.info.total    = sum(Cnum, 'all');
    S.info.rowSums  = rowSums;
    S.info.colSums  = colSums;
    S.info.labels   = labels;

end
