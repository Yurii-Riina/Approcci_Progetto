function enableHistoryTableDoubleClick(fig)
% ENABLEHISTORYTABLEDOUBLECLICK - Abilita comportamento "doppio click" su HistoryTableFull.
%
% Scopo:
%   Questo script emula la funzionalità di doppio click sulla tabella 
%   'HistoryTableFull' (tipicamente nel Tab 4 della GUI), SENZA utilizzare 
%   funzioni esterne come findjobj. Si basa invece su:
%       - intercettazione della selezione di cella
%       - rilevamento di due click consecutivi sulla stessa riga
%         entro una soglia temporale definita (dblThresh)
%
% Funzionamento:
%   - Al primo click, memorizza la riga selezionata e il timestamp.
%   - Se entro dblThresh secondi si clicca la stessa riga, viene chiamata 
%     la funzione `onDoubleClickRow` (se presente). In caso di errore 
%     o assenza di questa, viene usato il fallback `onHistorySelect`.
%
% Parametri:
%   fig (handle) - handle alla figura principale della GUI
%
% Dipendenze:
%   - onDoubleClickRow(fig, ...) (preferibile)
%   - onHistorySelect(fig, event) (fallback)
%
% Note:
%   - La soglia temporale predefinita è 0.30 secondi.
%   - Gli stati temporanei 'LastRowClick' e 'LastClickTime' vengono salvati
%     in appdata della figura.
%
% Autore: [Tuo Nome]
% Data:   [Data]
% -------------------------------------------------------------------------

%% 1) Recupero tabella di cronologia completa (Tab 4)
    tbl = findobj(fig, 'Tag', 'HistoryTableFull');
    if isempty(tbl) || ~isgraphics(tbl)
        return; % Nessuna tabella trovata: uscita silenziosa
    end

%% 2) Parametri di configurazione
    dblThresh = 0.30;  % soglia doppio click in secondi

%% 3) Inizializzazione stato click
    setappdata(fig, 'LastRowClick', []);
    setappdata(fig, 'LastClickTime', 0);

%% 4) Assegnazione callback alla selezione cella
    tbl.CellSelectionCallback = @(src, event) onCellPick(src, event, fig, dblThresh);
end

% ========================================================================
% CALLBACK INTERNA: rilevamento doppio click simulato
% ========================================================================
function onCellPick(src, event, fig, dblThresh)
    % Selezione nulla → uscita
    if isempty(event.Indices)
        return;
    end

    % Riga selezionata (indice MATLAB 1-based)
    thisRow = event.Indices(1);

    % Recupero stato precedente
    lastRow  = getappdata(fig, 'LastRowClick');
    lastTime = getappdata(fig, 'LastClickTime');

    % Tempo trascorso dall'ultimo click
    elapsed = Inf;
    if lastTime ~= 0
        elapsed = toc(lastTime);
    end

    % Rilevamento doppio click: stessa riga entro soglia
    if isequal(thisRow, lastRow) && elapsed <= dblThresh
        try
            % Se disponibile, usa gestione nativa del doppio click
            onDoubleClickRow(src, [], fig);
        catch
            % In assenza/errore, fallback su anteprima con onHistorySelect
            onHistorySelect(fig, struct('Indices', [thisRow, 1]));
        end

        % Reset stato dopo doppio click
        setappdata(fig, 'LastRowClick', []);
        setappdata(fig, 'LastClickTime', 0);
    else
        % Primo click o riga diversa: aggiorna stato
        setappdata(fig, 'LastRowClick', thisRow);
        setappdata(fig, 'LastClickTime', tic); % memorizza timer avvio
    end
end