function [c, pr, feat] = extractFeatures(imgPath)
    % Estrae le feature [c, pr, feat] da un'immagine di mano

    I = imread(imgPath);
    if size(I,3)==3
        Igray = rgb2gray(I);
    else
        Igray = I;
    end

    % Segmentazione
    bw = imbinarize(Igray, 'adaptive', 'Sensitivity', 0.5);
    bw = bwareaopen(bw, round(0.02 * numel(bw)));

    % Trova la regione più grande
    stats = regionprops(bw, 'Area', 'Perimeter', 'PixelIdxList', 'Centroid');
    if isempty(stats)
        c = NaN;
        pr = NaN;
        feat = 0;
        return;
    end

    [~, idx] = max([stats.Area]);
    R = stats(idx);

    % Calcolo compattezza
    c = 4*pi * R.Area / (R.Perimeter^2);

    % Calcolo protrusion ratio
    cx = R.Centroid(1);
    [~, x] = ind2sub(size(bw), R.PixelIdxList);
    maxRight = max(x) - cx;
    maxLeft  = cx - min(x);
    pr = maxRight / maxLeft;

    % Placeholder per eventuali altre feature
    feat = 0;
end