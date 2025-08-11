function enableHistoryTableDoubleClick(fig)
% enableHistoryTableDoubleClick(fig)
% -----------------------------------------------------------------------------
% Emula il doppio-click sulla tabella "HistoryTableFull" (Tab 4) SENZA findjobj,
% usando la selezione di cella e una soglia temporale. Se l'utente seleziona
% la stessa riga due volte entro 'dblThresh' secondi, chiama onDoubleClickRow.
% -----------------------------------------------------------------------------

    tbl = findobj(fig,'Tag','HistoryTableFull');
    if isempty(tbl) || ~isgraphics(tbl), return; end

    % soglia per riconoscere il "doppio click" (in secondi)
    dblThresh = 0.30;

    % azzera stato precedente
    setappdata(fig,'LastRowClick',[]);
    setappdata(fig,'LastClickTime',0);

    % callback sulla selezione di cella
    tbl.CellSelectionCallback = @(src,event) onCellPick(src,event,fig,dblThresh);
end

function onCellPick(src,event,fig,dblThresh)
    if isempty(event.Indices), return; end
    thisRow = event.Indices(1,1);

    lastRow  = getappdata(fig,'LastRowClick');
    lastTime = getappdata(fig,'LastClickTime');
    nowTime  = tic;  % marcatore temporale

    % converti timer in secondi: se non abbiamo un tic precedente, lastTime=0
    elapsed =  Inf;
    if lastTime ~= 0
        elapsed = toc(lastTime);
    end

    % doppio click se stessa riga entro soglia
    if isequal(thisRow,lastRow) && elapsed <= dblThresh
        % costruiamo un "event" compatibile con onDoubleClickRow (se serve)
        fakeEvt = struct('Indices',[thisRow,1]); %#ok<NASGU>
        try
            onDoubleClickRow(src,[],fig);   % tua funzione esistente
        catch
            % fallback: apre anteprima usando onHistorySelect
            onHistorySelect(fig, struct('Indices',[thisRow,1]));
        end
        % reset stato
        setappdata(fig,'LastRowClick',[]);
        setappdata(fig,'LastClickTime',0);
    else
        % primo click (o riga diversa): memorizza stato
        setappdata(fig,'LastRowClick',thisRow);
        setappdata(fig,'LastClickTime',nowTime);
    end
end