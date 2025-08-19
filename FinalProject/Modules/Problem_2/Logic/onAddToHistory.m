function onAddToHistory(fig)
% ONADDTOHISTORY  Inserisce la matrice corrente nello storico e aggiorna la UI.
% =====================================================================================
% PURPOSE
%   Serializza lo stato corrente (C, labels, opts, metriche) in una voce di
%   'HistoryP2' e aggiorna:
%     - Tab5: tabella storico (append riga)
%     - Tab3/Tab4: dropdown tramite refreshP2History
%
% CONTRACT (AppData in lettura)
%   'CurrentConfMat'   : matrice NxN dei conteggi
%   'CurrentLabels'    : 1xN labels (cellstr/string)
%   'CurrentOpts'      : struct opzioni di visualizzazione (opzionale)
%   'CurrentSourceName': nome sorgente/descrizione (opzionale)
%
% CONTRACT (AppData in scrittura)
%   'HistoryP2'        : array struct con campi {name,time,C,labels,opts,
%                       accGlobal,accPerClass,TP,support,note}
%
% BEHAVIOR
%   - Calcola metriche base sui conteggi (support, TP, acc_i, accGlobal).
%   - Appende voce allo storico e aggiorna tabella e dropdown.
%   - Tollerante: se mancano dati, mostra alert/log e ritorna senza errori fatali.
% =====================================================================================

    %% --- Fetch stato corrente -------------------------------------------------------
    C       = getappdata(fig,'CurrentConfMat');
    labels  = getappdata(fig,'CurrentLabels');
    opts    = getappdata(fig,'CurrentOpts');

    if isempty(C) || isempty(labels)
        try uialert(fig,'Nessuna matrice da aggiungere.','Attenzione'); catch, end
        logP2(fig,'[P2] onAddToHistory: nessuna matrice presente.');
        return;
    end

    % Normalizza labels a row-cell per coerenza serializzazione
    labels = local_toCellRow(labels);

    % Fallback opzioni se assenti
    if isempty(opts)
        opts = struct('normalizeRows',false,'showCounts',true,'showPerc',false, ...
                      'cmap','parula','highlightDiag',true);
    end

    %% --- Metriche base per la riga di storico --------------------------------------
    support = sum(C,2);
    TP      = diag(C);
    denom   = sum(C(:));
    accG    = iff(denom>0, sum(diag(C))/denom, NaN);

    acc_i   = nan(size(C,1),1);
    nz      = support > 0;
    acc_i(nz) = TP(nz)./support(nz);

    %% --- Metadata sorgente ----------------------------------------------------------
    srcName = getappdata(fig,'CurrentSourceName');   % valorizzato da onChooseDemo/onLoadConfMat
    if isempty(srcName), srcName = 'confmat'; end
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

    %% --- Append a HistoryP2 ---------------------------------------------------------
    H = getappdata(fig,'HistoryP2');
    if isempty(H)
        H = entry;
    else
        H(end+1) = entry;
    end
    setappdata(fig,'HistoryP2', H);

    %% --- Aggiorna Tab5 (tabella storico) -------------------------------------------
    try
        hTbl = findobj(fig,'Tag','HistoryTableP2');
        if ~isempty(hTbl) && isvalid(hTbl)
            rows = size(C,1);
            accStr = iff(isnan(accG),'',sprintf('%.1f%%',100*accG));
            row = { srcName, stamp, sprintf('%dx%d',rows,rows), accStr, entry.note };
            if isempty(hTbl.Data)
                hTbl.Data = row;
            else
                hTbl.Data(end+1,:) = row;
            end
        end
    catch ME
        logP2(fig, sprintf('[P2] Update HistoryTableP2 errore: %s', ME.message));
    end

    %% --- Aggiorna dropdown Tab3/Tab4 ------------------------------------------------
    try
        refreshP2History(fig);
    catch ME
        logP2(fig, sprintf('[P2] refreshP2History errore: %s', ME.message));
    end

    logP2(fig, sprintf('[P2] Aggiunto allo storico: %s.', srcName));
end

% ===== Helpers locali ================================================================
function o = iff(cond, a, b)
    if cond, o = a; else, o = b; end
end

function L = local_toCellRow(labels)
% Converte labels a cell array riga (cellstr row) con trim e fallback nome classe.
    if isstring(labels), L = cellstr(labels(:).');
    elseif ischar(labels), L = {labels};
    elseif iscell(labels), L = labels(:).';
    else, L = cellstr(string(labels(:).'));
    end
    % trim e fallback
    for k = 1:numel(L)
        L{k} = strtrim(char(L{k}));
        if isempty(L{k}), L{k} = sprintf('Class %d', k); end
    end
end
