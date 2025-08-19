function clearHistoryP2(fig)
% CLEARHISTORYP2  Svuota completamente la sessione del Problema 2 (previa conferma).
% =====================================================================================
% SCOPE
%   Reinizializza stato applicativo e componenti UI del Modulo 2:
%     - AppData: HistoryP2, matrice/labels correnti, sorgente
%     - Tab 5: tabella storico + log esteso
%     - Tab 2: heatmap corrente + log breve
%     - Tab 3: badge, tabella metriche, bar chart, mini‑report, dropdown
%     - Tab 4: dropdown, heatmap L/R, pannello riepilogo (rimosso)
%     - Stato sessione: “Inattiva” (warning)
%
% GOALS
%   - Operazione “distruttiva” con conferma esplicita.
%   - Pulizia non distruttiva delle proprietà degli axes (NO 'cla(...,"reset")').
%   - Nessun throw fatale: best‑effort con try/catch.
% =====================================================================================

%% --- Conferma utente (bloccante ma sicura)
try
    choice = uiconfirm(fig, ...
        ['Sei sicuro di voler cancellare la cronologia?' newline ...
         '⚠️ Questa azione eliminerà TUTTO ciò che hai fatto finora.' newline ...
         'Consigliato: salva la sessione prima di procedere.'], ...
        'Conferma cancellazione', ...
        'Options',      {'Annulla','Cancella tutto'}, ...
        'DefaultOption',1, ...   % Sicurezza: default = Annulla
        'CancelOption', 1, ...
        'Icon','warning');
    if ~strcmp(choice,'Cancella tutto'), return; end
catch
    % se uiconfirm non disponibile (versioni vecchie), prosegui senza prompt
end

%% --- AppData (stato)
setappdata(fig,'HistoryP2',[]);
setappdata(fig,'CurrentConfMat',[]);
setappdata(fig,'CurrentLabels',{});
setappdata(fig,'CurrentSourceName','');

%% --- Tab 5: storico + log esteso
tbl5 = findobj(fig,'Tag','HistoryTableP2');
if ~isempty(tbl5) && isgraphics(tbl5), tbl5.Data = {}; end

log5 = findobj(fig,'Tag','FullLogBoxP2');
if ~isempty(log5) && isgraphics(log5), log5.Value = {''}; end

% Log breve Tab 2 (se presente)
log2 = findobj(fig,'Tag','LogBoxP2');
if ~isempty(log2) && isgraphics(log2), log2.Value = {''}; end

%% --- Tab 3: Metriche
% Dropdown
ddM = findobj(fig,'Tag','MetricsHistoryDropdown');
resetDropdown(ddM);

% Badge accur. globale
accLbl = findobj(fig,'Tag','LabelGlobalAcc');
if ~isempty(accLbl) && isgraphics(accLbl), accLbl.Text = '–'; end

% Tabella per classe
tbl3 = findobj(fig,'Tag','TablePerClass');
if ~isempty(tbl3) && isgraphics(tbl3), tbl3.Data = {}; end

% Bar chart
axBar = findobj(fig,'Tag','BarAxes');
safeClearAxes(axBar);
title(axBar,'Accuratezza per classe (%)'); xlabel(axBar,'Classe'); ylabel(axBar,'Acc %');

% Mini‑report (card)
setTextIf(fig,'RptGlobal','Accuratezza globale: –');
setTextIf(fig,'RptBest','Migliore: –');
setTextIf(fig,'RptWorst','Peggiore: –');
setTextIf(fig,'RptTip','Suggerimento: —');

%% --- Tab 4: Confronto
% Dropdown A/B
ddL = findobj(fig,'Tag','CompareDropLeft');
ddR = findobj(fig,'Tag','CompareDropRight');
resetDropdown(ddL); 
resetDropdown(ddR);

% Heatmap L/R
axL = findobj(fig,'Tag','CompareAxesLeft');
axR = findobj(fig,'Tag','CompareAxesRight');
safeClearAxes(axL); 
safeClearAxes(axR);

% Report pannello “card”
tabCompare = [];
tg = findobj(fig,'Type','uitabgroup');
if ~isempty(tg)
    tabs = findobj(tg,'Type','uitab');
    tabCompare = findobj(tabs,'Title','🆚 Confronto');
end
if ~isempty(tabCompare)
    oldRpt = findobj(tabCompare(1),'Tag','CompareReportPanel');
    if ~isempty(oldRpt)
        try delete(oldRpt(ishghandle(oldRpt))); catch, end
    end
end

% Vecchia textarea di riepilogo (se c'è) → ripristina placeholder e visibilità
txt = findobj(fig,'Tag','CompareSummaryBox');
if ~isempty(txt) && isgraphics(txt)
    txt.Value   = {'Riepilogo confronto (globale e per classe) apparirà qui.'};
    txt.Visible = 'on';
end

%% --- Tab 2: heatmap corrente
axCM = getappdata(fig,'AxesCMHandle');
if isempty(axCM) || ~isgraphics(axCM)
    axCM = findall(fig,'Type','uiaxes','-and','Tag','AxesCM');
    if ~isempty(axCM), axCM = axCM(1); end
end
safeClearAxes(axCM); 
xlabel(axCM,'Predicted'); 
ylabel(axCM,'True');

%% --- Stato sessione + log finale
try setSessionStatus(fig,'Pulisci cronologia',false,[],'warning'); catch, end   % “Inattiva”
try writeFullLog(fig,'Cronologia e viste pulite (P2).'); catch, end
logP2(fig,'[P2] Cronologia e viste pulite.');
end

%% ===== Helpers =====================================================================
function resetDropdown(h)
% RESETDROPDOWN  Reinizializza un dropdown alla voce “storico vuoto”.
    if isempty(h) || ~isgraphics(h), return; end
    try
        h.Items = {'-- storico vuoto --'};
        h.Value = h.Items{1};
    catch
    end
end

function safeClearAxes(ax)
% SAFECLEARAXES  Pulisce un uiaxes senza resettarne le proprietà/Tag.
    if isempty(ax) || ~isgraphics(ax), return; end
    try
        cla(ax);                          % <-- NIENTE 'reset'
        ax.CLimMode = 'auto';
        ax.Toolbar.Visible = 'off';
        box(ax,'on');
    catch
    end
end

function setTextIf(fig, tag, txt)
% SETTEXTIF  Setta h.Text se il controllo con Tag esiste/valido.
    h = findobj(fig,'Tag',tag);
    if ~isempty(h) && isgraphics(h), h.Text = txt; end
end
