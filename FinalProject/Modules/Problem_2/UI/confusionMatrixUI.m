function confusionMatrixUI()
% CONFUSIONMATRIXUI
% =====================================================================================
% Purpose
%   Costruisce l’interfaccia grafica (UI-only) per il "Problema 2 – Analisi Matrici
%   di Confusione". La UI offre:
%     - Caricamento/Selezione/Incolla di matrici di confusione NxN (Tab 2)
%     - Opzioni di visualizzazione (normalizzazione, colormap, show mode) (Tab 2)
%     - Pannello metriche con tabella per-classe, grafico a barre e mini-report (Tab 3)
%     - Confronto side-by-side tra due matrici (corrente vs. storico) (Tab 4)
%     - Gestione sessione: storico, stato, export, log esteso (Tab 5)
%     - FAQ collapse/expand con scroll (Tab 6)
%
% Scope & Constraints
%   - Questo file contiene esclusivamente UI e “wiring light”. Nessuna logica numerica o
%     I/O pesante: i callback delegano a funzioni esterne se presenti (Core/Logic).
%   - Se la funzione esterna non esiste, viene mostrato un TODO non bloccante.
%   - La UI è resiliente: non genera errori se le dipendenze non sono presenti.
%
% Integration Contract
%   - I callback invocano funzioni con firma FEVAL-like: feval(name, fig, ...).
%     Nomi tipici (da implementare nel Core/Logic):
%       onLoadConfMat, onChooseDemo, onPasteMatrix,
%       onVisOptionsChanged, onComputeMetrics, onAddToHistory,
%       onSelectMetricsFromHistory, onCompare,
%       loadSessionP2|loadSession, saveSessionP2|saveSession,
%       exportSessionCSV_P2|exportSessionCSV, clearHistoryP2|clearHistory,
%       enableHistoryTableDoubleClickP2|enableHistoryTableDoubleClick,
%       setSessionStatus, addFooter, refreshP2History.
%   - Se un nome non è disponibile, si stampa un TODO e, dove utile (compute metrics),
%     si usa una demo mock per popolare la UI.
%
% State Management
%   - AppData su figura:
%       'CurrentOpts'      : struct (normalizeRows, showCounts, showPerc, cmap, highlightDiag)
%       'P2Controls'       : handle struct a controlli delle opzioni
%       'AxesCMHandle'     : handle uiaxes per heatmap principale
%       'BarAxesHandle'    : handle uiaxes per grafico barre
%       'HistoryP2'        : array/struct storico (gestito da Core/Logic)
%       'CurrentConfMat'   : matrice corrente (gestita da Core/Logic)
%       'CurrentLabels'    : etichette correnti (gestite da Core/Logic)
%
% UX Guidelines
%   - Nessun toolstrip sugli axes; layout coerente col Modulo 1.
%   - Testi, tooltip e tag stabili per consentire automation e test di UI.
%
% Non-Functional
%   - Compatibile con MATLAB App Designer components (uifigure, uitabgroup, uiaxes, …).
%   - Nessun requisito su toolboxes vietate; il caricamento/parse è delegato.
%
% Versioning
%   - UI Preview Mode: se onComputeMetrics non è implementata, viene eseguita
%     demoPopulateMetrics per mostrare un’anteprima coerente con la UI.
%
% NOTE PER REFACTORING FUTURI
%   - Eventuali modifiche alla logica di comparazione/metriche NON devono essere introdotte qui.
%   - Mantenere la stabilità dei Tag (vedi struct T) per non rompere automazioni.
% =====================================================================================

    %% ====== Tag/UI keys & Testi ======
    % Mappa di costanti per Tag degli oggetti UI. I Tag sono contratti stabili per
    %   - individuare widget in callbacks esterni
    %   - evitare hardcoding di stringhe sparse nel codice
    T = struct( ...
      'AxesCM',            'AxesCM', ...
      'LogBoxP2',          'LogBoxP2', ...
      'HistoryTableP2',    'HistoryTableP2', ...
      'TablePerClass',     'TablePerClass', ...
      'LabelGlobalAcc',    'LabelGlobalAcc', ...
      'CompareDropdown',   'CompareDropdown', ...
      'CompareAxesLeft',   'CompareAxesLeft', ...
      'CompareAxesRight',  'CompareAxesRight', ...
      'BarAxes',           'BarAxes', ...
      'FAQScrollPanel',    'FAQScrollPanel', ...
      'SessionStatusLabel','SessionStatusLabel' ...
    );

    % Testi dei pulsanti centralizzati per:
    %   - localizzazione futura
    %   - coerenza visiva
    BTN = struct( ...
      'Back',          '◀ Torna alla schermata principale', ...
      'LoadMat',       '📂 Carica .mat/.csv', ...
      'ChooseDemo',    '🧪 Scegli demo', ...
      'PasteMatrix',   '📝 Incolla matrice', ...
      'Compute',       '🧮 Calcola metriche', ...
      'AddHistory',    '📌 Aggiungi allo storico', ...
      'SessLoad',      '📁 Carica sessione', ...
      'SessSave',      '💾 Salva sessione', ...
      'SessCSV',       '📤 Esporta CSV', ...
      'SessClear',     '🧹 Pulisci cronologia', ...
      'Compare',       '🆚 Confronta' ...
    );

    %% ====== Figura ======
    % Finestra principale dell’applicazione UI del Modulo 2
    fig = uifigure('Name','Problema 2 – Matrici di Confusione', ...
                   'Position',[300 150 1200 700], ...
                   'Color',[0.96,0.96,0.96]);

    % Pulsante Back: chiama backToMain(fig) se disponibile, altrimenti TODO non bloccante
    uibutton(fig,'Text',BTN.Back,'FontSize',12,'FontName','Segoe UI', ...
        'Position',[10 660 230 30], ...
        'ButtonPushedFcn',@(~,~) callOrTodo('backToMain',fig));

    % Contenitore a tab per le 6 sezioni principali
    tg = uitabgroup(fig,'Position',[10 60 1180 570]);

    %% ====== TAB 1 – Info modulo ======
    % Scopo: testo introduttivo, requisiti e note d’uso del Modulo 2
    tabInfo = uitab(tg,'Title','🗞 Info modulo');

    uilabel(tabInfo,'Text','Modulo 2 – Matrici di Confusione', ...
        'FontSize',18,'FontWeight','bold','Position',[20 510 800 30]);

    uitextarea(tabInfo,'Position',[20 230 1140 270],'Editable','off', ...
        'Value',{ ...
        'Obiettivo:', ...
        '- Visualizzare una matrice di confusione (NxN).', ...
        '- Calcolare tasso di riconoscimento per classe e globale.', ...
        '- Testare con matrici diverse (.mat/.csv/demo).', ...
        '', ...
        'Note:', ...
        '- Vietato usare Statistics and Machine Learning Toolbox.', ...
        '- Interfaccia coerente col Modulo 1. Tutta la logica è esterna (Core/Logic).', ...
        '- Tab4/Tab5 riusate: storico, sessione, export, guida.'});

    %% ====== TAB 2 – Matrice di confusione ======
    % Scopo: input della matrice, opzioni di visualizzazione e heatmap principale
    tabCM = uitab(tg,'Title','📊 Matrice');

    % --- Pannello Input (caricamento/incollo/demo)
    panelInput = uipanel(tabCM,'Title','Input matrice','FontName','Segoe UI', ...
        'FontSize',12,'Position',[20 390 520 135],'BackgroundColor',[1 1 1]);

    uibutton(panelInput,'Text',BTN.LoadMat,'Position',[10 60 240 40], ...
        'Tooltip','Carica file .mat (C, labels opz.) o .csv','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onLoadConfMat',fig));

    uibutton(panelInput,'Text',BTN.ChooseDemo,'Position',[270 60 240 40], ...
        'Tooltip','Seleziona una matrice demo pre-caricata','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onChooseDemo',fig));

    uibutton(panelInput,'Text',BTN.PasteMatrix,'Position',[10 15 500 35], ...
        'Tooltip','Incolla testo grezzo di una matrice (CSV o spazi)','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onPasteMatrix',fig));

    % --- Pannello Opzioni Visuali (normalizzazione, show mode, colormap, diagonale)
    panelOpts = uipanel(tabCM,'Title','Opzioni visuali','FontName','Segoe UI', ...
        'FontSize',12,'Position',[560 390 600 135],'BackgroundColor',[1 1 1]);

    % Opzione: normalizzazione per riga (percentuali)
    chkNorm = uicheckbox(panelOpts,'Text','Normalizza righe (%)','Position',[10 65 200 25], ...
        'Value',false,'Tooltip','Mostra percentuali rispetto alla riga');

    % Opzione: evidenziazione diagonale (True Positive)
    chkDiag = uicheckbox(panelOpts,'Text','Evidenzia diagonale','Position',[10 30 200 25], ...
        'Value',true);

    % Show mode: conteggi / percentuali (futuro: entrambi)
    bg = uibuttongroup(panelOpts,'Title','Valori da mostrare','Position',[180 10 190 95]);
    uicontrol(bg,'Style','radiobutton','String','Conteggi','Position',[10 40 180 20],'Tag','counts');
    uicontrol(bg,'Style','radiobutton','String','Percentuali','Position',[10 10 180 20],'Tag','perc');
    bg.SelectedObject = findobj(bg,'Tag','counts');

    % Colormap selezionabile
    uilabel(panelOpts,'Text','Colormap:','Position',[400 65 70 22]);
    ddCMap = uidropdown(panelOpts,'Items',{'parula','turbo','hot','gray'}, ...
        'Value','parula','Position',[470 65 100 22]);

    % Stato opzioni correnti in AppData (consumate da logica esterna)
    setappdata(fig,'CurrentOpts',struct( ...
        'normalizeRows',chkNorm.Value, ...
        'showCounts',true, ...
        'showPerc',false, ...
        'cmap',ddCMap.Value, ...
        'highlightDiag',chkDiag.Value));

    % Handle a controlli (per aggiornamenti mirati da Core/Logic)
    setappdata(fig,'P2Controls', struct('chkNorm',chkNorm,'chkDiag',chkDiag,'bg',bg,'ddCMap',ddCMap));

    % Wiring delle opzioni: la logica di refresh è delegata a onVisOptionsChanged
    cbOpts = @(~,~) callOrTodo('onVisOptionsChanged',fig);
    chkNorm.ValueChangedFcn = cbOpts;
    chkDiag.ValueChangedFcn = cbOpts;
    ddCMap.ValueChangedFcn  = cbOpts;
    bg.SelectionChangedFcn  = @(~,evt) setShowMode(evt,fig);

    % --- Heatmap principale (axes)
    ax = uiaxes(tabCM,'Position',[20 40 920 330],'Tag',T.AxesCM);
    setappdata(fig,'AxesCMHandle', ax);
    axis(ax,'tight'); box(ax,'on'); ax.Toolbar.Visible = 'off';
    xlabel(ax,'Predicted'); ylabel(ax,'True');

    % --- Azioni e Log (compute, add to history, log breve)
    uibutton(tabCM,'Text',BTN.Compute,'Position',[950 300 220 40],'FontSize',14, ...
        'Tooltip','Calcola tassi per-classe e globale (Core)','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onComputeMetrics',fig));

    uibutton(tabCM,'Text',BTN.AddHistory,'Position',[950 245 220 40],'FontSize',14, ...
        'Tooltip','Aggiunge la matrice corrente allo storico (Tab4)','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onAddToHistory',fig));

    uitextarea(tabCM,'Position',[950 80 220 150],'Editable','off','Tag',T.LogBoxP2, ...
        'Value',{'Log breve operazioni P2.'});

    %% ====== TAB 3 – Metriche & Confronto ======
    % Scopo: mostrare metriche per-classe e globali + mini-report e grafico
    tabMetrics = uitab(tg,'Title','📈 Metriche');

    % Selettore dallo storico per popolare metriche
    uidropdown(tabMetrics, ...
        'Items',{'-- storico vuoto --'}, ...
        'Position',[20 510 440 30], ...
        'Tag','MetricsHistoryDropdown', ...
        'Tooltip','Scegli una voce dallo storico per visualizzarne le metriche', ...
        'ValueChangedFcn',@(~,~) onSelectMetricsFromHistory(fig));

    % Badge/label accuratezza globale
    uilabel(tabMetrics,'Text','Accuratezza Globale:', ...
        'Position',[20 470 220 32],'FontSize',16,'FontWeight','bold');
    uilabel(tabMetrics,'Text','–','Tag',T.LabelGlobalAcc, ...
        'Position',[240 470 200 32],'FontSize',20,'FontWeight','bold','FontColor',[0 0.5 0]);

    % Tabella metrica per-classe
    tbl = uitable(tabMetrics,'Position',[20 210 560 250],'Tag',T.TablePerClass, ...
        'ColumnName',{'Classe','True Positives','Totale','Accuratezza %'}, ...
        'ColumnEditable',[false false false false], ...
        'RowName',[]);
    try
        % Suggerimento layout: formati e centratura (tolleranti a release vecchie)
        tbl.ColumnFormat = {'char','numeric','numeric','numeric'};
        sCenter = uistyle('HorizontalAlignment','center');
        addStyle(tbl,sCenter,'column',1:4);
    catch
        % Non interrompere la UI in release prive di queste API
    end

    % Grafico a barre per accuratezza per-classe
    axBar = uiaxes(tabMetrics,'Position',[600 210 560 250],'Tag',T.BarAxes);
    setappdata(fig,'BarAxesHandle', axBar);
    axBar.Toolbar.Visible = 'off'; box(axBar,'on');
    title(axBar,'Accuratezza per classe (%)');
    xlabel(axBar,'Classe'); ylabel(axBar,'Acc %');
    try
        axBar.XTickLabelRotation = 25;
    catch
    end

    % Mini-report (sostituisce textarea: più leggibile e strutturato)
    rpt = uipanel(tabMetrics,'Position',[20 40 1140 150], ...
        'Title','Report metriche','BackgroundColor',[1 1 1], ...
        'FontName','Segoe UI','FontSize',12,'Tag','MetricsReportPanel');

    uilabel(rpt,'Text','Accuratezza globale: –','Tag','RptGlobal', ...
        'Position',[12 92 1110 24],'FontSize',14,'FontWeight','bold');

    uilabel(rpt,'Text','Migliore: –','Tag','RptBest', ...
        'Position',[12 66 1110 22],'FontSize',13);

    uilabel(rpt,'Text','Peggiore: –','Tag','RptWorst', ...
        'Position',[12 42 1110 22],'FontSize',13);

    uilabel(rpt,'Text','Suggerimento: —','Tag','RptTip', ...
        'Position',[12 16 1110 22],'FontSize',12);

    % Popolamento iniziale del dropdown/tab se History già disponibile
    refreshP2History(fig);     % helper esterno, se presente

    %% ====== TAB 4 – Confronto ======
    % Scopo: confronto visivo e numerico fra due matrici (A/B)
    tabCompare = uitab(tg,'Title','🆚 Confronto');

    uilabel(tabCompare,'Text','Sinistra = matrice corrente o scelta A   |   Destra = scelta B dallo storico', ...
        'Position',[20 510 820 22]);

    % Dropdown di selezione A/B (A vuoto = usa corrente)
    uidropdown(tabCompare, ...
        'Items',{'-- storico vuoto --'}, ...
        'Position',[20 475 500 28], ...
        'Tag','CompareDropLeft', ...
        'Tooltip','Scelta A (sinistra): se lasci vuoto usa la matrice corrente');
    uidropdown(tabCompare, ...
        'Items',{'-- storico vuoto --'}, ...
        'Position',[660 475 500 28], ...
        'Tag','CompareDropRight', ...
        'Tooltip','Scelta B (destra): elemento dallo storico');

    % Azione di confronto (delegata)
    uibutton(tabCompare,'Text','🆚 Confronta','Position',[540 474 100 30], ...
        'ButtonPushedFcn',@(~,~) onCompare(fig));

    % Heatmap affiancate per confronto
    axL = uiaxes(tabCompare,'Position',[20 232 560 220],'Tag',T.CompareAxesLeft);
    axL.Toolbar.Visible = 'off'; axis(axL,'tight'); box(axL,'on');

    axR = uiaxes(tabCompare,'Position',[600 232 560 220],'Tag',T.CompareAxesRight);
    axR.Toolbar.Visible = 'off'; axis(axR,'tight'); box(axR,'on');

    % Riepilogo numerico del confronto (global/per-class)
    uitextarea(tabCompare, ...
        'Position',[20 40 1140 170], ...
        'Editable','off','Tag','CompareSummaryBox', ...
        'Value',{'Riepilogo confronto (globale e per classe) aparecerà qui.'});

    % Eventuale refresh iniziale (se storico già pronto)
    refreshP2History(fig);

    %% ====== TAB 5 – Sessione (storico, stato, export) ======
    % Scopo: gestione sessione del Modulo 2 (storico, status, export CSV, log esteso)
    tabSession = uitab(tg,'Title','🗃️ Sessione');

    % Storico (preview) – la sorgente dati è fornita dal Core/Logic
    uitable(tabSession,'Position',[20 320 750 210], ...
        'ColumnName',{'Nome','Data','NxN','AccGlobale','Note'}, ...
        'ColumnWidth',{250,130,80,110,180}, ...
        'RowName',[],'Tag',T.HistoryTableP2);

    % Stato operazioni corrente
    statusPanel = uipanel(tabSession,'Title','Stato operazioni', ...
        'Position',[840 320 320 210],'FontName','Segoe UI','FontSize',12, ...
        'BackgroundColor',[1 1 1]);

    uilabel(statusPanel,'Text',sprintf('- Ultima operazione: Nessuna\n- Stato sessione: Inattiva\n- Ultimo export: --'), ...
        'Position',[10 20 290 170],'FontName','Segoe UI','FontSize',13, ...
        'Tag',T.SessionStatusLabel,'HorizontalAlignment','left','WordWrap','on');

    % Pulsanti gestione sessione (fallback a nomi generici se le versioni P2 non esistono)
    uibutton(tabSession,'Text',BTN.SessLoad,'Position',[20 250 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'loadSessionP2','loadSession'},fig));

    uibutton(tabSession,'Text',BTN.SessSave,'Position',[315 250 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'saveSessionP2','saveSession'},fig));

    uibutton(tabSession,'Text',BTN.SessCSV,'Position',[605 250 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'exportSessionCSV_P2','exportSessionCSV'},fig));

    uibutton(tabSession,'Text',BTN.SessClear,'Position',[900 250 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'clearHistoryP2','clearHistory'},fig));

    % Log dettagliato della sessione P2 (solo visual, dati dal Core/Logic)
    uitextarea(tabSession,'Position',[20 20 1140 190],'Editable','off', ...
        'Tag','FullLogBoxP2','Value',{'Log dettagliato delle operazioni del Modulo 2.'});

    % Abilita doppio click sulla tabella storico se helper disponibile
    tblHist = findobj(fig,'Tag',T.HistoryTableP2);
    if ~isempty(tblHist)
        try
            if exist('enableHistoryTableDoubleClickP2','file')==2
                enableHistoryTableDoubleClickP2(fig);
            elseif exist('enableHistoryTableDoubleClick','file')==2
                enableHistoryTableDoubleClick(fig);
            else
                % Fallback: associa un handler minimo al click singolo
                tblHist.CellSelectionCallback = @(tbl,event) callOrTodo({'onHistorySelectP2','onHistorySelect'},fig,event);
            end
        catch ME
            % Non bloccare la UI su failure di wiring opzionale
            warning('%s - [P2] enable double click storico non configurato: %s', ME.identifier, ME.message);
        end
    end

    %% ====== TAB 6 – Guida (FAQ) ======
    % Scopo: sezione informativa con domande/risposte collassabili
    tabHelp = uitab(tg,'Title','❓ Guida');
    
    uilabel(tabHelp,'Text','Domande frequenti (FAQ)', ...
        'Position',[20 510 800 30],'FontSize',18,'FontWeight','bold','FontName','Segoe UI');
    
    scrollPanel = uipanel(tabHelp,'Position',[20 20 1140 480], ...
        'Scrollable','on','BackgroundColor',[1 1 1],'Tag',T.FAQScrollPanel);
    
    % ===================== Dataset Q/A (estendibile) =====================
    domande = {
     'Che cos’è una matrice di confusione e perché è utile?'
     'Che formato deve avere la matrice di confusione?'
     'Posso caricare variabili direttamente dal Workspace?'
     'Come carico i dati da .mat o .csv?'
     'Cosa deve contenere il file .mat per essere letto correttamente?'
     'Il .csv deve avere per forza un header?'
     'Perché a volte vedo “labels rigenerate automaticamente”?'
     'Cosa significa normalizzare per riga (rows %)?'
     'Qual è la differenza tra accuratezza per classe e globale?'
     'Come viene calcolata l’accuratezza per classe?'
     'Come viene calcolata l’accuratezza globale?'
     'Perché vedo NaN nelle metriche di una classe?'
     'Perché alcuni CSV danno errore “NaN/Inf rilevati”?'
     'Posso confrontare due matrici di dimensioni diverse?'
     'Come funziona il Confronto (Tab “🆚 Confronto”)?'
     'Cosa indica il simbolo Δ nel confronto?'
     'A cosa serve evidenziare la diagonale nella heatmap?'
     'Perché a volte i numeri nelle celle sono bianchi o neri?'
     'Come cambio la colormap?'
     'A cosa servono i demo (base, unbalanced, cross)?'
     'Posso aggiungere demo personalizzati? In che cartella?'
     'Come salvo la sessione e cosa viene salvato?'
     'Come carico una sessione salvata?'
     'Cosa c’è nell’Export CSV della Tab “🗃️ Sessione”?'
     'Perché ci sono due log (breve e dettagliato)?'
     'Dove vedo lo stato dell’ultima operazione?'
     'Perché la Tab “Metriche” mostra righe vuote?'
     'Perché la heatmap non mostra percentuali/conteggi?'
     'Cosa succede se la matrice non è quadrata?'
     'Dove finiscono i file salvati/esportati?'
     'Posso modificare le etichette delle classi?'
     'Perché non usiamo lo Statistics and Machine Learning Toolbox?'
     'Cosa succede se cancello la cronologia?'
     'Come faccio a capire quale dei due modelli è “migliore”?'
     'Posso esportare anche le figure?'
    };
    
    risposte = {
     "È una tabella NxN in cui le righe sono le classi vere e le colonne le classi predette. " + ...
     "Permette di capire dove il modello sbaglia e di confrontare modelli in modo trasparente."
    
     "Una matrice quadrata NxN con valori numerici >= 0. Le righe rappresentano le classi vere, le colonne le predette. " + ...
     "La validazione è gestita da validateConfMat (Core)."
    
     "Sì. Se passi una variabile numerica (NxN) o una table a importConfMat, viene interpretata come matrice in memoria."
    
     "Usa “Carica .mat/.csv”. Per i .mat deve esistere C (NxN) e opzionalmente labels (1xN). " + ...
     "Per i .csv viene usato readtable: se c’è l’header, diventa labels."
    
     "Il .mat deve contenere almeno la variabile C (NxN). Se c’è labels ma con lunghezza non coerente, le labels vengono rigenerate."
    
     "No. Se manca l’header o non è coerente con le colonne, il sistema genera labels di fallback: “Class 1..N”."
    
     "Significa che le etichette lette non corrispondono al numero di colonne della matrice. " + ...
     "In questo caso importConfMat ricrea labels coerenti e annota la nota in meta.note."
    
     "Ogni cella viene divisa per la somma della sua riga (classe vera). Utile quando i supporti per classe sono sbilanciati."
    
     "Accuratezza per classe: quota di corretti per singola classe. Globale: corretti totali / campioni totali."
    
     "acc_i = C(i,i) / max(sum(C(i,:)),1). Se la riga è vuota acc_i = NaN."
    
     "accG = sum(diag(C)) / max(sum(C,'all'),1). È mostrata nel badge “Accuratezza Globale”."
    
     "Una riga tutta zero implica supporto nullo per quella classe; la percentuale non è definibile → NaN/“n/d”."
    
     "Il CSV contiene celle non numeriche o simboli fuori posto (delimitatori/virgolette). Ripulisci l’input o usa il .mat."
    
     "No, per confrontare bisogna avere lo stesso set di classi (stessi nomi). Le classi vengono allineate per nome con intersect."
    
     "Seleziona A e B (o usa la matrice corrente a sinistra) e premi “Confronta”. " + ...
     "Vedrai due heatmap, la tabella con A%, B% e Δ, e un riepilogo di guadagni/perdite principali."
    
     "Δ è la differenza in punti percentuali tra A e B (A − B). Verde se A migliore, rosso se peggiore."
    
     "Evidenzia la diagonale (true positives) per leggere immediatamente dove il modello è più corretto."
    
     "Il colore del testo si adatta alla luminanza: bianco su fondo scuro, nero su fondo chiaro, per massima leggibilità."
    
     "Dal pannello “Opzioni visuali” nella Tab Matrice: seleziona la colormap desiderata (parula, turbo, hot, gray)."
    
     "Servono per provare velocemente la UI e le funzioni: base (realistica), unbalanced (supporti molto diversi), cross (due classi molto confuse)."
    
     "Sì: salva i tuoi file MAT/CSV in Data/Problem_2/Sessions/demoMatrices. La funzione resolvePathsP2 crea/migra le cartelle corrette."
    
     "Salva HistoryP2, matrice/labels correnti, opzioni UI e snapshot tabella/stato. Viene generato un .mat in Data/Problem_2/Sessions."
    
     "Usa “Carica sessione” e seleziona il file .mat salvato. Verranno ripristinati storico, selezioni e viste principali."
    
     "Un CSV con Nome, Data, NxN, AccGlobale e Note (contenuto della Tab “Sessione”). Utile per report veloci."
    
     "Il log breve (Tab Matrice) riporta azioni recenti; il log esteso (Tab “Sessione”) mantiene la cronologia completa con timestamp."
    
     "Nel pannello destro “Stato operazioni” (Tab “Sessione”). Mostra ultima operazione, stato sessione ed eventuale ultimo export."
    
     "Se una classe non ha campioni (supporto 0), acc% mostra “n/d” e le righe possono apparire vuote: è voluto."
    
     "Controlla “Opzioni visuali” (conteggi/percentuali) nella Tab Matrice. La heatmap può mostrare solo conteggi, solo %, o entrambi."
    
     "Se la matrice non è quadrata, viene respinta dalla validazione. Correggi l’input o verifica il CSV (colonne/righe)."
    
     "Per default in <root>/Data/Problem_2/… (Sessions/Exports). Il path è risolto da resolvePathsP2."
    
     "Le labels vengono lette da MAT/CSV. Al momento non c’è editor integrato: fornisci il file con le etichette corrette."
    
     "Per vincolo dell’esercitazione: tutte le elaborazioni sono implementate senza dipendenze da quel toolbox."
    
     "Pulisce HistoryP2, viste (heatmap, metriche, confronto) e azzera i log. Operazione irreversibile: viene richiesta conferma."
    
     "Osserva “Accuratezza globale” e la colonna Δ per classe nel confronto. Il migliore ha accG più alto e Δ mediamente positivo."
    
     "Le figure/rapporti non sono salvati automaticamente. Puoi esportare i dati (CSV) o salvare la sessione e generare grafici esternamente."
    };
    
    % ===================== Render collassabile =====================
    rowH = 150;      % altezza slot per Q/A
    padT = 40;       % margine superiore
    internalHeight = padT + numel(domande)*rowH + 20;
    internalPanel  = uipanel(scrollPanel,'Position',[0 0 1080 internalHeight], ...
        'BackgroundColor',[1 1 1],'BorderType','none');
    
    y = internalHeight - padT;
    for i = 1:numel(domande)
        % Header domanda
        btn = uibutton(internalPanel,'Text',['➕ ' domande{i}], ...
            'FontSize',14,'FontName','Segoe UI', ...
            'Position',[10 y-30 1060 30], 'HorizontalAlignment','left', ...
            'BackgroundColor',[1 1 1]);
    
        % Corpo risposta (multiline, inizialmente nascosto)
        txt = uitextarea(internalPanel, ...
            'Value', splitlines(risposte{i}), ...
            'Editable','off','Visible','off','FontSize',13,'FontName','Segoe UI', ...
            'Position',[20 y-140 1040 110]);
    
        % Toggle
        btn.ButtonPushedFcn = @(src,~) toggleFAQEntry(src, txt);
        y = y - rowH;
    end
    
    drawnow; 
    scroll(scrollPanel,'top');

    %% ====== Footer ======
    % Footer modulare: se esiste addFooter, la usa; altrimenti fallback testuale
    footerFrame = uipanel(fig,'Position',[10 10 1180 50], ...
        'BackgroundColor',[0.94 0.94 0.94],'BorderType','line','BorderWidth',1);
    addFooterIfAny(footerFrame);

    %% ====== AppData iniziali ======
    % Inizializza contenitori di stato senza assumere la presenza del Core
    if ~isappdata(fig,'HistoryP2'), setappdata(fig,'HistoryP2',[]); end
    if ~isappdata(fig,'CurrentConfMat'), setappdata(fig,'CurrentConfMat',[]); end
    if ~isappdata(fig,'CurrentLabels'), setappdata(fig,'CurrentLabels',{}); end

    % Stato iniziale sessione (se helper disponibile)
    if exist('setSessionStatus','file')==2
        setSessionStatus(fig,'Inizializzazione',true,[],'ok');
    end

end

%% ====== NESTED HELPERS (solo UI) =====================================================
% Nota: helper UI-Only, senza alcuna elaborazione dati. Mantenerli leggeri,
%       idempotenti e tolleranti all’assenza delle dipendenze esterne.

function callOrTodo(fcn, varargin)
% CALLORTODO  Prova a chiamare una o più funzioni esterne; in fallback mostra TODO.
% INPUT
%   fcn      : string o cell-array di nomi funzione candidati (in ordine di preferenza)
%   varargin : argomenti aggiuntivi passati a feval (tipicamente fig, event, ...)
%
% BEHAVIOR
%   - Scorre l’elenco e invoca la prima funzione disponibile (exist(...)=2).
%   - In caso di eccezione nel feval, stampa un warning non bloccante.
%   - Se nessuna disponibile:
%       * per 'onComputeMetrics' esegue una DEMO di popolamento metriche (UI preview)
%       * altrimenti stampa un messaggio "TODO: implementare ..."
%
% SIDE EFFECTS
%   - Per la DEMO, popola Tab3 con dati fake tramite demoPopulateMetrics(fig).
%
% NOTE
%   - Non genera errori fatali: mantiene la UI responsiva anche in assenza del Core.
    names = {};
    if ischar(fcn) || isstring(fcn), names = {char(fcn)}; end
    if iscell(fcn), names = fcn; end

    % Prova le opzioni in ordine
    for k = 1:numel(names)
        if exist(names{k},'file')==2
            try
                feval(names{k}, varargin{:});
                return;
            catch ME
                warning('[P2] Errore chiamando %s: %s', names{k}, ME.message);
                return;
            end
        end
    end

    % Fallback DEMO per la sola compute metrics
    if ~isempty(names) && strcmp(names{1},'onComputeMetrics')
        demoPopulateMetrics(fig);  % popola Tab3 con dati fake
        msg = 'Demo: metriche generate (mock) per anteprima UI. Collega la logica per i dati reali.';
        disp(msg);
        try
            uialert(fig,msg,'DEMO','Icon','info');
        catch
        end
        return;
    end

    % TODO generico per le altre azioni
    msg = sprintf('TODO: implementare %s (UI-only per ora)', strjoin(names, ' / '));
    disp(msg);
    try
        uialert(fig, msg, 'TODO','Icon','info');
    catch
    end
end

function demoPopulateMetrics(figH)
% DEMOPOPULATEMETRICS  Popola la Tab "Metriche" con dati sintetici realistici.
% PURPOSE
%   Fornire un’anteprima visiva coerente dell’area Metriche quando il Core non è
%   ancora integrato. Non salva stato persistente.
%
% INPUT
%   figH : handle della uifigure principale
%
% GUARANTEES
%   - Non solleva errori se widget non sono ancora costruiti (check exist/findobj)
%   - Non modifica 'HistoryP2' o 'CurrentConfMat'
    N = 6;
    labels = compose('Class %d', 1:N).';
    totRow = randi([30 150], N, 1);          % campioni per classe
    acc_i  = 0.55 + 0.40*rand(N,1);          % 55%..95% per classe
    TP     = floor(acc_i .* totRow);
    acc_g  = sum(TP) / max(sum(totRow),1);   % accuratezza globale

    % Badge accuratezza globale
    lbl = findobj(figH,'Tag','LabelGlobalAcc');
    if ~isempty(lbl), lbl.Text = sprintf('%.1f%%', 100*acc_g); end

    % Tabella per-classe
    tbl = findobj(figH,'Tag','TablePerClass');
    if ~isempty(tbl)
        data = [labels(:), num2cell(TP), num2cell(totRow), num2cell(round(100*acc_i,1))];
        tbl.Data = data;
        try
            tbl.ColumnFormat = {'char','numeric','numeric','numeric'};
        catch
        end
    end

    % Grafico barre
    axBar = findobj(figH,'Tag','BarAxes');
    if ~isempty(axBar)
        cla(axBar,'reset'); axBar.Toolbar.Visible = 'off'; box(axBar,'on');
        bar(axBar, 100*acc_i); ylim(axBar,[0 100]);
        xticks(axBar,1:N); xticklabels(axBar,labels);
        try
            axBar.XTickLabelRotation = 25;
        catch
        end
        title(axBar,'Accuratezza per classe (%)');
        xlabel(axBar,'Classe'); ylabel(axBar,'Acc %');
    end
end

function setShowMode(evt, figH)
% SETSHOWMODE  Aggiorna lo "show mode" (conteggi/percentuali) nelle opzioni correnti.
% INPUT
%   evt  : event data del SelectionChangedFcn (evt.NewValue.Tag = 'counts'|'perc')
%   figH : handle della uifigure principale
%
% EFFECTS
%   - Aggiorna AppData 'CurrentOpts' e notifica la logica esterna con onVisOptionsChanged.
    opts = getappdata(figH,'CurrentOpts');
    tag = get(evt.NewValue,'Tag');
    switch tag
        case 'counts'
            opts.showCounts = true;  opts.showPerc = false;
        case 'perc'
            opts.showCounts = false; opts.showPerc = true;
        otherwise
            % Estensione futura: modalità "entrambi"
            opts.showCounts = true;  opts.showPerc = true;
    end
    setappdata(figH,'CurrentOpts',opts);
    callOrTodo('onVisOptionsChanged',figH);
end

function toggleFAQEntry(btn, answer, scrollParent)
% TOGGLEFAQENTRY  Espande/Collassa un elemento FAQ con aggiornamento dello scroll.
% INPUT
%   btn          : handle del pulsante domanda
%   answer       : handle della textarea risposta
%   scrollParent : pannello scrollabile contenitore
%
% UX
%   - Cambia il simbolo ➕/➖ nel testo del bottone
%   - Mantiene lo scroll consistente dopo il toggle
    isVis = strcmp(answer.Visible,'on');
    if isVis
        answer.Visible = 'off';
        if startsWith(btn.Text,'➖'), btn.Text = ['➕' btn.Text(2:end)]; end
    else
        answer.Visible = 'on';
        if startsWith(btn.Text,'➕'), btn.Text = ['➖' btn.Text(2:end)]; end
    end
    drawnow;
    try
        scroll(scrollParent,'top');
    catch
    end
end

function addFooterIfAny(parent)
% ADDFOOTERIFANY  Inserisce un footer personalizzato se disponibile, altrimenti fallback.
% INPUT
%   parent : pannello contenitore nella zona footer
%
% CONTRACT
%   - Se esiste addFooter(parent) esterno, viene utilizzato.
%   - In fallback crea due label descrittive.
    if exist('addFooter','file')==2
        try
            addFooter(parent);
            return;
        catch
        end
    end
    uilabel(parent,'Text','Approcci e Sistemi 2024/2025 – Modulo 2', ...
        'Position',[15 15 400 22],'FontName','Segoe UI','FontSize',12);
    uilabel(parent,'Text','UI-only build. La logica verrà collegata (Core/Logic).', ...
        'Position',[420 15 400 22],'FontName','Segoe UI','FontSize',11);
end