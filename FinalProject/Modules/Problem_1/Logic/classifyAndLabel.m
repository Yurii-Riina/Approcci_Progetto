function classifyAndLabel(fig)
    % Esegue la tua classificazione standard
    classifyCurrentImage(fig);

    % Aggiorna i nomi delle feature in base alla lunghezza dei dati
    tbl = findobj(fig, 'Tag', 'FeatureTable');
    if isempty(tbl) || ~isgraphics(tbl) || isempty(tbl.Data), return; end

    n = size(tbl.Data, 1);
    names = strings(n,1);
    if n >= 1, names(1) = "Compattezza"; end
    if n >= 2, names(2) = "Protrusion ratio"; end
    for k = 3:n
        names(k) = "feat_" + string(k-2);   % nomi generici per le feature extra
    end

    tbl.RowName = cellstr(names);
    % (opzionale) assicura l'intestazione colonna
    if isempty(tbl.ColumnName)
        tbl.ColumnName = {'Valore'}; 
    end
end
