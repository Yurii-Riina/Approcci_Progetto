function [C, labels, meta] = importConfMat(pathOrVar)
% Importa matrice di confusione da:
%  - .mat: variabile C (NxN), opzionale labels (1xN cellstr o string)
%  - .csv: header opzionale; se header testuale presente -> labels = header
%  - table/matrix già in workspace: accettato come input diretto
%
% Ritorna:
%   C       double NxN
%   labels  cellstr 1xN (o {Class 1..N})
%   meta.name, meta.note

    C = []; labels = {}; meta = struct('name','', 'note','');

    if istable(pathOrVar)
        C = table2array(pathOrVar);
        labels = defaultLabels(size(C,1));
        meta.name = 'table-var';
        return;
    elseif isnumeric(pathOrVar)
        C = pathOrVar;
        labels = defaultLabels(size(C,1));
        meta.name = 'matrix-var';
        return;
    end

    [~,name,ext] = fileparts(pathOrVar);
    meta.name = [name ext];

    switch lower(ext)
        case '.mat'
            S = load(pathOrVar);
            if isfield(S,'C')
                C = double(S.C);
            else
                error('Nel .mat deve esistere la variabile C (NxN).');
            end
            if isfield(S,'labels')
                labels = toCellStr(S.labels);
                if numel(labels) ~= size(C,1)
                    meta.note = ' (labels ridimensionate automaticamente)';
                    labels = defaultLabels(size(C,1));
                end
            else
                labels = defaultLabels(size(C,1));
            end

        case '.csv'
            % Usa readtable: gestisce l'header come VariableNames
            T = readtable(pathOrVar, 'PreserveVariableNames', true);
            C = table2array(T);
            labels = T.Properties.VariableNames;
        
            % Se i VariableNames sono stringhe con spazi, lasciale così (vanno bene per i tick)
            labels = toCellStr(labels);
        
            % Se la tabella è vuota o non numerica, errore esplicito
            if isempty(C) || ~isnumeric(C)
                error('CSV non contiene una matrice numerica valida.');
            end
        
            % Se non è quadrata, prova a capire se c’è una prima colonna “row label” da scartare
            [r,c] = size(C);
            if r~=c && c-1==r
                % esempio: prima colonna è un indice/ID -> scartala
                C = C(:,2:end);
                c = size(C,2);
            end
        
            % Se dopo il tentativo non è quadrata, lascia che la validate avvisi
            if numel(labels) ~= size(C,2)
                % normalizza labels alla dimensione delle colonne
                labels = defaultLabels(size(C,2));
            end

        otherwise
            error('Estensione non supportata: %s', ext);
    end
end

function L = defaultLabels(N)
    L = arrayfun(@(k)sprintf('Class %d',k), 1:N, 'UniformOutput', false);
end

function c = toCellStr(x)
    if isstring(x), x = cellstr(x); end
    if ischar(x),   x = cellstr(string(x)); end
    c = x(:).';
end
