function staticGestureRecognitionUI()
% STATICGESTURERECOGNITIONUI
    % ------------------------------------------------------------------------------
    % Costruisce la GUI del Problema 1 (Gesti statici) con 5 tab:
    %   1) Info modulo
    %   2) Classifica immagine (anteprima, feature, cronologia parziale)
    %   3) Vettori di feature (inserimento manuale/da .mat e classificazione)
    %   4) Sessione (cronologia completa + stato + log)
    %   5) Guida (FAQ)
    %
    % NOTE DI DESIGN
    % - Questo file si occupa SOLO di UI e wiring: nessuna logica pesante.
    % - I callback puntano a funzioni già presenti nel tuo progetto:
    %     loadMultipleImages, classifyAndLabel, classifyAllImages,
    %     loadFeatureVector, onHistorySelect, loadSession, saveSession,
    %     exportSessionCSV, clearHistory, enableHistoryTableDoubleClick.
    % - I tag UI vengono centralizzati in costanti qui sotto per evitare refusi.
    % ------------------------------------------------------------------------------
    
    %% ===== Costanti/tag usati in più punti =====
    T = struct( ...
      'ResultLabel',        'ResultLabel', ...
      'FeatureTable',       'FeatureTable', ...
      'LogBox',             'LogBox', ...
      'ImgInfoLabel',       'ImgInfoLabel', ...
      'HistoryTable',       'HistoryTable', ...        % tab 2 (parziale)
      'FeatureTableVector', 'FeatureTableVector', ...  % tab 3
      'ResultLabelVector',  'ResultLabelVector', ...
      'HistoryTableFull',   'HistoryTableFull', ...    % tab 4 (completa)
      'SessionStatusLabel', 'SessionStatusLabel', ...
      'FAQScrollPanel',     'FAQScrollPanel' ...
    );
    
    BTN = struct( ...
      'Back',          '◀ Torna alla schermata principale', ...
      'LoadImg',       '📂 Carica immagine', ...
      'ClassifyOne',   '▶ Classifica immagine', ...
      'ClassifyAll',   '📁 Classifica tutto', ...
      'VecManual',     '✍ Inserisci manuale', ...
      'VecMat',        '📁 Carica .mat', ...
      'VecClassify',   '📁 Classifica vettori', ...
      'SessLoad',      '📁 Carica sessione', ...
      'SessSave',      '💾 Salva sessione', ...
      'SessCSV',       '📤 Esporta CSV', ...
      'SessClear',     '🧹 Pulisci cronologia' ...
    );
    
    %% ===== Figura principale =====
    fig = uifigure('Name', 'Problema 1 – Gesti Statici', ...
                   'Position', [300 150 1200 700], ...
                   'Color', [0.96, 0.96, 0.96]);
    
    % Pulsante “torna indietro” (lascia il controllo alla tua backToMain)
    uibutton(fig,'Text',BTN.Back,'FontSize',12,'FontName','Segoe UI', ...
        'Position',[10 660 230 30], ...
        'ButtonPushedFcn',@(~,~) backToMain(fig));
    
    % TabGroup principale
    tg = uitabgroup(fig,'Position',[10 60 1180 570]);
    
    %% ===== TAB 1 – Info Modulo =====
    tabInfo = uitab(tg,'Title','🗞 Info modulo');
    
    uilabel(tabInfo,'Text','Modulo 1 – Riconoscimento gesti statici', ...
        'FontSize',18,'FontWeight','bold','Position',[20 510 800 30]);
    
    uitextarea(tabInfo,'Position',[20 230 1140 270],'Editable','off', ...
        'Value',{'Descrizione dettagliata del modulo, obiettivi, approccio usato, ecc.'});
    
    %% ===== TAB 2 – Classifica Immagine =====
    tabClassify = uitab(tg,'Title','🧠 Classifica immagine');
    
    % --- Pannello anteprima
    previewPanel = uipanel(tabClassify,'Title','Anteprima immagine', ...
        'FontName','Segoe UI','FontSize',12,'Position',[20 290 380 240], ...
        'BackgroundColor',[1 1 1]);
    
    axPreview = uiaxes(previewPanel,'Position',[10 60 360 170]);
    axis(axPreview,'off'); axPreview.Toolbar.Visible = 'off'; box(axPreview,'off');
    setappdata(fig,'PreviewAxes',axPreview);
    
    uilabel(previewPanel,'Position',[10 20 360 20], ...
        'Tag',T.ImgInfoLabel,'FontName','Segoe UI');
    
    % --- Pannello risultato
    resultPanel = uipanel(tabClassify,'Title','Risultato','Position',[410 290 370 240]);
    uilabel(resultPanel,'Text','Risultato: –','Tag',T.ResultLabel, ...
        'Position',[10 190 350 30],'FontSize',18,'FontWeight','bold');
    
    uitextarea(resultPanel,'Position',[10 60 350 130],'Editable','off','Tag',T.LogBox);
    
    % --- Pulsanti azione
    uibutton(tabClassify,'Text',BTN.LoadImg, ...
        'Position',[800 450 370 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) loadMultipleImages(fig));
    
    uibutton(tabClassify,'Text',BTN.ClassifyOne, ...
        'Position',[800 390 370 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) classifyAndLabel(fig));
    
    uibutton(tabClassify,'Text',BTN.ClassifyAll, ...
        'Position',[800 330 370 40],'FontSize',14, ...
        'ButtonPushedFcn',@(~,~) classifyAllImages(fig));
    
    % --- Tabella feature
    featurePanel = uipanel(tabClassify,'Title','Feature estratte','Position',[20 20 560 250]);
    uitable(featurePanel,'Position',[10 10 540 210], ...
        'ColumnName',{'Valore'},'RowName',{},'Tag',T.FeatureTable);
    
    % --- Tabella cronologia parziale (Tab 2)
    fileTablePanel = uipanel(tabClassify,'Title','File analizzati','Position',[600 20 560 250]);
    uitable(fileTablePanel,'Position',[10 10 540 210], ...
        'ColumnName',{'Nome','Data','Tipo','Dim (KB)','Tag'}, ...
        'ColumnWidth',{130, 90, 80, 110, 130}, ...
        'RowName',[],'Tag',T.HistoryTable);
    
    %% ===== TAB 3 – Vettori di Feature =====
    tabVector = uitab(tg,'Title','🧩 Vettori di feature');
    
    uibutton(tabVector,'Text',BTN.VecManual,'Position',[20 490 260 40], ...
        'ButtonPushedFcn',@(~,~) loadFeatureVector(fig,'mode','manual','target','tab3'));
    
    uibutton(tabVector,'Text',BTN.VecMat,'Position',[300 490 260 40], ...
        'ButtonPushedFcn',@(~,~) loadFeatureVector(fig,'mode','mat','target','tab3'));
    
    uibutton(tabVector,'Text',BTN.VecClassify,'Position',[580 490 260 40], ...
        'ButtonPushedFcn',@(~,~) loadFeatureVector(fig,'mode','existing','target','tab3'));
    
    tblVector = uitable(tabVector,'Position',[20 240 1140 240], ...
        'ColumnName',{'Feature'},'RowName',[], ...
        'Tag',T.FeatureTableVector);
    
    lblVector = uilabel(tabVector,'Text','Risultato: –','Tag',T.ResultLabelVector, ...
        'Position',[20 200 800 30],'FontSize',18,'FontWeight','bold');
    
    setappdata(fig,'FeatureTableVector',tblVector);
    setappdata(fig,'ResultLabelVector', lblVector);
    
    %% ===== TAB 4 – Sessione =====
    tabSession = uitab(tg,'Title','🗃️ Sessione');
    
    % Cronologia completa (6 colonne)
    uitable(tabSession,'Position',[20 320 750 210], ...
        'ColumnName',{'Nome','Data','Tipo','Dim (KB)','Tag','Classe'}, ...
        'ColumnWidth',{220,110,100,100,110,110}, ...
        'RowName',[],'Tag',T.HistoryTableFull);
    
    % Stato operazioni
    statusPanel = uipanel(tabSession,'Title','Stato operazioni', ...
        'Position',[840 320 320 210], ...
        'FontName','Segoe UI','FontSize',12, ...
        'BackgroundColor',[1 1 1]);
    
    uilabel(statusPanel,'Text',sprintf('- Ultima operazione: Nessuna\n- Stato sessione: Inattiva\n- Ultimo export: --'), ...
        'Position',[10 20 250 170],'FontName','Segoe UI','FontSize',13, ...
        'Tag',T.SessionStatusLabel,'HorizontalAlignment','left','WordWrap','on');
    
    % Pulsanti gestione sessione
    uibutton(tabSession,'Text',BTN.SessLoad,'Position',[20 250 260 40], ...
        'FontSize',14,'ButtonPushedFcn',@(~,~) loadSession(fig));
    
    uibutton(tabSession,'Text',BTN.SessSave,'Position',[315 250 260 40], ...
        'FontSize',14,'ButtonPushedFcn',@(~,~) saveSession(fig));
    
    uibutton(tabSession,'Text',BTN.SessCSV,'Position',[605 250 260 40], ...
        'FontSize',14,'ButtonPushedFcn',@(~,~) exportSessionCSV(fig));
    
    uibutton(tabSession,'Text',BTN.SessClear,'Position',[900 250 260 40], ...
        'FontSize',14,'ButtonPushedFcn',@(~,~) clearHistory(fig));
    
    % Log dettagliato
    uitextarea(tabSession,'Position',[20 20 1140 190],'Editable','off', ...
        'Tag','FullLogBox','Value',{'Log dettagliato delle classificazioni e operazioni eseguite.'});
    
    %% ===== TAB 5 – Guida (FAQ) =====
    tabHelp = uitab(tg,'Title','❓ Guida');
    
    uilabel(tabHelp,'Text','Domande frequenti (FAQ)', ...
        'Position',[20 510 800 30],'FontSize',18,'FontWeight','bold','FontName','Segoe UI');
    
    % Pannello scrollabile + contenuto
    scrollPanel = uipanel(tabHelp,'Position',[20 20 1140 480], ...
        'Scrollable','on','BackgroundColor',[1 1 1],'Tag',T.FAQScrollPanel);
    
    internalHeight = 1850;
    internalPanel  = uipanel(scrollPanel,'Position',[0 0 1080 internalHeight], ...
        'BackgroundColor',[1 1 1],'BorderType','none');
    
    domande = {
        'Come carico un’immagine da classificare?'
        'Come funziona la classificazione?'
        'Posso classificare più immagini insieme?'
        'A cosa serve la tab “Vettori di feature”?'
        'Cosa viene salvato in una sessione?'
        'Come salvo una sessione?'
        'Come carico una sessione salvata?'
        'A cosa serve il CSV?'
        'Posso modificare i tag o i nomi dei file?'
        'Il classificatore può sbagliare?'
        'Posso usare file .mat personalizzati?'
        'A cosa serve il log dettagliato?'
        'Posso eliminare i dati e ricominciare da zero?'
        'Perché un’immagine non viene classificata?'
    };
    
    risposte = {
    "Per caricare un'immagine da classificare, vai alla tab 'Classifica immagine' e premi il pulsante '📂 Carica immagine'. Si aprirà una finestra in cui potrai selezionare file .jpg, .png o simili. L'immagine verrà visualizzata in anteprima e sarà pronta per la classificazione."
    "Il classificatore estrae caratteristiche geometriche (feature) dall'immagine, come forma e compattezza. Queste vengono analizzate secondo delle regole interne, e il sistema assegna la classe più probabile (es. mano aperta, pugno, ecc.)."
    "Sì, puoi classificare più immagini contemporaneamente. Caricale con '📂 Carica immagine', poi premi '📁 Classifica tutto'. Tutte le immagini verranno analizzate e i risultati salvati in un file CSV."
    "La tab 'Vettori di feature' ti permette di inserire direttamente i dati (feature) invece di caricare un'immagine. È utile se hai già calcolato le feature o hai un file .mat con i dati."
    "Vengono salvati tutti i dati della sessione attuale: immagini caricate, classificazioni, risultati CSV, log delle operazioni e vettori di feature. Quando riapri la sessione, tutto verrà ripristinato."
    "Per salvare una sessione vai alla tab 'Sessione' e clicca su '💾 Salva sessione'. Scegli un nome file e una cartella. Tutti i dati verranno archiviati in un file .mat."
    "Vai alla tab 'Sessione' e clicca su '📁 Carica sessione'. Seleziona il file .mat salvato in precedenza. Tutti i dati verranno caricati automaticamente."
    "Il CSV (Comma Separated Values) è un file di testo che contiene una tabella. Ogni riga rappresenta un'immagine classificata, con il suo nome, le feature estratte e il risultato."
    "No, non dall'interno dell'app. Se vuoi modificare il nome o i tag dei file, fallo nel sistema operativo (Esplora file) e poi ricarica le immagini."
    "Sì, il classificatore può sbagliare, specialmente con immagini sfocate, gesti incompleti o condizioni di luce difficili. Usa immagini chiare con sfondi semplici per ottenere risultati migliori."
    "Sì, se il file .mat contiene un vettore di feature nel formato corretto. Questo è utile per testare dati generati da altri strumenti o manualmente."
    "Il log mostra tutte le operazioni eseguite nella sessione, come caricamenti, classificazioni, salvataggi ed errori. Serve a capire cosa è successo e a ricostruire il flusso di lavoro."
    "Sì. Nella tab 'Sessione' clicca su '🧹 Pulisci cronologia'. Tutti i file caricati, le classificazioni e il log verranno cancellati. Potrai iniziare una nuova sessione da zero."
    "Ci sono diverse cause: il file potrebbe non essere un'immagine valida, avere un formato non supportato (.tiff, .bmp, ecc.), oppure essere troppo danneggiato o vuoto. Controlla che l'immagine sia nitida e ben ritagliata."
    };
    
    % Layout semplice per FAQ
    startY = internalHeight - 40;
    gap    = 10;
    faqComponents = gobjects(length(domande),2);
    
    for i = 1:length(domande)
        txt   = risposte{i};
        nLines = count(txt,newline) + ceil(strlength(txt)/85);
        respH  = max(60, nLines*18);
        buttonHeight = 30;
    
        y = startY - sum(cellfun(@(r) ...
            max(5, count(r, newline) + ceil(strlength(r)/85)) * 18 + gap + buttonHeight, ...
            risposte(1:i-1)));
    
        btn = uibutton(internalPanel,'Text',['➕ ' domande{i}], ...
            'FontSize',14,'FontName','Segoe UI', ...
            'Position',[10 y 1060 30], 'HorizontalAlignment','left', ...
            'BackgroundColor',[1 1 1]);
    
        answer = uitextarea(internalPanel,'Value',splitlines(txt), ...
            'Editable','off','Visible','off','FontSize',13,'FontName','Segoe UI', ...
            'Position',[20 y - respH - 5 1040 respH]);
    
        btn.ButtonPushedFcn = @(src,~) toggleFAQEntry(src, answer, scrollPanel);
        faqComponents(i,:) = [btn, answer];
    end
    drawnow;
    scroll(scrollPanel,'top');
    
    %% ===== Footer =====
    footerFrame = uipanel(fig,'Position',[10 10 1180 50], ...
        'BackgroundColor',[0.94 0.94 0.94],'BorderType','line','BorderWidth',1);
    addFooter(footerFrame);
    
    %% ===== Wiring finale / stato iniziale =====
    % Inizializza modelli minimi richiesti dalla logica
    if ~isappdata(fig,'ImageHistoryData'), setappdata(fig,'ImageHistoryData',{}); end
    if ~isappdata(fig,'CurrentImagePath'), setappdata(fig,'CurrentImagePath',''); end
    
    % Selezione riga nella tabella parziale → ricarica anteprima (Tab 2)
    tblHist = findobj(fig,'Tag',T.HistoryTable);
    if ~isempty(tblHist) && isprop(tblHist,'CellSelectionCallback')
        tblHist.CellSelectionCallback = @(tbl,event) onHistorySelect(fig,event);
    end
    
    % Abilita doppio click sulla tabella completa (Tab 4), se disponibile
    enableHistoryTableDoubleClick(fig);
    
    % Stato iniziale a video
    if exist('setSessionStatus','file')==2
        setSessionStatus(fig,'Inizializzazione',true,[],'ok');
    end

end
