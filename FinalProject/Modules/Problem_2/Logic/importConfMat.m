function [C, labels, meta] = importConfMat(pathOrVar)
% IMPORTCONFMAT  Import di una matrice di confusione + labels da file o variabili.
% =====================================================================================
% PURPOSE
%   Supporta tre ingressi:
%     1) Variabile MATLAB in memoria:
%        - matrix numeric/logical (NxN)  -> "matrix-var"
%        - table                         -> "table-var"
%     2) File .mat con variabile C (NxN) e, opzionale, labels (1xN cellstr/string)
%     3) File .csv con header opzionale:
%        - se presente header testuale -> usato come labels
%        - tenta correzione comune "prima colonna = row labels" (scarto colonne 1)
%
% OUTPUT
%   C       : double NxN (conteggi)
%   labels  : 1xN cellstr (fallback "Class 1..N" se mancanti/discordanti)
%   meta    : struct con .name (nome sorgente) e .note (annotazioni)
%
% BEHAVIOR
%   - Non esegue validazione “core” (delegata a validateConfMat).
%   - Messaggi d’errore espliciti in caso di I/O/formato non interpretabile.
% =====================================================================================

    % ---------------- Ingressi "variabile in memoria" -----------------
    if istable(pathOrVar)
        C       = table2array(pathOrVar);
        labels  = defaultLabels(size(C,1));
        meta    = struct('name','table-var','note','');
        return;

    elseif isnumeric(pathOrVar) || islogical(pathOrVar)
        C = double(pathOrVar);
        labels = defaultLabels(size(C,1));
        meta.name = 'matrix-var';
        return;
    end

    % ---------------- Ingressi "file su disco" ------------------------
    % Normalizza path (char/string) e verifica esistenza
    if ~(ischar(pathOrVar) || isstring(pathOrVar))
        error('Tipo di input non supportato. Attesi variabile numerica/table o path file.');
    end
    pathOrVar = char(pathOrVar);
    if ~isfile(pathOrVar)
        error('File non trovato: %s', pathOrVar);
    end

    [~,name,ext] = fileparts(pathOrVar);
    meta.name = [name ext];

    switch lower(ext)
        case '.mat'
            % -------- MAT: deve contenere C (NxN). labels opzionali ----------
            try
                S = load(pathOrVar);
            catch ME
                error('Impossibile leggere il MAT "%s": %s', pathOrVar, ME.message);
            end

            if isfield(S,'C')
                C = double(S.C);
            else
                error('Nel .mat "%s" deve esistere la variabile C (NxN).', meta.name);
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
            % -------- CSV: usa readtable; header -> VariableNames --------------
            try
                T = readtable(pathOrVar, 'PreserveVariableNames', true);
            catch ME
                error('Impossibile leggere il CSV "%s": %s', pathOrVar, ME.message);
            end

            % Estrarre matrice e labels
            try
                C = table2array(T);
            catch
                error('CSV non convertibile a matrice numerica: verifica celle non numeriche.');
            end
            if isempty(C) || ~isnumeric(C)
                error('CSV non contiene una matrice numerica valida.');
            end

            labels = toCellStr(T.Properties.VariableNames);

            % Rettangolarità/quadraticità: gestione colonna etichette riga
            [r,c] = size(C);
            if r~=c && c-1==r
                % pattern comune: prima colonna = ID/riga → scartala
                C = C(:,2:end);
                c = size(C,2);
                meta.note = [meta.note ' (rimossa 1^ colonna row-labels)'];
            end

            % Allinea num. labels alle colonne
            if numel(labels) ~= c
                labels = defaultLabels(c);
                meta.note = [meta.note ' (labels dal CSV non coerenti: rigenerate)'];
            end

            % Difesa: NaN imprevisti (header “sporchi” nelle righe dati)
            if any(~isfinite(C(:)))
                % Non forziamo fix qui: segnaliamo esplicitamente
                error('CSV contiene NaN/Inf; controlla header/delimitatori o righe non numeriche.');
            end

        otherwise
            error('Estensione non supportata: %s', ext);
    end
end

% ===== Helpers =======================================================================

function L = defaultLabels(N)
% DEFAULTLABELS  Genera {'Class 1',...,'Class N'}.
    L = arrayfun(@(k)sprintf('Class %d',k), 1:N, 'UniformOutput', false);
end

function c = toCellStr(x)
% TOCELLSTR  Normalizza labels a cell array riga di char.
    if isstring(x), x = cellstr(x); end
    if ischar(x),   x = cellstr(string(x)); end
    if iscell(x),   x = x(:).'; else, x = cellstr(string(x)); end
    c = x;
end
