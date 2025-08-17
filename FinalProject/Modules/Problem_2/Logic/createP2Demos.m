function demoDir = createP2Demos()
% Crea 3 demo (MAT+CSV) per il Problema 2 con 6 classi standard.

    labels = {'Anger','Disgust','Fear','Happiness','Sadness','Surprise'}; 

    baseC  = [45  2  3  0  1  0;   % Base (realistica)
              3  40  2  1  4  0;
              2   3 42  5  3  1;
              0   2  3 47  2  1;
              1   4  2  2 44  3;
              0   1  2  1  2 46];

    unbal  = [80  6  8  2  3  1;   % Sbilanciata (supporto diverso)
              2  30  1  0  2  0;
              3   2 28  3  1  0;
              1   1  3 60  3  2;
              2   3  2  4 25  1;
              1   1  1  2  2 22];

    cross  = [44  2  3  0  1  0;   % Incrociata (Fear↔Sadness molto confusi)
              3  41  2  0  4  0;
              2   3 34  3 12  2;
              0   1  2 48  2  1;
              1   3 11  4 30  4;
              0   1  2  1  2 46];

    P = resolvePathsP2();
    demoDir = P.demoDir;
    if ~exist(demoDir,'dir')
        mkdir(demoDir);
    end

    writeOne(demoDir,'demo_base',       baseC,  labels, ...
        'Demo base (realistica): diagonale forte, rumore moderato.');
    writeOne(demoDir,'demo_unbalanced', unbal,  labels, ...
        'Demo sbilanciata: supporto molto diverso tra classi.');
    writeOne(demoDir,'demo_cross',      cross,  labels, ...
        'Demo incrociata: Fear↔Sadness spesso confusi.');
end

function writeOne(dirPath, stem, C, labels, ~)
    save(fullfile(dirPath,[stem '.mat']), 'C','labels');
    T = array2table(C,'VariableNames',labels);
    writetable(T, fullfile(dirPath,[stem '.csv']));
end
