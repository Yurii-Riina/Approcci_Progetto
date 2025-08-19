function saveSessionP2(fig)
% SAVESESSIONP2  Serializza lo stato del Modulo 2 (Confusion Matrices) in un .mat.
% =====================================================================================
% PURPOSE
%   Cattura lo stato corrente del Problema 2 (dati + snapshot UI) e lo salva su disco
%   dentro una struttura S, in un file .mat scelto dall’utente tramite uiputfile.
%
% SCOPE
%   - LOGIC/UI wiring: raccoglie AppData, contenuti UI e metadati.
%   - Nessuna elaborazione metrica o normalizzazione.
%
% OUTPUT FILE (.mat)
%   Variabile salvata: S (struct) con campi:
%     .version                  : versione schema (int)
%     .module                   : identificatore modulo (char)
%     .savedAt                  : timestamp datetime
%     .HistoryP2                : storico sessione P2 (come in AppData)
%     .CurrentConfMat           : matrice corrente
%     .CurrentLabels            : labels correnti
%     .CurrentSourceName        : sorgente dati corrente (nome/file/descrizione)
%     .CurrentOpts              : opzioni visualizzazione correnti
%     .HistoryTableP2           : snapshot tabella storico (cell)
%     .FullLogP2                : contenuto log esteso (cellstr)
%     .SessionStatusText        : testo stato sessione (char)
%     .MetricsHistoryDropdownValue, .CompareDropLeftValue, .CompareDropRightValue
%
% UX/ERRORS
%   - Se l’utente annulla il salvataggio: stato aggiornato con messaggio “annullato”.
%   - In caso di eccezioni I/O: uialert best-effort + setSessionStatus('error').
% =====================================================================================

    %% --- Metadati -------------------------------------------------------------------
    S = struct();
    S.version = 1;
    S.module  = 'Problem_2_ConfusionMatrices';
    S.savedAt = datetime('now');

    %% --- AppData / stato corrente ---------------------------------------------------
    S.HistoryP2          = getOr(fig,'HistoryP2',[]);
    S.CurrentConfMat     = getOr(fig,'CurrentConfMat',[]);
    S.CurrentLabels      = getOr(fig,'CurrentLabels',{});
    S.CurrentSourceName  = getOr(fig,'CurrentSourceName','');
    S.CurrentOpts        = getOr(fig,'CurrentOpts',struct());

    %% --- Snapshot UI (Tab5 e selezioni varie) --------------------------------------
    tbl = findobj(fig,'Tag','HistoryTableP2');
    S.HistoryTableP2 = normalizeTableData(tbl);

    logBox = findobj(fig,'Tag','FullLogBoxP2');
    S.FullLogP2 = i_getTextAreaValue(logBox);

    stLab = findobj(fig,'Tag','SessionStatusLabel');
    S.SessionStatusText = i_getLabelText(stLab);

    % Dropdown (opzionali)
    ddM = findobj(fig,'Tag','MetricsHistoryDropdown');
    ddL = findobj(fig,'Tag','CompareDropLeft');
    ddR = findobj(fig,'Tag','CompareDropRight');
    S.MetricsHistoryDropdownValue = i_getDropValue(ddM);
    S.CompareDropLeftValue        = i_getDropValue(ddL);
    S.CompareDropRightValue       = i_getDropValue(ddR);

    %% --- Cartella di default --------------------------------------------------------
    outDir = getProblemDataDir(2,'sessions');
    i_ensureDir(outDir);
    defName = ['sessione_' char(datetime('now','Format','yyyyMMdd_HHmmss')) '.mat'];

    %% --- Salvataggio ---------------------------------------------------------------
    try
        [f,p] = uiputfile('*.mat','Salva sessione (P2)', fullfile(outDir,defName));
        if isequal(f,0)
            setSessionStatus(fig,'Salvataggio annullato',true,[],'warning');
            return;
        end
        outFile = fullfile(p,f);
        save(outFile,'S');

        logP2(fig, sprintf('[P2] Sessione salvata: %s', outFile));
        try writeFullLog(fig, sprintf('Sessione salvata: %s', outFile)); catch, end
        setSessionStatus(fig,'Salvataggio sessione',true,outFile,'ok');

    catch ME
        try uialert(fig, ['Errore salvataggio: ' ME.message], 'Errore'); catch, end
        setSessionStatus(fig,'Salvataggio fallito',false,[],'error');
    end
end

%% ===== helpers locali ===============================================================

function v = getOr(fig,key,def)
% GETOR  Ritorna AppData(fig,key) se esiste/non vuoto, altrimenti 'def'.
    if isappdata(fig,key)
        v = getappdata(fig,key);
        if isempty(v), v = def; end
    else
        v = def;
    end
end

function C = normalizeTableData(tbl)
% NORMALIZETABLEDATA  Converte qualsiasi Data di uitable in cell array serializzabile.
%   - istable   -> table2cell
%   - numeric   -> num2cell
%   - cell      -> identity
%   - altrimenti-> cellstr(string(D))
    C = {};
    if isempty(tbl) || ~isgraphics(tbl), return; end
    D = tbl.Data;
    if isempty(D), return; end
    if istable(D)
        C = table2cell(D);
    elseif isnumeric(D)
        C = num2cell(D);
    elseif iscell(D)
        C = D;
    else
        C = cellstr(string(D));
    end
end

function t = i_getTextAreaValue(h)
% I_GETTEXTAREAVALUE  Estrae Value da uitextarea come cellstr (o {} se assente).
    if ~isempty(h) && isgraphics(h) && ~isempty(h.Value)
        t = h.Value;
    else
        t = {};
    end
end

function t = i_getLabelText(h)
% I_GETLABELTEXT  Estrae Text da uilabel (o '' se assente).
    if ~isempty(h) && isgraphics(h)
        t = h.Text;
    else
        t = '';
    end
end

function v = i_getDropValue(h)
% I_GETDROPVALUE  Estrae Value da uidropdown (o '' se assente).
    if ~isempty(h) && isgraphics(h)
        v = h.Value;
    else
        v = '';
    end
end

function i_ensureDir(d)
% I_ENSUREDIR  Crea la directory se non esiste (no-op se già presente).
    if ~exist(d,'dir'), mkdir(d); end
end

function outDir = getProblemDataDir(problemIdx, subfolder)
% GETPROBLEMDATADIR  Risolve la cartella Data/Problem_<idx>/<subfolder> a partire da questo file.
%   Strategy:
%     1) Assume struttura: .../<root>/Modules/Problem_2/Logic/<thisfile>
%        -> root = fileparts(fileparts(fileparts(thisFileDir)))
%     2) Fallback: risale di max 6 livelli finché non trova una cartella 'Data'
    thisFileDir = fileparts(mfilename('fullpath'));
    rootDir = fileparts(fileparts(fileparts(thisFileDir))); % Logic -> Problem_2 -> Modules -> <root>
    if ~exist(fullfile(rootDir,'Data'),'dir')
        tmp = thisFileDir;
        for k = 1:6
            tmp = fileparts(tmp);
            if exist(fullfile(tmp,'Data'),'dir')
                rootDir = tmp; 
                break;
            end
        end
    end
    outDir = fullfile(rootDir,'Data',sprintf('Problem_%d',problemIdx),subfolder);
end
