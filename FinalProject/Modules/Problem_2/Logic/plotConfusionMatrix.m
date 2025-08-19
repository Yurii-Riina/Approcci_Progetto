function plotConfusionMatrix(ax, C, labels, opts)
% PLOTCONFUSIONMATRIX  Render della heatmap (UI) con annotazioni intelligenti.
% =====================================================================================
% PURPOSE
%   Visualizza una matrice (conteggi o percentuali per riga) come heatmap con:
%     - Annotazioni (conteggi/percentuali) leggibili su qualsiasi colormap
%     - Font-size adattivo per evitare overflow
%     - Diagonale evidenziata (true positives)
%
% INPUT
%   ax     : uiaxes/axes target (richiesto). Se mancante/invalid -> return silenzioso.
%   C      : matrice NxN dei conteggi per classe (numeric, >=0).
%   labels : etichette classe (1xN, cellstr/string). Verranno forzate a cellstr,row
%            e clampate/troncate a N per robustezza UI.
%   opts   : struct opzioni (tutte opzionali, default tra parentesi):
%              .normalizeRows (false)  -> usa percentuali per riga (P) al posto di conteggi
%              .showCounts     (true)   -> mostra conteggi C(i,j)
%              .showPerc       (false)  -> mostra percentuali P(i,j) in %
%              .cmap           ('parula')-> nome colormap
%              .highlightDiag  (true)   -> disegna bordo leggero sulla diagonale
%
% BEHAVIOR
%   - Non modifica C; calcola P = C./sum(C,2) solo per display.
%   - Non usa 'cla(...,"reset")' per preservare proprietà/Tag degli axes.
%   - Colore del testo adattato alla luminanza della cella (bianco su scuro, nero su chiaro).
%
% NON-GOALS
%   - Nessuna validazione “core” della matrice (delegata a validateConfMat).
%   - Nessun salvataggio di stato o logica di I/O.
% =====================================================================================

    % === Guardie minime ==============================================================
    if isempty(ax) || ~isvalid(ax), return; end
    if nargin < 4 || isempty(opts)
        opts = struct('normalizeRows',false,'showCounts',true,'showPerc',false,'cmap','parula','highlightDiag',true);
    end

    % === Prepara dati (conteggi e percentuali per riga) ==============================
    M = C;
    rowSum = sum(C,2);
    P = zeros(size(C));
    nz = rowSum > 0;
    P(nz,:) = C(nz,:) ./ rowSum(nz);
    if isfield(opts,'normalizeRows') && opts.normalizeRows
        M = P;  % range 0..1
    end

    % === Plot heatmap (no reset delle proprietà degli axes) ==========================
    cla(ax);                 % cancella figli, preserva Tag/proprietà
    ax.CLimMode = 'auto';
    ax.Toolbar.Visible = 'off';
    box(ax,'on');
    imagesc(ax, M);

    % Colormap robusta
    cmapName = 'parula';
    if isfield(opts,'cmap') && ~isempty(opts.cmap), cmapName = opts.cmap; end
    try
        colormap(ax, cmapName);
    catch
        colormap(ax, 'parula');
    end
    colorbar(ax);

    % === Etichette assi ==============================================================
    N = size(C,1);
    labels = local_toCellRow(labels);
    labels = local_fitLabels(labels, N);   % clamp/pad a N per robustezza UI

    xticks(ax, 1:N); yticks(ax, 1:N);
    xticklabels(ax, labels); yticklabels(ax, labels);
    try
        ax.XTickLabelRotation = 25;
    catch
    end
    xlabel(ax, 'Predicted'); ylabel(ax, 'True');
    title(ax, local_tern(opts.normalizeRows,'Confusion Matrix (rows %)','Confusion Matrix'));

    % === Font size adattivo (in px, con clamp 8..18 pt) ==============================
    axPos  = ax.Position;                      % [x y w h] in px (UI figures)
    cellW  = max(1, axPos(3)/N);
    cellH  = max(1, axPos(4)/N);
    fsBase = floor(0.42 * min(cellW, cellH));
    fs     = max(8, min(18, fsBase));

    % === Mapping valore->colore->luminanza per colore testo ==========================
    cmap = colormap(ax);
    if size(cmap,1) < 16, cmap = parula(256); end
    climVec = ax.CLim;                          % [min max] dati visualizzati
    span = max(eps, climVec(2)-climVec(1));
    toIndex     = @(val) max(1, min(size(cmap,1), round((val - climVec(1))/span*(size(cmap,1)-1) + 1)));
    luminanceOf = @(rgb) 0.2126*rgb(1) + 0.7152*rgb(2) + 0.0722*rgb(3);

    % === Annotazioni (conteggi / percentuali) ========================================
    showCounts = ~isfield(opts,'showCounts') || opts.showCounts;
    showPerc   =  isfield(opts,'showPerc')   && opts.showPerc;

    hold(ax,'on');
    for i = 1:N
        for j = 1:N
            if ~(showCounts || showPerc), continue; end

            % max 2 pezzi: conteggio e/o percentuale -> prealloc eviti append
            parts = strings(2,1);
            t = 0;
            if showCounts
                t = t + 1;
                parts(t) = string(C(i,j));
            end
            if showPerc
                t = t + 1;
                parts(t) = sprintf('%.0f%%', 100*P(i,j));
            end
            if t==0
                continue;                % nulla da mostrare
            end
            str = strjoin(parts(1:t), " / ");

            % Colore testo in base alla luminanza della cella
            idx = toIndex(M(i,j));
            rgb = cmap(idx,:);
            Y   = luminanceOf(rgb);
            col = [1 1 1];                      % default: bianco su scuro
            if Y > 0.60, col = [0 0 0]; end     % su chiaro: nero

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

    % === Evidenzia diagonale (bordo leggero) =========================================
    if isfield(opts,'highlightDiag') && opts.highlightDiag
        hold(ax,'on');
        for d = 1:N
            rectangle(ax,'Position',[d-0.5 d-0.5 1 1],'EdgeColor',[0 0 0],'LineWidth',1.1);
        end
        hold(ax,'off');
    end
end

% ===== Helpers locali (senza alterare la firma pubblica) =============================

function out = local_tern(cond, a, b)
    if cond, out = a; else, out = b; end
end

function L = local_toCellRow(labels)
% Normalizza a cellstr row; gestisce string/char/cell.
    if isstring(labels), L = cellstr(labels(:).');
    elseif ischar(labels), L = {labels};
    elseif iscell(labels), L = labels(:).';
    else, L = cellstr(string(labels(:).'));
    end
end

function L = local_fitLabels(L, N)
% Clamp/Pad etichette a lunghezza N (senza sollevare errori in UI).

    % Normalizza input a cell row
    if ~iscell(L), L = cellstr(string(L)); end
    L = L(:).';

    n = numel(L);
    Lout = cell(1, N);                 % prealloc

    % copia quelle esistenti (fino a N)
    if n >= N
        Lout(:) = L(1:N);
    else
        if n > 0, Lout(1:n) = L; end
        % padding con fallback
        for k = n+1:N
            Lout{k} = sprintf('Class %d', k);
        end
    end

    % trim/spazi e fallback su vuoti
    for k = 1:N
        s = strtrim(char(Lout{k}));
        if isempty(s), s = sprintf('Class %d', k); end
        Lout{k} = s;
    end

    L = Lout;
end
