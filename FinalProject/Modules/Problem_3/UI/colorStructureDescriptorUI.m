function colorStructureDescriptorUI()
% PROBLEM3_CSD_UI
% =====================================================================================
% UI-ONLY per il "Problema 3 – Color Structure Descriptor (CSD)".
% Struttura a 6 tab, coerente con Moduli 1 e 2:
%   1) Info modulo
%   2) CSD (calcolo singolo)
%   3) Test set & Playground
%   4) Confronto 1↔1
%   5) Sessione (storico, stato, export)
%   6) Guida (FAQ)
%
% Scope & Constraints
%   - Solo interfaccia. Nessuna logica di calcolo CSD qui dentro.
%   - Tutti i callback delegano a funzioni Core/Logic se disponibili.
%   - In assenza del Core, la UI rimane responsiva e mostra TODO o demo mock.
%
% Integrazione: FEVAL-like (se esistono, vengono chiamate)
%   - onLoadImage10x10, onChooseDemoCSD, onPasteArray10x10,
%     onComputeCSD, onAddToHistoryCSD, onGenerateTestCase,
%     refreshP3History, onCompareCSD, onHistorySelectP3,
%     loadSessionP3|loadSession, saveSessionP3|saveSession,
%     exportSessionCSV_P3|exportSessionCSV, clearHistoryP3|clearHistory,
%     setSessionStatus, addFooter, backToMain
%
% AppData (fig):
%   - 'P3Controls'          : struct con handle controlli principali
%   - 'AxesPreviewP3'       : handle uiaxes anteprima immagine
%   - 'AxesPreviewA','AxesPreviewB' : handle uiaxes per confronto
%   - 'HistoryP3'           : struct/array storico (gestito dal Core)
%   - 'CurrentImageP3'      : immagine corrente 10x10 BN (gestita dal Core)
%   - 'CurrentCSDP3'        : struct con campi Nero, Bianco (gestito dal Core)
%   - 'TestLogBoxP3'        : handle textarea log test
%
% Estetica:
%   - Font Segoe UI, pannelli bianchi, badge numerici, layout arioso.
% =====================================================================================

    %% ====== Tag/UI keys & Testi ======
    T = struct( ...
      'AxesPreviewP3',     'AxesPreviewP3', ...
      'AxesA',             'AxesA', ...
      'AxesB',             'AxesB', ...
      'LblNero',           'LblNero', ...
      'LblBianco',         'LblBianco', ...
      'LblWindows',        'LblWindows', ...
      'LblImgName',        'LblImgName', ...
      'HistoryTableP3',    'HistoryTableP3', ...
      'SessionStatusLabel','SessionStatusLabel', ...
      'TestLogBoxP3',      'TestLogBoxP3', ...
      'CompareSummaryBox', 'CompareSummaryBox' ...
    );

    BTN = struct( ...
      'Back',          '◀ Torna alla schermata principale', ...
      'LoadImg',       '📂 Carica immagine 10×10', ...
      'ChooseDemo',    '🧪 Scegli demo', ...
      'PasteArray',    '📝 Incolla array 10×10', ...
      'ComputeCSD',    '🧮 Calcola CSD', ...
      'AddHistory',    '📌 Aggiungi allo storico', ...
      'SessLoad',      '📁 Carica sessione', ...
      'SessSave',      '💾 Salva sessione', ...
      'SessCSV',       '📤 Esporta CSV', ...
      'SessClear',     '🧹 Pulisci cronologia', ...
      'Compare',       '🆚 Confronta', ...
      'GenWhite',      '⬜ Tutta bianca', ...
      'GenBlack',      '⬛ Tutta nera', ...
      'GenChecker',    '♟️ Scacchiera', ...
      'GenBlock',      '◼️ Blocco 4×4', ...
      'GenRandom',     '🎲 Random' ...
    );

    %% ====== Figura ======
    fig = uifigure('Name','Problema 3 – Color Structure Descriptor (CSD)', ...
                   'Position',[300 120 1200 720], ...
                   'Color',[0.96,0.96,0.96], 'AutoResizeChildren','on');

    uibutton(fig,'Text',BTN.Back,'FontSize',12,'FontName','Segoe UI', ...
        'Position',[10 680 260 28], 'ButtonPushedFcn',@(~,~) callOrTodo('backToMain',fig));

    tg = uitabgroup(fig,'Position',[10 70 1180 600]);

    %% ====== TAB 1 – Info modulo ======
    tabInfo = uitab(tg,'Title','🗞 Info modulo');

    uilabel(tabInfo,'Text','Modulo 3 – Color Structure Descriptor (CSD)', ...
        'FontSize',18,'FontWeight','bold','FontName','Segoe UI', ...
        'Position',[20 540 800 30]);

    intro = {
        'Obiettivo', ...
        '• Implementare il CSD con structuring element 3×3 su immagini 10×10 bianco/nero.', ...
        '• Mostrare il risultato (conteggi bin Nero/Bianco).', ...
        '• Testare con immagini diverse.', ...
        ' ', ...
        'Cos’è il CSD (in breve)', ...
        '• È un istogramma che considera la PRESENZA del colore in un intorno (3×3), non il conteggio dei pixel.', ...
        '• Ogni finestra 3×3: se c''è almeno un pixel nero ⇒ bin Nero +1; se c''è almeno un pixel bianco ⇒ bin Bianco +1.', ...
        '• Due immagini con identico istogramma classico possono avere CSD diversi (cattura la distribuzione spaziale).', ...
        ' ', ...
        'Vincoli UI', ...
        '• Input ammesso: solo 10×10 binaria (0/1).', ...
        '• SE fisso 3×3; finestre valide: 64.'};
    uitextarea(tabInfo,'Position',[20 240 1140 290],'Editable','off','Value',intro);

    card = uipanel(tabInfo,'Title','Suggerimenti d’uso','Position',[20 40 1140 180], ...
        'BackgroundColor',[1 1 1],'FontName','Segoe UI','FontSize',12);
    uilabel(card,'Text','• Usa la Tab "CSD" per un singolo calcolo sull’immagine corrente.', ...
        'Position',[12 120 1110 24],'FontSize',13);
    uilabel(card,'Text','• Prova la Tab "Test set" per capire come cambia il CSD al variare della distribuzione.', ...
        'Position',[12 92 1110 24],'FontSize',13);
    uilabel(card,'Text','• Nella Tab "Confronto" affianca due immagini (A/B) e osserva Δ dei bin.', ...
        'Position',[12 64 1110 24],'FontSize',13);
    uilabel(card,'Text','• Salva/Carica/Esporta dalla Tab "Sessione". Le FAQ sono nella Tab "Guida".', ...
        'Position',[12 36 1110 24],'FontSize',13);

    %% ====== TAB 2 – CSD (calcolo singolo) ======
    tabCSD = uitab(tg,'Title','🧮 CSD');

    panelInput = uipanel(tabCSD,'Title','Input immagine (10×10 BN)','FontName','Segoe UI', ...
        'FontSize',12,'Position',[20 400 520 155],'BackgroundColor',[1 1 1]);
    uibutton(panelInput,'Text',BTN.LoadImg,'Position',[10 74 240 45], ...
        'Tooltip','Carica .mat/.png come 10×10 binaria','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onLoadImage10x10',fig));
    uibutton(panelInput,'Text',BTN.ChooseDemo,'Position',[270 74 240 45], ...
        'Tooltip','Seleziona una demo predefinita (checker, block...)','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onChooseDemoCSD',fig));
    uibutton(panelInput,'Text',BTN.PasteArray,'Position',[10 20 500 40], ...
        'Tooltip','Incolla array 10×10 (0/1) da testo','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onPasteArray10x10',fig));

    % Anteprima immagine
    axPrev = uiaxes(tabCSD,'Position',[20 60 520 300],'Tag',T.AxesPreviewP3);
    axPrev.Toolbar.Visible = 'off'; box(axPrev,'on'); title(axPrev,'Anteprima immagine');
    xlabel(axPrev,''); ylabel(axPrev,'');
    setappdata(fig,'AxesPreviewP3',axPrev);

    % Risultati CSD
    panelOut = uipanel(tabCSD,'Title','Risultati CSD (SE=3×3)','FontName','Segoe UI', ...
        'FontSize',12,'Position',[560 105 600 450],'BackgroundColor',[1 1 1]);

    uibutton(tabCSD,'Text',BTN.ComputeCSD,'Position',[560 50 290 40],'FontSize',14, ...
        'Tooltip','Calcola CSD (delegato al Core)','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onComputeCSD',fig));
    uibutton(tabCSD,'Text',BTN.AddHistory,'Position',[870 50 290 40],'FontSize',14, ...
        'Tooltip','Aggiungi immagine/CSD allo storico (Tab Sessione)','ButtonPushedFcn', ...
        @(~,~) callOrTodo('onAddToHistoryCSD',fig));

    uilabel(panelOut,'Text','Immagine corrente:','Position',[16 390 180 26], ...
        'FontSize',13,'FontWeight','bold');
    uilabel(panelOut,'Text','—','Position',[180 390 380 26], ...
        'Tag',T.LblImgName,'FontSize',13);

    % Badge risultati
    badge = @(parent, txt, xpos, ypos) uipanel(parent,'Position',[xpos ypos 260 110], ...
        'BackgroundColor',[0.98 0.98 0.98],'BorderType','line','BorderWidth',1,'Title',txt, ...
        'FontName','Segoe UI','FontSize',12,'TitlePosition','centertop');

    bN = badge(panelOut,'Conteggio bin NERO',  16, 240);
    bB = badge(panelOut,'Conteggio bin BIANCO',316, 240);
    bW = badge(panelOut,'Finestre analizzate',  16, 110);

    uilabel(bN,'Text','—','Tag',T.LblNero,'FontSize',28,'FontWeight','bold', ...
        'Position',[20 30 220 50],'HorizontalAlignment','center');
    uilabel(bB,'Text','—','Tag',T.LblBianco,'FontSize',28,'FontWeight','bold', ...
        'Position',[20 30 220 50],'HorizontalAlignment','center');
    uilabel(bW,'Text','64','Tag',T.LblWindows,'FontSize',26,'FontWeight','bold', ...
        'Position',[20 30 220 50],'HorizontalAlignment','center');

    % Note esplicative
    note = {
        '• Presenza, non frequenza: per ciascuna finestra 3×3 si incrementa il bin se il colore è presente almeno una volta.'
        '• Entrambi i bin possono crescere nella stessa finestra (se compaiono 0 e 1 insieme).'
        '• Per 10×10 e SE=3×3 le finestre valide sono 64.'
        };
    uitextarea(panelOut,'Position',[16 16 564 80],'Editable','off','Value',note);

    %% ====== TAB 3 – Test set & Playground ======
    tabTest = uitab(tg,'Title','🧪 Test set');
    
    % ---- Costanti layout per armonia visiva ----
    M   = 20;      % margine esterno
    G   = 16;      % gutter tra pannelli
    LW  = 460;     % larghezza colonna sinistra
    RH1 = 350;     % altezza preview (↑ per riempire meglio)
    RH2 = 150;     % altezza pannello Azioni&Log (↑ per respiro)
    
    % ============ COLONNA SINISTRA ============
    left = uipanel(tabTest,'Title','Generatori rapidi', ...
        'Position',[M, 230, LW, 320], ...
        'BackgroundColor',[1 1 1],'FontName','Segoe UI','FontSize',12);
    
    % Riga 1
    uibutton(left,'Text',BTN.GenWhite, 'Position',[16 237 210 44], ...
        'ButtonPushedFcn',@(~,~) callOrTodo('onGenerateTestCase',fig,'white'));
    uibutton(left,'Text',BTN.GenBlack, 'Position',[234 237 210 44], ...
        'ButtonPushedFcn',@(~,~) callOrTodo('onGenerateTestCase',fig,'black'));
    
    % Riga 2
    uibutton(left,'Text',BTN.GenChecker,'Position',[16 180 210 44], ...
        'ButtonPushedFcn',@(~,~) callOrTodo('onGenerateTestCase',fig,'checker'));
    uibutton(left,'Text',BTN.GenBlock,  'Position',[234 180 210 44], ...
        'Tooltip','Blocco 4×4 in un angolo', ...
        'ButtonPushedFcn',@(~,~) callOrTodo('onGenerateTestCase',fig,'block'));
    
    % Riga 3 (centrato)
    uibutton(left,'Text',BTN.GenRandom,'Position',[16 123 428 44], ...
        'ButtonPushedFcn',@(~,~) callOrTodo('onGenerateTestCase',fig,'random'));
    
    % Riga 4 (centrato)
    uibutton(left,'Text','▶ Calcola CSD','Position',[16 71 428 44], ...
        'Tooltip','Calcola CSD sull’immagine corrente (mock se Core assente)', ...
        'ButtonPushedFcn',@(~,~) callOrTodo('onGenerateTestCase',fig,'run'));
    
    % Riga 5 (centrato)
    uibutton(left,'Text',BTN.AddHistory,'Position',[16 19 428 44], ...
        'Tooltip','Aggiunge immagine/CSD allo storico', ...
        'ButtonPushedFcn',@(~,~) callOrTodo('onAddToHistoryCSD',fig));
    
    % --- Parametri Random (card separata, allineata alla sinistra) ---
    leftPar = uipanel(tabTest,'Title','Parametri Random', ...
        'Position',[M, 14, LW, 200], ...   % ↓ abbassato per gutter coerente (16 px)
        'BackgroundColor',[1 1 1],'FontName','Segoe UI','FontSize',12);
    
    % Pixel Bianco
    uilabel(leftPar,'Text','pBianco:','Position',[16 144 70 22],'HorizontalAlignment','right');  % x da valori negativi a 16
    sP = uislider(leftPar,'Position',[92 154 250 3],'Limits',[0 1],'Value',0, ...
        'MajorTicks',0:0.25:1);
    pRead = uieditfield(leftPar,'numeric','Position',[352 134 92 28],'Value',0.50,'Editable','off');
    sP.ValueChangingFcn = @(src,evt) set(pRead,'Value',round(evt.Value,2));
    
    % Noise %
    uilabel(leftPar,'Text','Noise %:','Position',[16 80 70 22],'HorizontalAlignment','right');   % x da valori negativi a 16
    sN = uislider(leftPar,'Position',[92 90 250 3],'Limits',[0 20],'Value',0, ...
        'MajorTicks',0:5:20, 'MinorTicks',0:1:20);
    sN.Value = round(sN.Value);
    nRead = uieditfield(leftPar,'numeric','Position',[352 80 92 28],'Value',0,'Editable','off');
    sN.ValueChangingFcn = @(src,evt) set(nRead,'Value',round(evt.Value));
    
    % Seed
    uilabel(leftPar,'Text','Seed:','Position',[16 20 70 22],'HorizontalAlignment','right');       % x da valori negativi a 16
    sS = uieditfield(leftPar,'numeric','Position',[92 14 120 28],'Value',1,'RoundFractionalValues','on');
    setappdata(fig,'P3Controls', struct('sliderPWhite',sP,'editSeed',sS));   

    % ============ COLONNA DESTRA ============
    % Area preview (grande, con margini respiranti)
    rx = M + LW + G;            % x della colonna destra
    rw = 1180 - rx - M;         % larghezza colonna destra (coerente con fig/tg)
    
    prevPanel = uipanel(tabTest,'Title','Anteprima (Test set) – 10×10', ...
        'Position',[rx, 200, rw, RH1], ...  % ↑ allineata in alto
        'BackgroundColor',[1 1 1],'FontName','Segoe UI','FontSize',12);
    
    % Asse QUADRATO centrato, 10×10 pixel con unità chiare
    axSize = min(RH1-70, rw-70);                % -70 per titoli/padding card
    axX    = (rw - axSize)/2;
    axY    = (RH1 - axSize)/2;
    axTest = uiaxes(prevPanel,'Position',[axX axY axSize axSize]);
    axTest.Toolbar.Visible='off'; box(axTest,'on');
    axis(axTest,'image'); colormap(axTest,gray(2));
    xlabel(axTest,'Colonna j (pixel)'); ylabel(axTest,'Riga i (pixel)');
    xlim(axTest,[0.5 10.5]); ylim(axTest,[0.5 10.5]);
    xticks(axTest,1:10); yticks(axTest,1:10);
    title(axTest,'Anteprima (10×10)');
    
    setappdata(fig,'AxesPreviewP3',axTest);  % preview corrente
    
    % Azioni & Log in basso, allineato e con larghezza piena colonna destra
    right = uipanel(tabTest,'Title','Azioni & Log', ...
        'Position',[rx, M - 5, rw, RH2], ...    % ↑ altezza coerente
        'BackgroundColor',[1 1 1],'FontName','Segoe UI','FontSize',12);
    
    logBox = uitextarea(right,'Position',[12 12 rw-24 RH2-40], ...
        'Editable','off','Tag',T.TestLogBoxP3, ...
        'Value',{'Log test set (azioni e risultati sintetici).'});
    setappdata(fig,'TestLogBoxP3',logBox);  

    %% ====== TAB 4 – Confronto 1↔1 ======
    tabCmp = uitab(tg,'Title','🆚 Confronto');

    uilabel(tabCmp,'Text','Slot A (sinistra)  |  Slot B (destra). Carica/Seleziona dallo storico o dal Test set.', ...
        'Position',[20 540 860 24],'FontSize',12);

    % Selettori (lasciati vuoti: il Core popolerà)
    % Dropdown di selezione A/B (A vuoto = usa corrente)
    uidropdown(tabCmp, ...
        'Items',{'-- Seleziona A --'}, ...
        'Position',[20 504 500 28], ...
        'Tag','CompareDropLeft', ...
        'Tooltip','Scelta A (sinistra): se lasci vuoto usa la matrice corrente');
    uidropdown(tabCmp, ...
        'Items',{'-- Seleziona B --'}, ...
        'Position',[660 504 500 28], ...
        'Tag','CompareDropRight', ...
        'Tooltip','Scelta B (destra): elemento dallo storico');

    % Azione di confronto (delegata)
    uibutton(tabCmp,'Text','🆚 Confronta','Position',[540 503 100 30], ...
        'ButtonPushedFcn',@(~,~) callOrTodo(fig));

    axA = uiaxes(tabCmp,'Position',[20 270 560 220],'Tag',T.AxesA);
    axA.Toolbar.Visible='off'; box(axA,'on'); title(axA,'Anteprima A');
    axB = uiaxes(tabCmp,'Position',[600 270 560 220],'Tag',T.AxesB);
    axB.Toolbar.Visible='off'; box(axB,'on'); title(axB,'Anteprima B');
    setappdata(fig,'AxesPreviewA',axA);
    setappdata(fig,'AxesPreviewB',axB);

    % Riepilogo numerico (Nero/Bianco per A/B + Δ)
    sumBox = uitextarea(tabCmp,'Position',[20 40 1140 210],'Editable','off', ...
        'Tag',T.CompareSummaryBox, ...
        'Value',{'Riepilogo confronto CSD:', ...
                 '- A: Nero=?, Bianco=?', ...
                 '- B: Nero=?, Bianco=?', ...
                 '- Δ: (A−B) per ciascun bin.'}); %#ok<NASGU>

    %% ====== TAB 5 – Sessione ======
    tabSession = uitab(tg,'Title','🗃️ Sessione');

    uitable(tabSession,'Position',[20 330 760 230], ...
        'ColumnName',{'Nome','Data','Img','Nero','Bianco','Note'}, ...
        'ColumnWidth',{240,130,80,80,80,180}, ...
        'RowName',[],'Tag',T.HistoryTableP3);

    statusPanel = uipanel(tabSession,'Title','Stato operazioni', ...
        'Position',[820 330 340 230],'FontName','Segoe UI','FontSize',12, ...
        'BackgroundColor',[1 1 1]);
    uilabel(statusPanel,'Text',sprintf('- Ultima operazione: Nessuna\n- Stato sessione: Inattiva\n- Ultimo export: --'), ...
        'Position',[10 20 310 180],'FontSize',13,'Tag',T.SessionStatusLabel, ...
        'HorizontalAlignment','left','WordWrap','on');

    uibutton(tabSession,'Text',BTN.SessLoad,'Position',[20 270 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'loadSessionP3','loadSession'},fig));
    uibutton(tabSession,'Text',BTN.SessSave,'Position',[315 270 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'saveSessionP3','saveSession'},fig));
    uibutton(tabSession,'Text',BTN.SessCSV,'Position',[605 270 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'exportSessionCSV_P3','exportSessionCSV'},fig));
    uibutton(tabSession,'Text',BTN.SessClear,'Position',[900 270 260 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) callOrTodo({'clearHistoryP3','clearHistory'},fig));

    uitextarea(tabSession,'Position',[20 20 1140 230],'Editable','off', ...
        'Tag','FullLogBoxP3','Value',{'Log dettagliato delle operazioni del Modulo 3.'});

    % Abilita eventuali utility di storico
    tblHist = findobj(fig,'Tag',T.HistoryTableP3);
    if ~isempty(tblHist)
        try
            if exist('enableHistoryTableDoubleClickP3','file')==2
                enableHistoryTableDoubleClickP3(fig);
            elseif exist('enableHistoryTableDoubleClick','file')==2
                enableHistoryTableDoubleClick(fig);
            else
                tblHist.CellSelectionCallback = @(tbl,event) callOrTodo({'onHistorySelectP3','onHistorySelect'},fig,event);
            end
        catch ME
            warning('%s - [P3] enable double click storico non configurato: %s', ME.identifier, ME.message);
        end
    end

    %% ====== TAB 6 – Guida (FAQ) ======
    tabHelp = uitab(tg,'Title','❓ Guida');

    uilabel(tabHelp,'Text','Domande frequenti (FAQ)', ...
        'Position',[20 540 800 30],'FontSize',18,'FontWeight','bold','FontName','Segoe UI');

    scrollPanel = uipanel(tabHelp,'Position',[20 40 1140 490], ...
        'Scrollable','on','BackgroundColor',[1 1 1],'Tag','FAQScrollPanel');

    q = {
      'Cos’è il CSD in due righe?'
      'Perché i bin CSD non sommano a 64?'
      'Quali input sono accettati?'
      'Cosa fa “Calcola CSD”?'
      'Posso usare immagini non 10×10?'
      'A cosa serve il Test set?'
      'Come confronto due immagini?'
      'Cosa viene salvato in Sessione?'
      'Perché vedo “TODO: implementare …”?'
      'Come gestire errori di input (NaN, valori ≠ 0/1)?'
    };
    a = {
      "CSD = istogramma di PRESENZA per colore nell'intorno 3×3. Conta finestre in cui il colore appare almeno una volta."
      "Perché in una stessa finestra 3×3 possono essere presenti sia nero sia bianco → entrambi i bin incrementano."
      "Solo 10×10 binaria (0/1). Caricamento da .mat/.png o incolla array 10×10. La validazione è nel Core."
      "Chiama la logica per scorrere le 64 finestre e restituisce i conteggi per Nero/Bianco. In assenza del Core parte una demo mock."
      "No, per l’esercitazione sono richieste 10×10 BN e SE fisso 3×3. Altre dimensioni vanno rifiutate dal Core."
      "Per mostrare come la distribuzione spaziale cambi il CSD (scacchiera, blocco, random…). Utile anche per la relazione."
      "Scegli A e B (o usa la corrente), premi 'Confronta' e guarda le anteprime e il Δ dei bin nel riquadro di riepilogo."
      "Storico (nome, data, CSD), immagine, opzioni base e log. Export CSV per report rapidi."
      "Significa che il Core non è collegato. La UI non si rompe e mostra un alert non bloccante."
      "La UI non elabora: il Core deve validare e mostrare alert chiari (dimensione errata, valori non binari, NaN)."
    };

    % Render collassabile
    rowH = 140; padT = 30;
    internalHeight = padT + numel(q)*rowH + 20;
    internalPanel  = uipanel(scrollPanel,'Position',[0 0 1080 internalHeight], ...
        'BackgroundColor',[1 1 1],'BorderType','none');
    y = internalHeight - padT;
    for i=1:numel(q)
        btn = uibutton(internalPanel,'Text',['➕ ' q{i}], ...
            'FontSize',14,'FontName','Segoe UI',...
            'Position',[10 y-28 1060 28],'HorizontalAlignment','left', ...
            'BackgroundColor',[1 1 1]);
        txt = uitextarea(internalPanel,'Value',splitlines(a{i}), ...
            'Editable','off','Visible','off','FontSize',13,'FontName','Segoe UI', ...
            'Position',[20 y-126 1040 96]);
        btn.ButtonPushedFcn = @(src,~) toggleFAQEntry(src, txt, scrollPanel);
        y = y - rowH;
    end
    drawnow; scroll(scrollPanel,'top');

    %% ====== Footer ======
    footerFrame = uipanel(fig,'Position',[10 10 1180 50], ...
        'BackgroundColor',[0.94 0.94 0.94],'BorderType','line','BorderWidth',1);
    addFooterIfAny(footerFrame);

    %% ====== AppData & bootstrap ======
    if ~isappdata(fig,'HistoryP3'),      setappdata(fig,'HistoryP3',[]);       end
    if ~isappdata(fig,'CurrentImageP3'), setappdata(fig,'CurrentImageP3',[]);  end
    if ~isappdata(fig,'CurrentCSDP3'),   setappdata(fig,'CurrentCSDP3',[]);    end

    if exist('setSessionStatus','file')==2
        setSessionStatus(fig,'Inizializzazione Modulo 3',true,[],'ok');
    end

    % Primo refresh storico (se funzione disponibile)
    callOrTodo('refreshP3History',fig);
end

%% ====== HELPERS UI-ONLY ==============================================================
function callOrTodo(fcn, varargin)
% CALLORTODO  Prova a chiamare funzioni Core/Logic; in fallback usa DEMO o TODO.
% - NIENTE popup per i TODO (non blocca): log in console + status label se disponibile.
% - Popup solo per DEMO (una volta per azione).

    % ---- CONFIG ----
    QUIET_TODO = true;   % ← lascia true per non mostrare gli uialert dei TODO

    % Normalizza nomi funzione da provare
    if ischar(fcn) || isstring(fcn)
        names = {char(fcn)};
    elseif iscell(fcn)
        names = fcn;
    else
        names = {};
    end

    % 1) PROVA A CHIAMARE IL CORE
    for k = 1:numel(names)
        if exist(names{k},'file')==2
            try
                feval(names{k}, varargin{:});              % call Core
                figH = localPickFig(varargin{:});          % figura corretta
                if exist('setDemoStyle','file')==2, setDemoStyle(figH,false); end
                return;
            catch ME
                warning('[P3] Errore chiamando %s: %s', names{k}, ME.message);
                return;
            end
        end
    end

    % 2) FALLBACK DEMO: onComputeCSD oppure onGenerateTestCase(...,'run')
    isDemoTrigger = ~isempty(names) && ...
        ( strcmp(names{1},'onComputeCSD') || ...
         (strcmp(names{1},'onGenerateTestCase') && any(strcmp(varargin,'run'))) );

    if isDemoTrigger
        demoPopulateCSD(varargin{:});
        figH = localPickFig(varargin{:});
        if exist('setDemoStyle','file')==2, setDemoStyle(figH,true); end
        disp('Demo: CSD generato (mock) per anteprima UI. Collega la logica per i dati reali.');
        % Alert solo per DEMO (non troppo invadente)
        try uialert(figH,'Demo: CSD generato (mock). Collega la logica per i dati reali.','DEMO','Icon','info'); catch, end
        return;
    end

    % 3) TODO GENERICO (silenzioso)
    msg = sprintf('TODO: implementare %s (UI-only per ora)', strjoin(names,' / '));
    disp(msg);  % log in Command Window

    % se c'è un setter di stato, usalo al posto del popup
    figH = localPickFig(varargin{:});
    try
        if exist('setSessionStatus','file')==2
            setSessionStatus(figH, msg, false, [], 'info');  % non bloccante
        elseif ~QUIET_TODO
            % Solo se vuoi forzare il popup TODO
            try
                uialert(figH, msg, 'TODO','Icon','info');
            catch
                disp('[P3] impossibile mostrare uialert.');
            end
        end
    catch
        % niente: resta il log in console
    end
end

function setDemoStyle(fig, isDemo)
    if isempty(fig) || ~ishghandle(fig), return; end
    demoCol = [0.85 0.20 0.20];
    normCol = [0 0 0];
    col = normCol; 
    if isDemo, col = demoCol; end
    for tag = {'LblNero','LblBianco','LblWindows'}
        h = findobj(fig,'Tag',tag{1});
        if ~isempty(h) && isvalid(h)
            h.FontColor = col;
        end
    end
    setappdata(fig,'P3_isDemo',logical(isDemo));
end

function fig = localPickFig(varargin)
% Ritorna l'handle della uifigure più probabile:
    fig = [];
    % 1) prova dai varargin
    for v = 1:numel(varargin)
        if ishghandle(varargin{v}) && isa(varargin{v},'matlab.ui.Figure')
            fig = varargin{v}; return;
        end
    end
    % 2) callback corrente (se esiste)
    try
        cbf = gcbf; 
        if ishghandle(cbf) && isa(cbf,'matlab.ui.Figure'), fig = cbf; return; end
    catch
    end
    % 3) ultima figura usata
    try
        gf = gcf;
        if ishghandle(gf) && isa(gf,'matlab.ui.Figure'), fig = gf; return; end
    catch
    end
    % 4) prima trovata
    figs = findall(0,'Type','figure');
    if ~isempty(figs), fig = figs(1); end
end

function demoPopulateCSD(varargin)
% DEMOPOPULATECSD  Popola i badge CSD con valori plausibili (0..64) e aggiorna log Test.
    fig = [];
    for v = 1:numel(varargin)
        if ishghandle(varargin{v}) && isa(varargin{v},'matlab.ui.Figure'), fig = varargin{v}; break; end
    end
    if isempty(fig)
        figs = findall(0,'Type','figure'); if ~isempty(figs), fig = figs(1); end
    end
    if isempty(fig), return; end

    % Valori plausibili (possono entrambi arrivare a 64). Simula immagine mista:
    nero   = randi([20 64]);
    bianco = randi([20 64]);

    lblN = findobj(fig,'Tag','LblNero');   if ~isempty(lblN), lblN.Text   = sprintf('%d',nero); end
    lblB = findobj(fig,'Tag','LblBianco'); if ~isempty(lblB), lblB.Text   = sprintf('%d',bianco); end
    lblW = findobj(fig,'Tag','LblWindows');if ~isempty(lblW), lblW.Text   = '64'; end

    % Aggiorna anteprima con pattern semplice (mock scacchiera)
    ax = getappdata(fig,'AxesPreviewP3');
    if ~isempty(ax) && isvalid(ax)
        img = checkerboardMock(10);
        imagesc(ax, img); colormap(ax,gray(2)); axis(ax,'image'); ax.XTick=[]; ax.YTick=[];
    end

    % Log test (se presente)
    tlog = getappdata(fig,'TestLogBoxP3');
    if ~isempty(tlog) && isvalid(tlog)
        t = char(datetime('now','Format','dd-MM-yyyy HH:mm'));
        tlog.Value = [tlog.Value; {sprintf('[%s] DEMO CSD → Nero=%d, Bianco=%d',t,nero,bianco)}];
        tlog.Value = tlog.Value(max(1,end-200):end); % mantieni ultimi
    end

    % Riepilogo confronto (se aperto)
    sumBox = findobj(fig,'Tag','CompareSummaryBox');
    if ~isempty(sumBox)
        sumBox.Value = {'Riepilogo confronto CSD (DEMO):', ...
                        sprintf('- A: Nero=%d, Bianco=%d',nero,bianco), ...
                        '- B: Nero=?, Bianco=?', ...
                        '- Δ: (A−B) per ciascun bin.'};
    end
end

function img = checkerboardMock(N)
% CHECKERBOARDMOCK  Scacchiera binaria N×N (N pari).
    if mod(N,2)~=0, N = N+1; end
    img = zeros(N);
    img(1:2:end,2:2:end) = 1;
    img(2:2:end,1:2:end) = 1;
end

function toggleFAQEntry(btn, answer, scrollParent)
% TOGGLEFAQENTRY  Espandi/Collassa voce FAQ con aggiornamento scroll.
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
% ADDFOOTERIFANY  Inserisce un footer custom se disponibile, altrimenti fallback.
    if exist('addFooter','file')==2
        try
            addFooter(parent);
            return; 
        catch
        end 
    end
    uilabel(parent,'Text','Approcci e Sistemi 2024/2025 – Modulo 3 (UI-only)', ...
        'Position',[15 15 420 22],'FontName','Segoe UI','FontSize',12);
    uilabel(parent,'Text','Collega il Core per calcolo CSD, sessione e confronto.', ...
        'Position',[450 15 500 22],'FontName','Segoe UI','FontSize',11);
end
