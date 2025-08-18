function ax = getSingleAxesByTag(fig, tag)
% Ritorna un SOLO uiaxes con Tag=tag (se ce ne sono più di uno elimina i duplicati).
    axAll = findall(fig,'Type','uiaxes','-and','Tag',tag);
    if isempty(axAll)
        ax = [];
        return;
    end
    if numel(axAll) > 1
        delete(axAll(2:end));  % tieni il primo
    end
    ax = axAll(1);
end
