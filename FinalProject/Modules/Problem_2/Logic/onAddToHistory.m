function onAddToHistory(fig)
% Salva la matrice corrente nello storico (Tab4) e aggiorna il dropdown di confronto (Tab3).

    C       = getappdata(fig,'CurrentConfMat');
    labels  = getappdata(fig,'CurrentLabels');
    opts    = getappdata(fig,'CurrentOpts');

    if isempty(C) || isempty(labels)
        try uialert(fig,'Nessuna matrice da aggiungere.','Attenzione'); 
        catch
        end
        logP2(fig,'[P2] onAddToHistory: nessuna matrice presente.');
        return;
    end

    % --- metriche base per la riga di storico
    support = sum(C,2);
    TP      = diag(C);
    denom   = sum(C(:));
    accG    = iff(denom>0, sum(diag(C))/denom, NaN);
    acc_i   = nan(size(C,1),1);
    nz      = support>0; 
    acc_i(nz) = TP(nz)./support(nz);

    % --- nome/metadata sorgente (se non presente, fallback con timestamp)
    srcName = getappdata(fig,'CurrentSourceName');   % se onChooseDemo/onLoadConfMat lo hanno settato
    if isempty(srcName)
        srcName = 'confmat';
    end
    stamp = char(datetime('now','Format','dd-MM-yyyy HH:mm:ss'));

    entry = struct( ...
        'name',        srcName, ...
        'time',        stamp, ...
        'C',           C, ...
        'labels',      {labels}, ...
        'opts',        opts, ...
        'accGlobal',   accG, ...
        'accPerClass', acc_i, ...
        'TP',          TP, ...
        'support',     support, ...
        'note',        '' );

    % --- append ad HistoryP2
    H = getappdata(fig,'HistoryP2');
    if isempty(H)
        H = entry;
    else
        H(end+1) = entry;
    end
    setappdata(fig,'HistoryP2', H);

    % --- aggiorna Tab5 (tabella storico)
    try
        hTbl = findobj(fig,'Tag','HistoryTableP2');
        if ~isempty(hTbl) && isvalid(hTbl)
            rows = size(C,1);
            row = { sprintf('%s',srcName), stamp, sprintf('%dx%d',rows,rows), ...
                    iff(isnan(accG),'',sprintf('%.1f%%',100*accG)), entry.note };
            % append
            if isempty(hTbl.Data)
                hTbl.Data = row;
            else
                hTbl.Data(end+1,:) = row;
            end
        end
    catch ME
        logP2(fig, sprintf('[P2] Update HistoryTableP2 errore: %s', ME.message));
    end

    % --- aggiorna dropdown Tab3/Tab4 in un colpo
    try
        refreshP2History(fig);
    catch ME
        logP2(fig, sprintf('[P2] refreshP2History errore: %s', ME.message));
    end

    logP2(fig, sprintf('[P2] Aggiunto allo storico: %s (%s).', srcName, stamp));
end

function o = iff(cond, a, b)
    if cond, o = a; else, o = b; end
end
