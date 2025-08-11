function gesture = classifyGestureFromImage(imgName)
% CLASSIFYGESTUREFROMIMAGE  Classifica un gesto statico a partire da un'immagine di mano.
%
% Sintassi
%   gesture = classifyGestureFromImage(imgName)
%
% Input
%   imgName : stringa o char
%             - Può essere un nome file semplice (es. 'Riposo.png')
%             - Oppure un path assoluto/completo
%
% Output
%   gesture : string
%             "sinistra" | "destra" | "stop" | "riposo"
%
% Descrizione
%   La funzione:
%     1. Determina il path dell'immagine (assoluto o relativo alla cartella "Images")
%     2. Carica l'immagine e converte in scala di grigi se necessario
%     3. Segmenta la mano con thresholding adattivo
%     4. Elimina rumore e seleziona la regione più grande
%     5. Calcola due feature:
%          - Compat­tezza (c)
%          - Protrusion Ratio (pr)
%     6. Classifica il gesto usando classifyGestureFromVector()
%
% Note
%   - Le soglie di classificazione sono definite in classifyGestureFromVector
%   - Funzione robusta a immagini RGB o in scala di grigi
%   - Se nessuna regione valida viene trovata → "riposo"
%
% Vedi anche: classifyGestureFromVector, extractFeatures

%% === Determinazione del path immagine ===
if isfile(imgName)
    % Già path completo
    imgPath = imgName;
else
    % Relativo alla cartella /Images accanto a questo file .m
    baseDir   = fileparts(mfilename('fullpath'));
    imagesDir = fullfile(baseDir, 'Images');
    imgPath   = fullfile(imagesDir, imgName);
end

%% === Controllo finale esistenza file ===
if ~isfile(imgPath)
    error('classifyGestureFromImage:FileNotFound', ...
        'Immagine non trovata: %s', imgPath);
end

%% === Lettura immagine ===
I = imread(imgPath);
if size(I,3) == 3
    Igray = rgb2gray(I);
else
    Igray = I;
end

%% === Segmentazione ===
% Thresholding adattivo → separa mano dallo sfondo anche con illuminazione variabile
bw = imbinarize(Igray, 'adaptive', 'Sensitivity', 0.5);

%% === Rimozione rumore ===
% Rimuove oggetti troppo piccoli (meno del 2% dei pixel totali)
minArea = round(0.02 * numel(bw));
bw = bwareaopen(bw, minArea);

%% === Analisi regioni ===
stats = regionprops(bw, 'Area', 'Perimeter', 'PixelIdxList', 'Centroid');
if isempty(stats)
    gesture = "riposo";
    fprintf("Nessuna mano rilevata in %s → riposo\n", imgName);
    return;
end

% Seleziona la regione più grande (mano principale)
[~, idx] = max([stats.Area]);
R = stats(idx);

%% === Calcolo feature ===
% Compat­tezza: misura della regolarità della forma (1 = cerchio perfetto)
c = 4*pi * R.Area / (R.Perimeter^2);

% Protrusion Ratio: sbilanciamento orizzontale rispetto al centroide
cx = R.Centroid(1);
[~, x] = ind2sub(size(bw), R.PixelIdxList);
maxRight = max(x) - cx;
maxLeft  = cx - min(x);
pr = maxRight / maxLeft;

%% === Classificazione ===
gesture = classifyGestureFromVector([c, pr, 0]);

%% === Log a console ===
fprintf("Gesto riconosciuto da %s → %s\n", imgName, gesture);

end