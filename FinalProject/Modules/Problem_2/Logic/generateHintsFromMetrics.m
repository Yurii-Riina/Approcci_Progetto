function lines = generateHintsFromMetrics(labels, acc_i, accG)
% GENERATEHINTSFROMMETRICS  Crea un set di commenti testuali sulle metriche correnti.
% =====================================================================================
% PURPOSE
%   Dato l'insieme delle accuratezze per classe (acc_i) e quella globale (accG),
%   produce un elenco di frasi sintetiche utili per un mini‑report UI.
%
% INPUT
%   labels : 1xN cellstr/string  - etichette delle classi (possono contenere NaN o vuoti)
%   acc_i  : 1xN o Nx1 double    - accuratezza per classe in [0..1] (NaN ammessi)
%   accG   : scalar double       - accuratezza globale in [0..1] (NaN ammesso)
%
% OUTPUT
%   lines  : cell array di righe (char), pronte per essere mostrate in UI.
%
% BEHAVIOR
%   - Gestione difensiva di input incoerenti (dimensioni, tipi, NaN).
%   - Messaggi coerenti e localizzati (IT).
%   - Non solleva errori: ritorna sempre almeno una riga.
% =====================================================================================

    % --- Inizializzazione output -----------------------------------------------------
    lines = {};

    % --- Normalizzazione input -------------------------------------------------------
    % labels → cellstr riga
    labels = i_toCellRow(labels);

    % acc_i → colonna double
    if isempty(acc_i)
        lines = {'Nessuna metrica disponibile.'};
        return;
    end
    acc_i = double(acc_i(:));

    % Allinea lunghezze (taglia o pad labels)
    N = numel(acc_i);
    labels = i_fitLabels(labels, N);

    % --- Accuratezza globale ---------------------------------------------------------
    if isnan(accG)
        lines{end+1} = 'Accuratezza globale non disponibile.'; 
    else
        lines{end+1} = sprintf('Accuratezza globale: %.1f%%.', 100*accG); 
    end

    % --- Accuratezze per classe (ignora NaN) -----------------------------------------
    vals = 100 * acc_i;                 % porta in percentuale
    mask = isfinite(vals);              % true se non NaN/Inf
    if any(mask)
        valsV = vals(mask);
        labsV = labels(mask);

        % Best / Worst
        [bestVal, iBest]   = max(valsV);
        [worstVal, iWorst] = min(valsV);

        lines{end+1} = sprintf('Migliore: %s (%.1f%%).', labsV{iBest}, bestVal);  
        lines{end+1} = sprintf('Peggiore: %s (%.1f%%).', labsV{iWorst}, worstVal);

        % Suggerimenti semplici (soglie euristiche)
        if worstVal < 60
            lines{end+1} = sprintf('Suggerimento: la classe "%s" è critica (<60%%); valuta più campioni o revisione feature.', labsV{iWorst}); 
        end
        if bestVal > 90
            lines{end+1} = sprintf('Ottimo: la classe "%s" supera il 90%%.', labsV{iBest}); 
        end
    else
        lines{end+1} = 'Accuratezze per classe non calcolabili (righe vuote o dati insufficienti).'; 
    end
end

% ===== Helpers locali ================================================================

function L = i_toCellRow(labels)
% Converte labels a cell array riga di char, con trim e fallback.
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

function L = i_fitLabels(L, N)
% Adegua il numero di etichette a N (taglia o pad con 'Class k').
    n = numel(L);
    if n >= N
        L = L(1:N);
    else
        for k = n+1:N
            L{end+1} = sprintf('Class %d', k); %#ok<AGROW>
        end
    end
end
