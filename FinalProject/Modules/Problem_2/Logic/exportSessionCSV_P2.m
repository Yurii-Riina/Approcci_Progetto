function exportSessionCSV_P2(fig)
% EXPORTSESSIONCSV_P2  Esporta la cronologia P2 (Tab5) in CSV.
% =====================================================================================
% PURPOSE
%   Serializza la cronologia del Modulo 2 in un file CSV con colonne:
%     Nome, Data, NxN, AccGlobale, Note
%
% INPUT
%   fig : handle della uifigure principale.
%
% DATI SORGENTE (ordine di priorità)
%   1) Tabella UI 'HistoryTableP2' (se valorizzata)
%   2) AppData 'HistoryP2' (ricostruzione riga per riga)
%
% BEHAVIOR
%   - Chiede all’utente dove salvare (uiputfile) con default sotto Data/Problem_2/Exports.
%   - Scrive CSV UTF‑8 con quoting RFC‑like su campi che contengono virgole, quote o newline.
%   - Non solleva errori fatali: informa con alert/log/stato e ritorna.
% =====================================================================================

    %% --- 1) Sorgente principale: Tabella UI ----------------------------------------
    tbl  = findobj(fig,'Tag','HistoryTableP2');
    data = {};
    if ~isempty(tbl) && isgraphics(tbl)
        data = tbl.Data;
    end

    % Se vuota, ricostruisci da HistoryP2
    if isempty(data)
        H = getappdata(fig,'HistoryP2');
        if isempty(H)
            try uialert(fig,'Nessun dato da esportare.','Info'); catch, end
            try setSessionStatus(fig,'Export CSV - nessun dato',true,[],'warning'); catch, end
            return;
        end
        data = cell(numel(H),5);
        for k = 1:numel(H)
            C   = H(k).C; 
            n   = size(C,1);
            accG= safe(H(k),'accGlobal',NaN);
            data{k,1} = safe(H(k),'name','');
            data{k,2} = safe(H(k),'time','');
            data{k,3} = sprintf('%dx%d',n,n);
            data{k,4} = iff(isnan(accG),'',sprintf('%.1f%%',100*accG));
            data{k,5} = safe(H(k),'note','');
        end
    end

    % Normalizza data → cell array di celle (sempre 2D)
    data = i_normalizeDataToCell(data);

    headers = {'Nome','Data','NxN','AccGlobale','Note'};
    nCols   = numel(headers);

    %% --- 2) Path di output ----------------------------------------------------------
    outDir  = getProblemDataDir(2,'Exports');
    if ~exist(outDir,'dir'), mkdir(outDir); end
    defName = ['sessione_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.csv'];

    [f,p] = uiputfile('*.csv','Esporta cronologia (P2)', fullfile(outDir,defName));
    if isequal(f,0)
        try setSessionStatus(fig,'Export CSV annullato',true,[],'warning'); catch, end
        return;
    end
    outFile = fullfile(p,f);

    %% --- 3) Scrittura CSV (UTF-8) ---------------------------------------------------
    fid = fopen(outFile,'w','n','UTF-8');
    if fid<=0
        try uialert(fig, sprintf('Impossibile creare: %s', outFile),'Errore'); catch, end
        try setSessionStatus(fig,'Export CSV fallito',false,[],'error'); catch, end
        return;
    end

    % Header
    fprintf(fid,'%s\n', strjoin(headers,','));

    % Righe
    for r = 1:size(data,1)
        row = data(r,:);
        if numel(row) < nCols, row(end+1:nCols) = {''}; end
        if numel(row) > nCols, row = row(1:nCols);     end

        parts = cell(1,nCols);
        for c = 1:nCols
            parts{c} = i_toCsvString(row{c});
        end
        fprintf(fid,'%s\n', strjoin(parts,','));
    end
    fclose(fid);

    %% --- 4) Log + stato -------------------------------------------------------------
    try writeFullLog(fig, sprintf('Esportato CSV (P2): %s', outFile)); catch, end
    logP2(fig, sprintf('[P2] Export CSV completato: %s', outFile));
    try setSessionStatus(fig,'Export CSV (P2)',true,outFile,'ok'); catch, end
end

%% ===== Helpers ======================================================================
function out = i_toCsvString(x)
% Converte un valore qualsiasi in campo CSV con quoting/escape quando necessario.
    if isempty(x), out=''; return; end
    if exist('toCsvString','file')==2
        out = toCsvString(x); 
        return;
    end
    % Scalar numeric/logical
    if isnumeric(x) && isscalar(x), out = num2str(x); return; end
    if islogical(x) && isscalar(x), out = char(lower(string(x))); return; end

    % Stringhe/char/strings scalari
    s = char(string(x));           % gestisce anche datetime, string, ecc.
    needsQuote = contains(s, {',','"',newline,sprintf('\r')});
    s = strrep(s,'"','""');        % escape CSV per doppie virgolette
    if any(needsQuote), out = ['"' s '"']; else, out = s; end
end

function v = safe(S,f,def)
% safe: S.(f) se esiste, altrimenti def.
    if isfield(S,f), v = S.(f); else, v = def; end
end

function o = iff(c,a,b)
% iff: inline if.
    if c, o = a; else, o = b; end
end

function out = i_normalizeDataToCell(data)
% Normalizza 'data' alla forma cell array (R x C) senza errori per string array, ecc.
    if isempty(data)
        out = {};
        return;
    end
    if istable(data)
        out = table2cell(data);
        return;
    end
    if iscell(data)
        out = data;
        return;
    end
    if isstring(data)
        % string array → cellstr (mantieni shape 2D se possibile)
        if isrow(data) || iscolumn(data)
            out = cellstr(data(:)).';
        else
            out = cellstr(string(data));
        end
        return;
    end
    if isnumeric(data) || islogical(data)
        out = num2cell(data);
        return;
    end
    % Fallback generico
    out = cellstr(string(data));
end

function outDir = getProblemDataDir(problemIdx, subfolder)
% getProblemDataDir: root/Data/Problem_<idx>/<subfolder>
    thisFileDir = fileparts(mfilename('fullpath'));
    rootDir     = fileparts(fileparts(fileparts(thisFileDir)));
    outDir      = fullfile(rootDir,'Data',sprintf('Problem_%d',problemIdx),subfolder);
end
