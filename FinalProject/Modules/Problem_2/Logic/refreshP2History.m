function refreshP2History(fig)
% REFRESHP2HISTORY  Popola i dropdown di Tab3 (Metriche) e Tab4 (Confronto) da HistoryP2.
% =====================================================================================
% PURPOSE
%   Legge lo storico (AppData 'HistoryP2') e costruisce le liste per:
%     - Tab3: 'MetricsHistoryDropdown' (se presente -> seleziona ultimo item reale)
%     - Tab4: 'CompareDropLeft' e 'CompareDropRight' (se presenti -> placeholder)
%
% CONTRACT
%   AppData 'HistoryP2' atteso come array struct con campi almeno:
%     .name (char/string)     : nome voce di storico (es. file o label)
%     .time (char/string/datetime) : timestamp o descrizione temporale
%     .accGlobal (double)     : accuratezza globale [0..1] (può mancare/NaN)
%
% BEHAVIOR
%   - Se HistoryP2 è vuoto/assente -> mostra '-- storico vuoto --'.
%   - L’ultimo elemento reale dello storico viene selezionato in Tab3 per immediatezza.
%   - In Tab4 non si forza la selezione (rimane placeholder).
%
% NON-GOALS
%   - Nessuna modifica dello storico.
%   - Nessuna validazione profonda dei campi (best-effort, NaN-safe).
% =====================================================================================

    % --- Recupero storico ------------------------------------------------------------
    H = getappdata(fig,'HistoryP2');

    % --- Costruzione items -----------------------------------------------------------
    items = {'-- storico vuoto --'};
    if isstruct(H) && ~isempty(H)
        n = numel(H);
        items = cell(1, n);
        for k = 1:n
            % Acc globale in %, NaN-safe
            accG = getfieldOr(H(k),'accGlobal', NaN);
            if isnan(accG), accStr = 'n/d'; else, accStr = sprintf('%.1f%%', 100*accG); end

            % Nome e tempo robusti (supporta char/string/datetime)
            nameStr = toCharSafe(getfieldOr(H(k),'name','(sconosciuto)'));
            timeRaw = getfieldOr(H(k),'time','');
            if isa(timeRaw,'datetime')
                timeStr = char(timeRaw);  % usa formato default di MATLAB
            else
                timeStr = toCharSafe(timeRaw);
            end

            items{k} = sprintf('%s | %s | acc %s', nameStr, timeStr, accStr);
        end
    end

    % --- Tab3: MetricsHistoryDropdown -----------------------------------------------
    ddM = findobj(fig,'Tag','MetricsHistoryDropdown');
    if ~isempty(ddM) && isvalid(ddM)
        ddM.Items = items;
        if numel(items) > 1
            % seleziona l’ultima voce reale (più recente)
            ddM.Value = items{end};
        else
            ddM.Value = items{1};
        end

        % Aggiorna subito la UI metriche se esiste almeno una voce reale
        if isstruct(H) && ~isempty(H)
            try
                onSelectMetricsFromHistory(fig);
            catch
                % se il wiring non è disponibile, ignora senza bloccare la UI
            end
        end
    end

    % --- Tab4: CompareDropLeft / CompareDropRight -----------------------------------
    ddL = findobj(fig,'Tag','CompareDropLeft');
    ddR = findobj(fig,'Tag','CompareDropRight');
    for dd = [ddL ddR]
        if ~isempty(dd) && isvalid(dd)
            dd.Items = items;
            % In confronto non forziamo l’ultima: lasciamo placeholder/utente decide
            dd.Value = items{1};
        end
    end
end

% ===== Helpers locali ================================================================

function v = getfieldOr(S, fname, def)
% GETFIELDR  Ritorna S.(fname) se esiste, altrimenti def (no error).
    if isfield(S, fname)
        v = S.(fname);
    else
        v = def;
    end
end

function s = toCharSafe(x)
% TOCHARSAFE  Converte in char string/char/num/others -> string(x)->char.
    if ischar(x)
        s = x;
    elseif isstring(x)
        s = char(x);
    else
        s = char(string(x));
    end
end
