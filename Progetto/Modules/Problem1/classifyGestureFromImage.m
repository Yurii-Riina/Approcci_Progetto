function gesture = classifyGestureFromImage(imgName)
    % classifyGestureFromImage Classifica gesto statico da immagine di mano
    %
    % Supporta sia filename semplice (es. "Riposo.png") che path completo

    % === Verifica se imgName è già un path assoluto esistente ===
    if isfile(imgName)
        imgPath = imgName;
    else
        % === Altrimenti costruisci il percorso relativo nella cartella Images ===
        baseDir   = fileparts(mfilename('fullpath'));
        imagesDir = fullfile(baseDir, 'Images');
        imgPath   = fullfile(imagesDir, imgName);
    end

    % === Controllo finale esistenza file ===
    if ~isfile(imgPath)
        error('Immagine non trovata: %s', imgPath);
    end

    % === Lettura immagine ===
    I = imread(imgPath);
    if size(I,3)==3
        Igray = rgb2gray(I);
    else
        Igray = I;
    end

    % === Segmentazione ===
    bw = imbinarize(Igray, 'adaptive', 'Sensitivity', 0.5);

    % === Rimozione rumore ===
    minArea = round(0.02 * numel(bw));
    bw = bwareaopen(bw, minArea);

    % === Regione più grande ===
    stats = regionprops(bw, 'Area', 'Perimeter', 'PixelIdxList', 'Centroid');
    if isempty(stats)
        gesture = "riposo";
        fprintf("Nessuna mano rilevata in %s → riposo\n", imgName);
        return;
    end
    [~, idx] = max([stats.Area]);
    R = stats(idx);

    % === Calcolo feature ===
    c = 4*pi * R.Area / (R.Perimeter^2);

    cx = R.Centroid(1);
    [~,x] = ind2sub(size(bw), R.PixelIdxList);
    maxRight = max(x) - cx;
    maxLeft  = cx - min(x);
    pr = maxRight / maxLeft;

    % === Classificazione ===
    gesture = classifyGestureFromVector([c, pr, 0]);

    % === Log a console ===
    fprintf("Gesto riconosciuto da %s → %s\n", imgName, gesture);
end