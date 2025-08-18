function lines = generateHintsFromMetrics(labels, acc_i, accG)
    % Produce qualche riga di commento smart sulle metriche correnti.
    
    lines = {};
    if isempty(labels) || isempty(acc_i)
        lines = {'Nessuna metrica disponibile.'};
        return;
    end
    
    % global
    if isnan(accG)
        lines{end+1} = 'Accuratezza globale non disponibile.';
    else
        lines{end+1} = sprintf('Accuratezza globale: %.1f%%.', 100*accG);
    end
    
    % classi migliori/peggiori (ignora NaN)
    vals = 100*acc_i;
    mask = ~isnan(vals);
    vals = vals(mask);
    labs = labels(mask);
    
    if ~isempty(vals)
        [bestVal, iBest] = max(vals);
        [worstVal, iWorst] = min(vals);
        lines{end+1} = sprintf('Migliore: %s (%.1f%%).', labs{iBest}, bestVal);
        lines{end+1} = sprintf('Peggiore: %s (%.1f%%).', labs{iWorst}, worstVal);
    
        % suggerimenti semplici
        if worstVal < 60
            lines{end+1} = sprintf('Suggerimento: la classe "%s" è critica; valuta più campioni o revisione feature.', labs{iWorst});
        end
        if bestVal > 90
            lines{end+1} = sprintf('Ottimo: la classe "%s" supera il 90%%.', labs{iBest});
        end
    else
        lines{end+1} = 'Accuratezze per classe non calcolabili (righe vuote?).';
    end
end
