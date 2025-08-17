function plotConfusionMatrix(ax, C, labels, opts)
% Heatmap con annotazioni, normalizzazione per riga e diagonale evidenziata.
% Fix:
%  - font size adattivo (no overflow) + Clipping ON
%  - colore testo basato sulla luminanza del colore di sfondo (bianco su scuro, nero su chiaro)
%  - compatibilità: usa ax.CLim (niente variabile/funzione 'clim')

    if isempty(ax) || ~isvalid(ax), return; end
    if nargin<4 || isempty(opts)
        opts = struct('normalizeRows',false,'showCounts',true,'showPerc',false,'cmap','parula','highlightDiag',true);
    end

    % === Prepara dati ===
    M = C;
    rowSum = sum(C,2);
    P = zeros(size(C));
    nz = rowSum>0;
    P(nz,:) = C(nz,:) ./ rowSum(nz);
    if isfield(opts,'normalizeRows') && opts.normalizeRows
        M = P;  % 0..1
    end

    % === Plot heatmap ===
    cla(ax,'reset');  
    ax.CLimMode = 'auto';
    ax.Toolbar.Visible = 'off';  
    box(ax,'on');    
    imagesc(ax, M);
    
    % colormap
    cmapName = 'parula';
    if isfield(opts,'cmap') && ~isempty(opts.cmap), cmapName = opts.cmap; end
    try colormap(ax, cmapName);
    catch
        colormap(ax,'parula');
    end
    colorbar(ax);

    % Assi / etichette
    N = size(C,1);
    xticks(ax,1:N); yticks(ax,1:N);
    xticklabels(ax, labels); yticklabels(ax, labels);
    try
        ax.XTickLabelRotation = 25;
    catch
    end
    xlabel(ax,'Predicted'); ylabel(ax,'True');
    title(ax, tern(opts.normalizeRows,'Confusion Matrix (rows %)','Confusion Matrix'));

    % === Font size adattivo (in px) ===
    axPos = ax.Position;                 % [x y w h] in px
    cellW = max(1, axPos(3)/N);
    cellH = max(1, axPos(4)/N);
    fsBase = floor(0.42 * min(cellW, cellH));
    fs = max(8, min(18, fsBase));        % clamp: 8..18 pt

    % === Mapping valore -> colore -> luminanza (compatibile) ===
    cmap = colormap(ax);
    if size(cmap,1) < 16, cmap = parula(256); end
    climVec = ax.CLim;                    % [min max] dei dati visualizzati
    span = max(eps, climVec(2)-climVec(1));

    toIndex = @(val) max(1, min(size(cmap,1), round((val - climVec(1))/span*(size(cmap,1)-1) + 1)));
    luminanceOf = @(rgb) 0.2126*rgb(1) + 0.7152*rgb(2) + 0.0722*rgb(3); % sRGB

    % === Annotazioni ===
    showCounts = ~isfield(opts,'showCounts') || opts.showCounts;
    showPerc   =  isfield(opts,'showPerc')   && opts.showPerc;

    hold(ax,'on');
    for i = 1:N
        for j = 1:N
            if ~(showCounts || showPerc), continue; end

            parts = strings(0,1);
            if showCounts
                parts(end+1) = string(C(i,j));
            end
            if showPerc
                parts(end+1) = sprintf('%.0f%%', 100*P(i,j));
            end
            str = strjoin(parts, " / ");
            if str == ""
                continue; 
            end

            % colore testo in base alla luminanza della cella
            idx = toIndex(M(i,j));
            rgb = cmap(idx,:);
            Y   = luminanceOf(rgb);
            col = [1 1 1];                % default bianco
            if Y > 0.60
                col = [0 0 0];
            end  % su sfondo chiaro → nero

            text(ax, j, i, str, ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle', ...
                'FontSize', fs, ...
                'Clipping','on', ...
                'Color', col, ...
                'Interpreter','none');
        end
    end
    hold(ax,'off');

    % === Evidenzia diagonale ===
    if isfield(opts,'highlightDiag') && opts.highlightDiag
        hold(ax,'on');
        for d = 1:N
            rectangle(ax,'Position',[d-0.5 d-0.5 1 1],'EdgeColor',[0 0 0],'LineWidth',1.1);
        end
        hold(ax,'off');
    end
end

function out = tern(cond, a, b)
    if cond, out = a; else, out = b; end
end
