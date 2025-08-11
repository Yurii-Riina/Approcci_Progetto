function addHistoryRowSession(fig, name, typeStr, sizeKB, tagStr, classStr)
% ADDHISTORYROWSESSION  Aggiunge una riga alla cronologia completa (Tab 4).
%
% Uso:
%   addHistoryRowSession(fig, name, typeStr, sizeKB, tagStr, classStr)
%
% Parametri:
%   - fig      : handle della figura principale (uifigure)
%   - name     : nome file/voce da mostrare in colonna "Nome" (string/char)
%   - typeStr  : tipo (es. 'PNG','JPG','FV','BATCH'...) → verrà forzato UPPER
%   - sizeKB   : dimensione in KB (numerico o stringa). Se vuoto → ''.
%   - tagStr   : tag libero (string/char). Opzionale, default ''.
%   - classStr : esito/Classe (string/char). Può essere vuoto.
%
% Effetto:
%   Appende una riga a 'HistoryTableFull' in Tab 4 con le 6 colonne:
%   {'Nome','Data','Tipo','Dim (KB)','Tag','Classe'}
%
% Note:
%   - Se la tabella non esiste, la funzione esce silenziosamente (nessun errore UI).
%   - Formatta 'Dim (KB)' con 1 decimale se numerico, altrimenti stringa così com’è.

    %% 1) Recupero tabella
    tbl = findobj(fig, 'Tag', 'HistoryTableFull');
    if isempty(tbl) || ~isgraphics(tbl)
        % Non rompiamo il flusso se la tabella non c'è (UI non pronta)
        return;
    end

    %% 2) Normalizzazione input
    if nargin < 5 || isempty(tagStr),   tagStr = '';   end
    if nargin < 6,                      classStr = ''; end

    name    = local_aschar(name);
    typeStr = upper(local_aschar(typeStr));
    tagStr  = local_aschar(tagStr);
    classStr= local_aschar(classStr);

    % Dim (KB): numerico → '%.1f' ; stringa → così com’è ; vuoto → ''
    if isempty(sizeKB)
        sizeOut = '';
    elseif isnumeric(sizeKB)
        sizeOut = sprintf('%.1f', sizeKB);
    else
        sizeOut = local_aschar(sizeKB);
    end

    % Timestamp
    ts = char(datetime('now', 'Format', 'dd-MM-yyyy HH:mm'));

    %% 3) Prepara nuova riga (6 colonne fisse)
    newRow = {name, ts, typeStr, sizeOut, tagStr, classStr};

    %% 4) Appendi in modo robusto
    D = tbl.Data;
    if istable(D)
        D = table2cell(D);
    elseif isempty(D)
        D = {};
    end

    % In caso di mismatch colonne, normalizza (6 colonne attese)
    nCols = 6;
    if ~isempty(D) && size(D,2) ~= nCols
        % taglia o estendi con celle vuote
        if size(D,2) > nCols
            D = D(:,1:nCols);
        else
            D(:, end+1:nCols) = {''};
        end
    end

    tbl.Data = [D; newRow];
end

%% ===== Helpers locali ====================================================
function c = local_aschar(x)
    % Converte qualunque input sensato in char in modo sicuro.
    if isstring(x), x = char(x); end
    if ischar(x)
        c = x;
    else
        try
            c = char(string(x));
        catch
            c = '';
        end
    end
end