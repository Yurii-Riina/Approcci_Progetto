function ax = getSingleAxesByTag(fig, tag)
% GETSINGLEAXESBYTAG  Recupera un SOLO uiaxes con Tag specifico.
% =====================================================================================
% PURPOSE
%   - Ricerca all’interno di una figura un axes con Tag=tag.
%   - Se non esiste → restituisce [].
%   - Se esistono più axes con lo stesso Tag → mantiene solo il primo valido ed elimina
%     tutti i duplicati per garantire unicità.
%
% INPUT
%   fig : handle figura (uifigure)
%   tag : string/char, Tag da ricercare
%
% OUTPUT
%   ax  : handle uiaxes unico, oppure [] se assente
% =====================================================================================

    % Trova tutti gli uiaxes col tag richiesto
    axAll = findall(fig,'Type','uiaxes','-and','Tag',tag);

    if isempty(axAll)
        ax = [];
        return;
    end

    % Se più di uno → tieni il primo valido, elimina i restanti
    if numel(axAll) > 1
        mainAx = axAll(1);
        for k = 2:numel(axAll)
            if isvalid(axAll(k))
                try delete(axAll(k)); catch, end
            end
        end
        ax = mainAx;
    else
        ax = axAll(1);
    end

    % Sanity: riafferma il tag sull’axes mantenuto
    if isvalid(ax)
        ax.Tag = tag;
    end
end
