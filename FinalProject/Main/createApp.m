function createApp()
% CREATEAPP  Avvia l'applicazione principale dei progetti "Approcci e Sistemi".
%
% Sintesi
%   - Inizializza i percorsi (initPaths).
%   - Costruisce la finestra principale con 4 tab: Home, Chi siamo, Documentazione, Progetti.
%   - Ogni tab usa una grafica coerente (pannelli “card”) e un footer comune.
%   - Nel tab “Progetti” viene esposto l’entry point del Modulo 1.
%
% Prerequisiti (sul path, vedi initPaths):
%   SharedUtils/addFooter.m                 – footer unico parametrico
%   SharedUtils/styleCardPanel.m            – pannello “card” con titolo
%   SharedUtils/pushEffect.m                – wrapper effetto-pressione per bottoni
%   SharedUtils/highlightTab.m              – evidenziazione icona della tab attiva
%   SharedUtils/simulatePress.m             – placeholder “press” per moduli non attivi
%   SharedUtils/openPDF.m                   – apertura sicura della relazione PDF
%   Modules/Problem_1/UI/staticGestureRecognitionUI.m
%   Modules/Problem_1/UI/launchProblem.m   – helper che chiude fig corrente e apre il Modulo 1
%
% Note
%   - La UI usa posizionamento assoluto (pixel). Se in futuro rendi la finestra
%     ridimensionabile, conviene migrare a uigridlayout.
%   - Gli stili colore sono volutamente soft per non affaticare e per coerenza
%     con il resto del progetto.

%% ==== Bootstrap: path e finestra principale ====
    try
        initPaths();  % porta sul path Modules/*, SharedUtils, etc.
    catch ME
        % Mostra un alert “amichevole” e rilancia per logging/diagnostica
        uialert(uifigure, sprintf('initPaths ha fallito:\n%s', ME.message), 'Errore path');
        rethrow(ME);
    end

    % Finestra principale dell’app
    fig = uifigure('Name', 'Approcci e Sistemi 2024/2025', ...
                   'Position', [300 150 900 600], ...
                   'Color',    [0.96 0.96 0.96]);

    % Gruppo di tab (barra a sinistra simulata con una colonna fissa)
    tg = uitabgroup(fig, 'Position', [40 0 860 600]);

    % Elenco descrittivo dei moduli (usato nella Documentazione e nei “card”)
    moduli = {
        '🖐️ Problema 1 – Riconoscimento gesti statici'
        '📊 Problema 2 – Analisi matrici di confusione'
        '🎨 Problema 3 – Color Structure Descriptor'
        '⚙️ Problema 4 – Modellazione e simulazione motore'
        '📈 Problema 5 – Analisi segnali e rilevamento anomalie'
    };

%% ==== Tab 1: Home ====
    tab1 = uitab(tg, 'Title', '🏠 Home');

    % Banner informativo in alto
    banner(tab1, 'Benvenuto! Qui puoi esplorare i contenuti del progetto.');

    % Titolo
    uilabel(tab1, 'Text', 'APPROCCI E SISTEMI 2024/2025', ...
        'FontSize', 28, 'FontWeight', 'bold', 'FontName', 'Segoe UI', ...
        'HorizontalAlignment', 'center', 'Position', [120 460 700 60]);

    % Sottolineatura decorativa
    uilabel(tab1, 'Text', '', 'BackgroundColor', [0.20 0.35 1.00], ...
        'Position', [150 450 600 3]);

    % Leggera “ombra” per distacco visivo
    uipanel(tab1, 'Position', [105 245 700 185], ...
        'BackgroundColor', [0.85 0.85 0.88], 'BorderType', 'none');

    % Card descrittivo
    mainPanel = styleCardPanel(tab1, 'Descrizione del progetto', [100 250 700 180]);
    descrizione = sprintf([ ...
        'Questa applicazione MATLAB è stata sviluppata come interfaccia grafica unificata per il progetto del corso\n', ...
        '''Approcci e Sistemi di Interfacciamento per i Videogame e la Realtà Virtuale''.\n\n', ...
        'Consente di accedere e gestire con semplicità i diversi moduli realizzati, ciascuno dedicato a un problema\n', ...
        'specifico legato all’interazione uomo-macchina, all’elaborazione di segnali, alla visione artificiale e\n', ...
        'alla modellazione dinamica.\n\n', ...
        'L’obiettivo è fornire uno strumento funzionale, ordinato e facilmente navigabile, che permetta agli utenti\n', ...
        'di esplorare e testare i singoli moduli attraverso un’interfaccia moderna e intuitiva.']);
    uilabel(mainPanel, 'Text', descrizione, ...
        'FontSize', 12, 'FontName', 'Segoe UI', ...
        'Position', [10 10 680 140], 'HorizontalAlignment', 'left');

    addFooter(tab1, 'createApp');

%% ==== Tab 2: Chi siamo ====
    tab2 = uitab(tg, 'Title', '👥 Chi siamo');

    uilabel(tab2, 'Text', 'Il nostro gruppo è composto da:', ...
        'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Segoe UI', ...
        'Position', [300 480 400 40]);

    membri = {'Yurii Riina', 'Nicolò Gioacchini', 'Thomas Marinucci'};
    for i = 1:3
        x = 80 + (i-1)*250;

        % “Ombra” + card con titolo (nome)
        uipanel(tab2, 'Position', [x+5, 235, 200, 230], ...
            'BackgroundColor', [0.85 0.85 0.88], 'BorderType', 'none');
        card = styleCardPanel(tab2, membri{i}, [x, 240, 200, 230]);

        % Avatar placeholder e ruolo
        uiimage(card, 'ImageSource', 'AvatarProfiles.png', ...
            'Position', [35, 100, 130, 100], 'ScaleMethod', 'fit');
        uilabel(card, 'Text', 'Studente UnivPM', ...
            'FontSize', 11, 'FontName', 'Segoe UI', ...
            'Position', [10, 60, 180, 30], 'HorizontalAlignment', 'center');
    end

    addFooter(tab2, 'createApp');

%% ==== Tab 3: Documentazione ====
    tab3 = uitab(tg, 'Title', '📄 Documentazione');

    banner(tab3, 'Consulta la guida dei moduli e accedi alla documentazione.');

    uipanel(tab3, 'Position', [85 215 750 300], ...
        'BackgroundColor', [0.85 0.85 0.88], 'BorderType', 'none');
    docPanel = styleCardPanel(tab3, '📘 Guida e suddivisione moduli', [80 220 750 300]);

    uitextarea(docPanel, ...
        'Value', [{'Questa sezione descrive sinteticamente le funzionalità implementate per ciascun problema.'}, {''}, moduli(:)'], ...
        'Editable', 'off', 'FontSize', 12, 'FontName', 'Segoe UI', ...
        'Position', [10 10 730 260], 'Tooltip', 'Riepilogo moduli disponibili');

    uibutton(tab3, 'Text', '📂 Apri relazione PDF', ...
        'FontSize', 13, 'FontName', 'Segoe UI', ...
        'Tooltip', 'Apre il file PDF della relazione', ...
        'Position', [350 240 200 40], ...
        'ButtonPushedFcn', @(~,~) openPDF(fig));

    addFooter(tab3, 'createApp');

%% ==== Tab 4: Progetti (moduli) ====
    tab4 = uitab(tg, 'Title', '🧩 Progetti');

    uilabel(tab4, 'Text', 'Moduli disponibili:', ...
        'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Segoe UI', ...
        'Position', [350 515 300 30]);

    % Layout manuale dei 5 “card”
    layoutX = [120, 480, 120, 480, 300];
    layoutY = [400, 400, 270, 270, 140];
    bg1     = [0.93 0.95 0.97];

    for i = 1:5
        x = layoutX(i);  y = layoutY(i);

        % “Ombra” + card
        uipanel(tab4, 'Position', [x+5, y-5, 300, 110], ...
            'BackgroundColor', [0.85 0.85 0.88], 'BorderType', 'none');
        card = styleCardPanel(tab4, moduli{i}, [x, y, 300, 110]);
        card.BackgroundColor = bg1;

        % Callback logica: apre Modulo 1, oppure placeholder
        switch i
            case 1
                
                btnText   = '▶ Visualizza modulo';
                tip       = 'Apri il modulo attivo';
                logicalCb = @(~,~) launchModule(fig, 1, @staticGestureRecognitionUI, struct('Title','Modulo 1'));
            case 2
                
                btnText   = '▶ Visualizza modulo';
                tip       = 'Apri il modulo attivo';
                logicalCb = @(~,~) launchModule(fig, 2, @confusionMatrixUI, struct('Title','Modulo 2'));
            otherwise
                logicalCb = @(src,evt) simulatePress(src);
                btnText   = '🔒 Modulo non attivo';
                tip       = 'Modulo non ancora disponibile';
        end

        % Bottone azione con effetto-pressione wrappato
        btn = uibutton(card, 'Text', btnText, ...
            'FontSize', 12, 'FontName', 'Segoe UI', ...
            'Position', [25 35 250 35], 'Tooltip', tip, ...
            'BackgroundColor', [0.94 0.94 0.94]);

        btn.ButtonPushedFcn = @(src,evt) pushEffect(btn, logicalCb, src, evt);
    end

    % Barra verticale “menu” con icone a sinistra
    uipanel(fig, 'Position', [0 0 40 600], ...
        'BackgroundColor', [0.90 0.92 0.96], 'BorderType', 'none');
    icons      = {'🏠','👥','📄','🧩'};
    iconLabels = gobjects(1,4);
    tabRefs    = [tab1, tab2, tab3, tab4];

    barWidth   = 40;
    buttonSize = 30;
    padding    = (barWidth - buttonSize) / 2;

    for i = 1:4
        yPos = 600 - i*70 + padding;  % centratura verticale

        iconLabels(i) = uibutton(fig, ...
            'Text', icons{i}, 'FontSize', 13, 'FontWeight', 'bold', ...
            'FontColor', [0.4 0.4 0.4], 'BackgroundColor', [0.90 0.92 0.96], ...
            'Position', [1 + padding, yPos, buttonSize, buttonSize], ...
            'Tooltip', sprintf('Vai a %s', tabRefs(i).Title), ...
            'ButtonPushedFcn', @(~,~) set(tg, 'SelectedTab', tabRefs(i)));
    end

    % Evidenzia l’icona della tab attiva
    tg.SelectionChangedFcn = @(~,event) highlightTab(iconLabels, event.NewValue.Title);

    addFooter(tab4, 'createApp');
end
