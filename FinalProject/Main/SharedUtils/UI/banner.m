function banner(parent, message)
% BANNER  Inserisce un piccolo banner informativo nella parte alta del container.
%
% Sintassi
%   banner(parent, message)
%
% Input
%   parent  : handle al container (uifigure / uipanel / grid cell) che ospita il banner
%   message : testo da visualizzare accanto all’icona informativa "ℹ️"
%
% Descrizione
%   Crea una uilabel con stile discreto, posizionata in alto (y≈550) per
%   fungere da messaggio informativo/contestuale nella pagina corrente.
%
% Note
%   - La posizione è assoluta (pixel) e pensata per finestre ~900x600.
%     Se rendi la UI ridimensionabile, valuta un uigridlayout o calcoli dinamici.

    % --- Validazioni leggere -------------------------------------------------
    if nargin < 2 || isempty(message)
        message = ""; % evita errori su concatenazione
    end
    if isempty(parent) || ~isgraphics(parent)
        warning('banner:InvalidParent','Parent non valido: banner non creato.');
        return;
    end

    % --- Creazione etichetta -------------------------------------------------
    uilabel(parent, ...
        'Text', ['ℹ️ ' char(message)], ...
        'FontSize', 12, ...
        'FontName', 'Segoe UI', ...
        'Position', [40, 550, 800, 30], ...
        'FontColor', [0.2 0.2 0.5]);  % blu tenue
end
