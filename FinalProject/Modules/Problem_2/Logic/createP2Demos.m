function demoDir = createP2Demos()
% CREATEP2DEMOS  Crea 3 matrici demo (MAT + CSV) per il Modulo 2 con 6 classi standard.
% =====================================================================================
% PURPOSE
%   Provisioning degli asset di esempio usati dalla UI:
%     - demo_base       : matrice realistica con diagonale “forte”
%     - demo_unbalanced : class imbalance marcato (supporti diversi)
%     - demo_cross      : confusione incrociata (Fear ↔ Sadness)
%
% OUTPUT
%   demoDir : path della directory finale contenente i file generati.
%
% SIDE EFFECTS
%   Scrive/overwrita (se esistono) i file:
%     <demoDir>/demo_base.{mat,csv}
%     <demoDir>/demo_unbalanced.{mat,csv}
%     <demoDir>/demo_cross.{mat,csv}
%
% DEPENDENCIES
%   resolvePathsP2()  -> deve restituire .demoDir (cartella target).
%
% NOTES
%   - I CSV includono header (VariableNames) con le etichette di classe.
%   - Nessuna validazione “core”: i contenuti sono deterministici e coerenti.
% =====================================================================================

    % Etichette standard (6 emozioni)
    labels = {'Anger','Disgust','Fear','Happiness','Sadness','Surprise'}; 

    % --- Demo: base (realistica) -----------------------------------------------------
    baseC  = [45  2  3  0  1  0;
              3  40  2  1  4  0;
              2   3 42  5  3  1;
              0   2  3 47  2  1;
              1   4  2  2 44  3;
              0   1  2  1  2 46];

    % --- Demo: sbilanciata (supporti diversi) ---------------------------------------
    unbal  = [80  6  8  2  3  1;
              2  30  1  0  2  0;
              3   2 28  3  1  0;
              1   1  3 60  3  2;
              2   3  2  4 25  1;
              1   1  1  2  2 22];

    % --- Demo: incrociata (Fear ↔ Sadness) ------------------------------------------
    cross  = [44  2  3  0  1  0;
              3  41  2  0  4  0;
              2   3 34  3 12  2;
              0   1  2 48  2  1;
              1   3 11  4 30  4;
              0   1  2  1  2 46];

    % --- Resolve cartella target -----------------------------------------------------
    P = resolvePathsP2();
    demoDir = P.demoDir;
    if ~exist(demoDir,'dir')
        mkdir(demoDir);
    end

    % --- Scrittura atomica dei 3 set (MAT + CSV) ------------------------------------
    writeOne(demoDir,'demo_base',       baseC,  labels, ...
        'Demo base (realistica): diagonale forte, rumore moderato.');
    writeOne(demoDir,'demo_unbalanced', unbal,  labels, ...
        'Demo sbilanciata: supporto molto diverso tra classi.');
    writeOne(demoDir,'demo_cross',      cross,  labels, ...
        'Demo incrociata: Fear↔Sadness spesso confusi.');
end

% =====================================================================================
% Local helpers
% =====================================================================================
function writeOne(dirPath, stem, C, labels, ~)
% WRITEONE  Serializza una matrice/labels in .mat e .csv con header.
%   - MAT: variabili 'C' e 'labels'
%   - CSV: header = labels come VariableNames
    % Normalizza labels come cellstr riga
    if isstring(labels), labels = cellstr(labels(:).'); end
    if ischar(labels),   labels = {labels}; end
    if ~iscell(labels),  labels = cellstr(string(labels(:).')); end

    % File target
    matFile = fullfile(dirPath,[stem '.mat']);
    csvFile = fullfile(dirPath,[stem '.csv']);

    % Salvataggio .mat (overwrite)
    save(matFile, 'C', 'labels');

    % Salvataggio .csv con header = labels
    T = array2table(C, 'VariableNames', labels);
    writetable(T, csvFile, 'WriteVariableNames', true);
end
