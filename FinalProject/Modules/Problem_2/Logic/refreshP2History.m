function refreshP2History(fig)
% Popola i dropdown di Tab3 (metriche) e Tab4 (confronto) con HistoryP2.
    
    H = getappdata(fig,'HistoryP2');
    items = {'-- storico vuoto --'};
    if ~isempty(H)
        items = cell(1,numel(H));
        for k = 1:numel(H)
            accG = getfieldOr(H(k),'accGlobal',NaN);
            items{k} = sprintf('%s | %s | acc %.1f%%', H(k).name, H(k).time, 100*accG);
        end
    end
    
    % Tab3
    ddM = findobj(fig,'Tag','MetricsHistoryDropdown');
    if ~isempty(ddM) && isvalid(ddM)
        ddM.Items = items;
        if numel(items)>1
            ddM.Value = items{end};   % ultima voce
        else
            ddM.Value = items{1};
        end
        % aggiorna subito la UI metriche (se c'è almeno una voce reale)
        if ~isempty(H)
            onSelectMetricsFromHistory(fig);
        end
    end
    
    % Tab4 (sinistra/destra)
    ddL = findobj(fig,'Tag','CompareDropLeft');
    ddR = findobj(fig,'Tag','CompareDropRight');
    for dd = [ddL ddR]
        if ~isempty(dd) && isvalid(dd)
            dd.Items = items;
            dd.Value = items{1};      % non forziamo l'ultima qui
        end
    end
end

function v = getfieldOr(S, fname, def)
    if isfield(S,fname), v = S.(fname); else, v = def; end
end
