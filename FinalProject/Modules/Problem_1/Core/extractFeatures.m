function [c, pr, feat] = extractFeatures(imgPath)
% EXTRACTFEATURES  Estrae tre feature semplici da un'immagine di mano.
%
% [c, pr, feat] = extractFeatures(imgPath)
%
% Output:
%   c   : Compattezza = 4*pi*Area / Perimetro^2   (∈ (0,1], cerchio→1)
%   pr  : Protrusion Ratio destra/sinistra rispetto al centroide
%   feat: (segnaposto) qui usiamo la SOLIDITY della regione (∈ (0,1])
%
% Note di robustezza:
% - Gestisce immagini RGB/gray.
% - Segmentazione con imbinarize adattivo + piccola pulizia morfologica.
% - Se non trova regioni: c=NaN, pr=NaN, feat=0 (compatibile col tuo uso).
% - Fix calcolo PR: attenzione che il centroide è [x y] = [colonna riga];
%   ind2sub restituisce [riga, colonna]. Usiamo le COLONNE per le distanze
%   orizzontali e il centroide.x per il confronto, con protezione da /0.

    %% Validazione input e default d’uscita
    c = NaN; pr = NaN; feat = 0;
    if nargin < 1 || ~ischar(imgPath) && ~isstring(imgPath) || ~isfile(imgPath)
        % Input non valido: usciamo con i default
        return;
    end

    %% Lettura + conversione in scala di grigi
    I = imread(imgPath);
    if ndims(I) == 3
        Igray = rgb2gray(I);
    else
        Igray = I;
    end

    %% Segmentazione (threshold adattivo) + pulizia basilare
    % Sensitivity medio-alta per facilitare il foreground in condizioni variabili.
    bw = imbinarize(Igray, 'adaptive', 'Sensitivity', 0.55);

    % Rimuovi piccole componenti (1% dell'area immagine come default “sicuro”)
    minPixels = max(50, round(0.01 * numel(bw)));
    bw = bwareaopen(bw, minPixels);

    % Chiudi piccoli buchi sulla mano
    bw = imfill(bw, 'holes');

    %% Estrazione regione principale
    stats = regionprops(bw, 'Area', 'Perimeter', 'PixelIdxList', 'Centroid', ...
                           'ConvexArea', 'Solidity');  % solidity per feat
    if isempty(stats)
        % Nessuna regione: ritorna default
        return;
    end

    % Seleziona la regione più grande per area
    [~, idxMax] = max([stats.Area]);
    R = stats(idxMax);

    %% Compattezza (con protezione perimetro)
    P = R.Perimeter;
    if P <= 0
        c = NaN;
    else
        c = 4*pi * (R.Area) / (P^2);
    end

    %% Protrusion Ratio (orizzontale) rispetto al centroide
    % Centroide: [x y] = [colonna riga]
    cx = R.Centroid(1);

    % Ottieni le COLONNE dei pixel della regione
    [rows, cols] = ind2sub(size(bw), R.PixelIdxList); %#ok<ASGLU>
    colMin = min(cols);
    colMax = max(cols);

    % Distanze orizzontali dal centroide in pixel
    maxRight = max(0, colMax - cx);
    maxLeft  = max(0, cx - colMin);

    % Evita divisioni per zero; se entrambi ~> 0, usa il rapporto
    if maxLeft < eps && maxRight < eps
        pr = NaN;                 % regione “puntiforme”/patologica
    elseif maxLeft < eps
        pr = Inf;                 % tutto a destra del centroide
    else
        pr = maxRight / maxLeft;  % >1: protrusione destra; <1: sinistra
    end

    %% Terza feature (segnaposto utile): SOLIDITY
    % Solidity ∈ (0,1]: 1 = forma “piena/convessa”.
    if isfield(R,'Solidity') && ~isempty(R.Solidity) && ~isnan(R.Solidity)
        feat = R.Solidity;
    else
        % fallback se non disponibile
        if isfield(R,'ConvexArea') && R.ConvexArea > 0
            feat = R.Area / R.ConvexArea;
        else
            feat = 0;
        end
    end
end