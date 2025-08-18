function confusionMatrixUI()
    % CONFUSIONMATRIXUI
    % ------------------------------------------------------------------------------
    % GUI del Problema 2 – Analisi Matrici di Confusione (solo UI, no logica pesante)
    % 5 Tab come nel Problema 1:
    %   1) Info modulo
    %   2) Matrice di confusione (input + heatmap + opzioni)
    %   3) Metriche & Confronto
    %   4) Sessione (storico, stato, export)
    %   5) Guida (FAQ)
    %
    % Linee guida:
    % - Nessuna elaborazione qui dentro. I callback:
    %     1) Se esiste una funzione di progetto con stesso nome -> la chiamano
    %     2) Altrimenti stampano un "TODO: ..." in Command Window
    % - Tag e AppData centralizzati per coerenza con P1
    % ------------------------------------------------------------------------------
    
    %% ====== Tag/UI keys & Testi ======
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
    fig = uifigure('Name','Problema 2 – Matrici di Confusione', ...
                   'Position',[300 150 1200 700], ...
                   'Color',[0.96,0.96,0.96]);
    
    % Pulsante "Back": usa backToMain se esiste, altrimenti TODO
    uibutton(fig,'Text',BTN.Back,'FontSize',12,'FontName','Segoe UI', ...
        'Position',[10 660 230 30], ...
        'ButtonPushedFcn',@(~,~) callOrTodo('backToMain',fig));
    
    % TabGroup principale
    tg = uitabgroup(fig,'Position',[10 60 1180 570]);
    
    %% ====== TAB 1 – Info modulo ======
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
    tabCM = uitab(tg,'Title','📊 Matrice');
    
    % --- Pannello Input
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
    
    % --- Pannello Opzioni Visuali
    panelOpts = uipanel(tabCM,'Title','Opzioni visuali','FontName','Segoe UI', ...
        'FontSize',12,'Position',[560 390 600 135],'BackgroundColor',[1 1 1]);
    
    % Normalize rows
    chkNorm = uicheckbox(panelOpts,'Text','Normalizza righe (%)','Position',[10 65 200 25], ...
        'Value',false,'Tooltip','Mostra percentuali rispetto alla riga');
    
    % Evidenzia diagonale
    chkDiag = uicheckbox(panelOpts,'Text','Evidenzia diagonale','Position',[10 30 200 25], ...
        'Value',true);
    
    % Show values (btngroup: count / % / entrambi)
    bg = uibuttongroup(panelOpts,'Title','Valori da mostrare','Position',[180 10 190 95]);
    uicontrol(bg,'Style','radiobutton','String','Conteggi','Position',[10 40 180 20],'Tag','counts');
    uicontrol(bg,'Style','radiobutton','String','Percentuali','Position',[10 10 180 20],'Tag','perc');
    bg.SelectedObject = findobj(bg,'Tag','counts');
    
    % Colormap
    uilabel(panelOpts,'Text','Colormap:','Position',[400 65 70 22]);
    ddCMap = uidropdown(panelOpts,'Items',{'parula','turbo','hot','gray'}, ...
        'Value','parula','Position',[470 65 100 22]);
    
    % AppData per opzioni correnti
    setappdata(fig,'CurrentOpts',struct( ...
        'normalizeRows',chkNorm.Value, ...
        'showCounts',true, ...
        'showPerc',false, ...
        'cmap',ddCMap.Value, ...
        'highlightDiag',chkDiag.Value));

    setappdata(fig,'P2Controls', struct('chkNorm',chkNorm,'chkDiag',chkDiag,'bg',bg,'ddCMap',ddCMap));
    
    % Cambio opzioni -> solo TODO + refresh visuale delegato
    cbOpts = @(~,~) callOrTodo('onVisOptionsChanged',fig);
    chkNorm.ValueChangedFcn = cbOpts;
    chkDiag.ValueChangedFcn = cbOpts;
    ddCMap.ValueChangedFcn  = cbOpts;
    bg.SelectionChangedFcn  = @(~,evt) setShowMode(evt,fig);
    
    % --- Heatmap axes
    ax = uiaxes(tabCM,'Position',[20 40 920 330],'Tag',T.AxesCM);
    setappdata(fig,'AxesCMHandle', ax);
    axis(ax,'tight'); box(ax,'on'); ax.Toolbar.Visible = 'off';
    xlabel(ax,'Predicted'); ylabel(ax,'True');
    
    % --- Azioni e Log
    uibutton(tabCM,'Text',BTN.Compute,'Position',[950 300 220 40],'FontSize',14, ...
        'Tooltip','Calcola tassi per-classe e globale (Core)','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onComputeMetrics',fig));
    
    uibutton(tabCM,'Text',BTN.AddHistory,'Position',[950 245 220 40],'FontSize',14, ...
        'Tooltip','Aggiunge la matrice corrente allo storico (Tab4)','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onAddToHistory',fig));
    
    uitextarea(tabCM,'Position',[950 80 220 150],'Editable','off','Tag',T.LogBoxP2, ...
        'Value',{'Log breve operazioni P2.'});
    
    %% ====== TAB 3 – Metriche & Confronto ======
    tabMetrics = uitab(tg,'Title','📈 Metriche');

    % Dropdown storico (default: ultimo)
    uidropdown(tabMetrics, ...
        'Items',{'-- storico vuoto --'}, ...
        'Position',[20 510 440 30], ...
        'Tag','MetricsHistoryDropdown', ...
        'Tooltip','Scegli una voce dallo storico per visualizzarne le metriche', ...
        'ValueChangedFcn',@(~,~) onSelectMetricsFromHistory(fig));
    
    % Badge accuratezza globale
    uilabel(tabMetrics,'Text','Accuratezza Globale:', ...
        'Position',[20 470 220 32],'FontSize',16,'FontWeight','bold');
    uilabel(tabMetrics,'Text','–','Tag',T.LabelGlobalAcc, ...
        'Position',[240 470 200 32],'FontSize',20,'FontWeight','bold','FontColor',[0 0.5 0]);
    
    % Tabella per-classe
    tbl = uitable(tabMetrics,'Position',[20 210 560 250],'Tag',T.TablePerClass, ...
        'ColumnName',{'Classe','True Positives','Totale','Accuratezza %'}, ...
        'ColumnEditable',[false false false false], ...
        'RowName',[]);
    try
        tbl.ColumnFormat = {'char','numeric','numeric','numeric'};

        % centra tutte le colonne (se disponibile)
        sCenter = uistyle('HorizontalAlignment','center');
        addStyle(tbl,sCenter,'column',1:4);
    catch
    end
    
    % Grafico a barre (Acc per classe)
    axBar = uiaxes(tabMetrics,'Position',[600 210 560 250],'Tag',T.BarAxes);
    setappdata(fig,'BarAxesHandle', axBar);  

    axBar.Toolbar.Visible = 'off'; box(axBar,'on');
    title(axBar,'Accuratezza per classe (%)');
    xlabel(axBar,'Classe'); ylabel(axBar,'Acc %');
    try 
        axBar.XTickLabelRotation = 25; 
    catch 
    end
    
    % Pannello note/suggerimenti (testo dinamico)
    uitextarea(tabMetrics,'Position',[20 40 1140 150], ...
        'Editable','off','Tag','MetricsNotesBox', ...
        'Value',{'Suggerimenti e osservazioni verranno mostrati qui.'});
    
    % popolamento iniziale dropdown tab3 (se c’è storico)
    refreshP2History(fig);     % (funzione helper)

    %% ====== TAB 4 – Confronto ======
    tabCompare = uitab(tg,'Title','🆚 Confronto');
    
    uilabel(tabCompare,'Text','Sinistra = matrice corrente o scelta A   |   Destra = scelta B dallo storico', ...
        'Position',[20 510 820 22]);

    % Dropdown A/B
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

    % Bottone Confronta
    uibutton(tabCompare,'Text','🆚 Confronta','Position',[540 474 100 30], ...
        'ButtonPushedFcn',@(~,~) onCompare(fig));
    
    % Heatmap affiancate (più compatte per lasciare spazio al riepilogo)
    axL = uiaxes(tabCompare,'Position',[20 232 560 220],'Tag',T.CompareAxesLeft);
    axL.Toolbar.Visible = 'off'; axis(axL,'tight'); box(axL,'on');

    axR = uiaxes(tabCompare,'Position',[600 232 560 220],'Tag',T.CompareAxesRight);
    axR.Toolbar.Visible = 'off'; axis(axR,'tight'); box(axR,'on');

    % Riepilogo numerico confronto
    uitextarea(tabCompare, ...
        'Position',[20 40 1140 170], ...
        'Editable','off','Tag','CompareSummaryBox', ...
        'Value',{'Riepilogo confronto (globale e per classe) aparecerà qui.'});
    
    % popolamento iniziale dropdown tab4 (se c’è storico)
    refreshP2History(fig);   
    
    %% ====== TAB 5 – Sessione (storico, stato, export) ======
    tabSession = uitab(tg,'Title','🗃️ Sessione');
    
    % Storico P2
    uitable(tabSession,'Position',[20 320 750 210], ...
        'ColumnName',{'Nome','Data','NxN','AccGlobale','Note'}, ...
        'ColumnWidth',{250,130,80,110,180}, ...
        'RowName',[],'Tag',T.HistoryTableP2);
    
    % Stato operazioni
    statusPanel = uipanel(tabSession,'Title','Stato operazioni', ...
        'Position',[840 320 320 210],'FontName','Segoe UI','FontSize',12, ...
        'BackgroundColor',[1 1 1]);
    
    uilabel(statusPanel,'Text',sprintf('- Ultima operazione: Nessuna\n- Stato sessione: Inattiva\n- Ultimo export: --'), ...
        'Position',[10 20 290 170],'FontName','Segoe UI','FontSize',13, ...
        'Tag',T.SessionStatusLabel,'HorizontalAlignment','left','WordWrap','on');
    
    % Pulsanti gestione sessione (riuso nomi P1 se presenti)
    uibutton(tabSession,'Text',BTN.SessLoad,'Position',[20 250 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'loadSessionP2','loadSession'},fig));
    
    uibutton(tabSession,'Text',BTN.SessSave,'Position',[315 250 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'saveSessionP2','saveSession'},fig));
    
    uibutton(tabSession,'Text',BTN.SessCSV,'Position',[605 250 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'exportSessionCSV_P2','exportSessionCSV'},fig));
    
    uibutton(tabSession,'Text',BTN.SessClear,'Position',[900 250 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'clearHistoryP2','clearHistory'},fig));
    
    % Log dettagliato
    uitextarea(tabSession,'Position',[20 20 1140 190],'Editable','off', ...
        'Tag','FullLogBoxP2','Value',{'Log dettagliato delle operazioni del Modulo 2.'});
    
    % Abilita doppio click storico, se avete già funzione analoga
    tblHist = findobj(fig,'Tag',T.HistoryTableP2);
    if ~isempty(tblHist)
        try
            % Se avete una funzione dedicata al P2
            if exist('enableHistoryTableDoubleClickP2','file')==2
                enableHistoryTableDoubleClickP2(fig);
            elseif exist('enableHistoryTableDoubleClick','file')==2
                enableHistoryTableDoubleClick(fig);
            else
                % fallback: wire minimo al click singolo
                tblHist.CellSelectionCallback = @(tbl,event) callOrTodo({'onHistorySelectP2','onHistorySelect'},fig,event);
            end
        catch ME
            warning('%s - [P2] enable double click storico non configurato: %s', ME.identifier, ME.message);
        end
    end
    
    %% ====== TAB 6 – Guida (FAQ) ======
    tabHelp = uitab(tg,'Title','❓ Guida');
    
    uilabel(tabHelp,'Text','Domande frequenti (FAQ)', ...
        'Position',[20 510 800 30],'FontSize',18,'FontWeight','bold','FontName','Segoe UI');
    
    scrollPanel = uipanel(tabHelp,'Position',[20 20 1140 480], ...
        'Scrollable','on','BackgroundColor',[1 1 1],'Tag',T.FAQScrollPanel);
    
    % Contenuti FAQ (coerenti con P2)
    domande = {
     'Che formato deve avere la matrice di confusione?'
     'Come carico i dati da .mat o .csv?'
     'Cosa significa normalizzare per riga?'
     'Come viene calcolata l''accuratezza per classe?'
     'Come salvo risultati e figure?'
     'Posso confrontare due matrici diverse?'
     'Perché vedo NaN nelle metriche di una classe?'
    };
    risposte = {
     'Una matrice quadrata NxN con valori >= 0. Le righe rappresentano le classi vere, le colonne le predette.'
     'Usa "Carica .mat/.csv". Il .mat dovrebbe contenere C (NxN) e, opzionalmente, labels (1xN). Il .csv può avere header.'
     'La percentuale di ogni cella è divisa per la somma di riga (True class). Utile per confronti quando le classi sono sbilanciate.'
     'acc_i = C(i,i) / max(sum(C(i,:)),1). L''accuratezza globale è sum(diag(C)) / max(sum(C,''all''),1).'
     'In Tab4 puoi esportare CSV e salvare figure/rapporti (quando la logica è collegata).'
     'Sì: scegli una voce dallo storico in Tab3 e premi "Confronta".'
     'Se una riga è tutta zero, non è possibile calcolare la percentuale per quella classe. Verrà indicato nel log e/o messo a NaN.'
    };
    
    % Layout semplice per FAQ (collassabili)
    internalHeight = 900;
    internalPanel  = uipanel(scrollPanel,'Position',[0 0 1080 internalHeight], ...
        'BackgroundColor',[1 1 1],'BorderType','none');
    
    y = internalHeight - 40;
    for i = 1:numel(domande)
        btn = uibutton(internalPanel,'Text',['➕ ' domande{i}], ...
            'FontSize',14,'FontName','Segoe UI', ...
            'Position',[10 y 1060 30], 'HorizontalAlignment','left', ...
            'BackgroundColor',[1 1 1]);
        txt = uitextarea(internalPanel,'Value',splitlines(risposte{i}), ...
            'Editable','off','Visible','off','FontSize',13,'FontName','Segoe UI', ...
            'Position',[20 y-120 1040 110]);
        btn.ButtonPushedFcn = @(src,~) toggleFAQEntry(src, txt, scrollPanel);
        y = y - 150;
    end
    drawnow; scroll(scrollPanel,'top');
    
    %% ====== Footer ======
    footerFrame = uipanel(fig,'Position',[10 10 1180 50], ...
        'BackgroundColor',[0.94 0.94 0.94],'BorderType','line','BorderWidth',1);
    addFooterIfAny(footerFrame); % se esiste addFooter, la usa; altrimenti silenzio
    
    %% ====== AppData iniziali ======
    if ~isappdata(fig,'HistoryP2'), setappdata(fig,'HistoryP2',[]); end
    if ~isappdata(fig,'CurrentConfMat'), setappdata(fig,'CurrentConfMat',[]); end
    if ~isappdata(fig,'CurrentLabels'), setappdata(fig,'CurrentLabels',{}); end
    
    % Stato iniziale se disponibile
    if exist('setSessionStatus','file')==2
        setSessionStatus(fig,'Inizializzazione',true,[],'ok');
    end  

end

%% ====== NESTED HELPERS (solo UI) ======

function callOrTodo(fcn, varargin)
    % fcn può essere string o cell array di candidati
    names = {};
    if ischar(fcn) || isstring(fcn), names = {char(fcn)}; end
    if iscell(fcn), names = fcn; end

    % prova a chiamare la prima funzione disponibile
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

    % --- Fallback demo SOLO per onComputeMetrics (UI preview senza logica) ---
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

    % Altri casi -> TODO
    msg = sprintf('TODO: implementare %s (UI-only per ora)', strjoin(names, ' / '));
    disp(msg);
    try
        uialert(fig, msg, 'TODO','Icon','info'); 
    catch
    end
end

function demoPopulateMetrics(figH)
    % === Dati fake realistici per anteprima UI ===
    N = 6;
    labels = compose('Class %d', 1:N).';
    totRow = randi([30 150], N, 1);          % campioni per classe
    acc_i  = 0.55 + 0.40*rand(N,1);          % 55%..95% per classe
    TP     = floor(acc_i .* totRow);
    acc_g  = sum(TP) / max(sum(totRow),1);   % accuratezza globale

    % --- Aggiorna badge ---
    lbl = findobj(figH,'Tag','LabelGlobalAcc');
    if ~isempty(lbl), lbl.Text = sprintf('%.1f%%', 100*acc_g); end

    % --- Aggiorna tabella ---
    tbl = findobj(figH,'Tag','TablePerClass');
    if ~isempty(tbl)
        data = [labels(:), num2cell(TP), num2cell(totRow), num2cell(round(100*acc_i,1))];
        tbl.Data = data;
        try
            tbl.ColumnFormat = {'char','numeric','numeric','numeric'}; 
        catch
        end
    end

    % --- Aggiorna grafico barre ---
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
    % Aggiorna showCounts/showPerc in CurrentOpts
    opts = getappdata(figH,'CurrentOpts');
    tag = get(evt.NewValue,'Tag');
    switch tag
        case 'counts'
            opts.showCounts = true;  opts.showPerc = false;
        case 'perc'
            opts.showCounts = false; opts.showPerc = true;
        otherwise
            % in futuro: "entrambi"
            opts.showCounts = true;  opts.showPerc = true;
    end
    setappdata(figH,'CurrentOpts',opts);
    callOrTodo('onVisOptionsChanged',figH);
end

function toggleFAQEntry(btn, answer, scrollParent)
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
    % Se esiste addFooter (come in P1), la usa; altrimenti crea un footer semplice
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