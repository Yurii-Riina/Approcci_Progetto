function classifyAndLabel(fig)
% CLASSIFYANDLABEL - Classifica l'immagine corrente e assegna nomi alle feature.
%
% Scopo:
%   1) Richiamare la classificazione standard (classifyCurrentImage)
%   2) Aggiornare i nomi delle feature nella tabella corrispondente (Tab 2)
%      in base alla lunghezza effettiva del vettore di feature estratto
%
% Funzionamento:
%   - Le prime due feature hanno nomi predefiniti:
%       1) "Compattezza"
%       2) "Protrusion ratio"
%   - Le eventuali feature aggiuntive vengono nominate come feat_X
%     (dove X parte da 1)
%   - Viene anche garantita la presenza di un’intestazione di colonna ("Valore")
%
% Input:
%   fig - Handle della figura principale della GUI
%
% -------------------------------------------------------------------------

%% 1) Classificazione standard dell'immagine corrente
    classifyCurrentImage(fig);

%% 2) Recupero tabella delle feature
    tbl = findobj(fig, 'Tag', 'FeatureTable');

    % Se la tabella non esiste, non è valida o è vuota → uscita
    if isempty(tbl) || ~isgraphics(tbl) || isempty(tbl.Data)
        return;
    end

%% 3) Assegnazione nomi riga in base al numero di feature
    n = size(tbl.Data, 1);          % numero di righe (feature)
    names = strings(n, 1);          % array stringhe inizializzato

    if n >= 1
        names(1) = "Compattezza";
    end
    if n >= 2
        names(2) = "Protrusion ratio";
    end

    % Feature extra dal terzo elemento in poi
    for k = 3:n
        names(k) = "feat_" + string(k - 2);
    end

    tbl.RowName = cellstr(names);   % assegna nomi come cell array di char

%% 4) Assicura l’intestazione di colonna
    if isempty(tbl.ColumnName)
        tbl.ColumnName = {'Valore'};
    end
end