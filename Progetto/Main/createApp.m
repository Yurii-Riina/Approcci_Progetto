function createApp()

    initPaths();

    fig = uifigure('Name', 'Approcci e Sistemi 2024/2025', ...
                   'Position', [300 150 900 600], ...
                   'Color', [0.96, 0.96, 0.96]);

    tg = uitabgroup(fig, 'Position', [40 0 860 600]);  % Spostato a destra per menu laterale

    moduli = {
        '🖐️ Problema 1 – Riconoscimento gesti statici'
        '📊 Problema 2 – Analisi matrici di confusione'
        '🎨 Problema 3 – Color Structure Descriptor'
        '⚙️ Problema 4 – Modellazione e simulazione motore'
        '📈 Problema 5 – Analisi segnali e rilevamento anomalie'
    };

    %% HOME
    tab1 = uitab(tg, 'Title', '🏠 Home');

    banner(tab1, 'Benvenuto! Qui puoi esplorare i contenuti del progetto.');

    uilabel(tab1, 'Text', 'APPROCCI E SISTEMI 2024/2025', ...
        'FontSize', 28, 'FontWeight', 'bold', 'FontName', 'Segoe UI', ...
        'HorizontalAlignment', 'center', 'Position', [120 460 700 60]);

    uilabel(tab1, 'Text', '', ...
        'BackgroundColor', [0.20, 0.35, 1.00], ...
        'Position', [150 450 600 3]);
    
    %ShadowPanel
    uipanel(tab1, 'Position', [105 245 700 185], ...
        'BackgroundColor', [0.85 0.85 0.88], 'BorderType', 'none');

    mainPanel = styleCardPanel(tab1, 'Descrizione del progetto', [100 250 700 180]);

    descrizione = sprintf([ ...
        'Questa applicazione MATLAB è stata sviluppata come interfaccia grafica unificata per il progetto del corso\n', ...
        '''Approcci e Sistemi di Interfacciamento per i Videogame e la Realtà Virtuale''.', ...
        '\n', ...
        'Consente di accedere e gestire con semplicità i diversi moduli realizzati, ciascuno dedicato a un problema\n', ...
        'specifico legato all’interazione uomo-macchina, all’elaborazione di segnali, alla visione artificiale e\n', ...
        'alla modellazione dinamica.\n', ...
        '\n', ...
        'L’obiettivo è fornire uno strumento funzionale, ordinato e facilmente navigabile, che permetta agli utenti\n', ...
        'di esplorare e testare i singoli moduli attraverso un’interfaccia moderna e intuitiva.']);

    uilabel(mainPanel, 'Text', descrizione, ...
        'FontSize', 12, 'FontName', 'Segoe UI', ...
        'Position', [10 10 680 140], ...
        'HorizontalAlignment', 'left');

    addFooter(tab1);

    %% CHI SIAMO
    tab2 = uitab(tg, 'Title', '👥 Chi siamo');

    uilabel(tab2, 'Text', 'Il nostro gruppo è composto da:', ...
        'FontSize', 18, 'FontWeight', 'bold', ...
        'FontName', 'Segoe UI', 'Position', [300 480 400 40]);

    membri = {'Yurii Riina', 'Nicolò Gioacchini', 'Thomas Marinucci'};
    for i = 1:3
        x = 80 + (i-1)*250;

        uipanel(tab2, 'Position', [x+5, 235, 200, 230], ...
            'BackgroundColor', [0.85 0.85 0.88], 'BorderType', 'none');

        card = styleCardPanel(tab2, membri{i}, [x, 240, 200, 230]);

        uiimage(card, 'ImageSource', 'AvatarProfiles.png', ...
            'Position', [35, 100, 130, 100], 'ScaleMethod', 'fit');

        uilabel(card, 'Text', 'Studente UnivPM', ...
            'FontSize', 11, 'FontName', 'Segoe UI', ...
            'Position', [10, 60, 180, 30], 'HorizontalAlignment', 'center');
    end

    addFooter(tab2);

    %% DOCUMENTAZIONE
    tab3 = uitab(tg, 'Title', '📄 Documentazione');

    banner(tab3, 'Consulta la guida dei moduli e accedi alla documentazione.');
    
    %ShadowPanel
    uipanel(tab3, 'Position', [85 215 750 300], ...
        'BackgroundColor', [0.85 0.85 0.88], 'BorderType', 'none');

    docPanel = styleCardPanel(tab3, '📘 Guida e suddivisione moduli', [80 220 750 300]);

    uitextarea(docPanel, ...
        'Value', [
            {'Questa sezione descrive sinteticamente le funzionalità implementate per ciascun problema.'}, {''}, ...
            moduli(:)' ], ... %moduli{:} },
        'Editable', 'off', 'FontSize', 12, 'FontName', 'Segoe UI', ...
        'Position', [10 10 730 260], 'Tooltip', 'Riepilogo moduli disponibili');

    uibutton(tab3, ...
        'Text', '📂 Apri relazione PDF', 'FontSize', 13, 'FontName', 'Segoe UI', ...
        'Tooltip', 'Apre il file PDF della relazione', ...
        'Position', [350 240 200 40], 'ButtonPushedFcn', @(btn,event)openPDF(fig));

    addFooter(tab3);

    %% PROGETTI
    tab4 = uitab(tg, 'Title', '🧩 Progetti');

    uilabel(tab4, 'Text', 'Moduli disponibili:', ...
        'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Segoe UI', ...
        'Position', [350 515 300 30]);

    layoutX = [120, 480, 120, 480, 300];
    layoutY = [400, 400, 270, 270, 140];
    bg1 = [0.93 0.95 0.97];
    %bg2 = [0.98 0.98 1.00];

    for i = 1:5
        x = layoutX(i);
        y = layoutY(i);

        uipanel(tab4, 'Position', [x+5, y-5, 300, 110], ...
            'BackgroundColor', [0.85 0.85 0.88], 'BorderType', 'none');

        bgColor = bg1;
        %if mod(i,2)==0
        %    bgColor = bg1;
        %else
        %    bgColor = bg2;
        %end
        uip = styleCardPanel(tab4, moduli{i}, [x, y, 300, 110]);
        uip.BackgroundColor = bgColor;

        if i == 1
            btn = uibutton(uip, 'Text', '▶ Visualizza modulo', ...
                'FontSize', 12, 'FontName', 'Segoe UI', 'Position', [25, 35, 250, 35], ...
                'Tooltip', 'Apri il modulo attivo', 'ButtonPushedFcn', @(~,~) launchProblem1(fig), ...
                'Enable', 'on', 'BackgroundColor', [0.94 0.94 0.94]);
        else
            btn = uibutton(uip, 'Text', '🔒 Modulo non attivo', ...
                'FontSize', 12, 'FontName', 'Segoe UI', 'Position', [25, 35, 250, 35], ...
                'Tooltip', 'Modulo non ancora disponibile', 'ButtonPushedFcn', @(btn, ~)simulatePress(btn));
        end

        % Hover effect (semplificato)
        btn.ButtonPushedFcn = @(src,~) pushEffect(src, btnFcn);
    end
    
    % Menu verticale
    uipanel(fig, 'Position', [0 0 40 600], 'BackgroundColor', [0.90 0.92 0.96], 'BorderType', 'none');
    icons = {'🏠','👥','📄','🧩'};
    iconLabels = gobjects(1,4);

    % Menu verticale cliccabile
    tabRefs = [tab1, tab2, tab3, tab4];

    barWidth = 40;
    buttonSize = 30;
    padding = (barWidth - buttonSize) / 2;
    
    for i = 1:4
        yPos = 600 - i*70 + padding;  % Centra il bottone verticalmente nella barra
    
        iconLabels(i) = uibutton(fig, ...
            'Text', icons{i}, ...
            'FontSize', 13, ...  % 👈 emoji ridotta
            'FontWeight', 'bold', ...
            'FontColor', [0.4 0.4 0.4], ...
            'BackgroundColor', [0.90 0.92 0.96], ...
            'Position', [1 + padding, yPos, buttonSize, buttonSize], ...
            'Tooltip', sprintf('Vai a %s', tabRefs(i).Title), ...
            'ButtonPushedFcn', @(~,~) set(tg, 'SelectedTab', tabRefs(i)));
    end

    % Evidenziazione attiva tab
    tg.SelectionChangedFcn = @(src,event) highlightTab(iconLabels, event.NewValue.Title);    

    addFooter(tab4);
end

function pushEffect(btn, actionFcn)
    origColor = btn.BackgroundColor;
    highlightColor = [0.80 0.87 1.00];
    
    % Cambia colore velocemente
    btn.BackgroundColor = highlightColor;
    drawnow;
    pause(0.1);
    
    % Ripristina subito
    btn.BackgroundColor = origColor;
    drawnow;

    % Esegui l'azione
    actionFcn();
end

function banner(parent, message)
    uilabel(parent, 'Text', ['ℹ️ ', message], 'FontSize', 12, 'FontName', 'Segoe UI', ...
        'Position', [40, 550, 800, 30], 'FontColor', [0.2 0.2 0.5]);
end

function highlightTab(iconLabels, selectedTitle)
    icone = {'🏠','👥','📄','🧩'};
    for i = 1:4
        if contains(selectedTitle, icone{i})
            iconLabels(i).FontColor = [0.10 0.35 0.80];
            iconLabels(i).FontWeight = 'bold';
        else
            iconLabels(i).FontColor = [0.4 0.4 0.4];
            iconLabels(i).FontWeight = 'normal';
        end
    end
end

function outPanel = styleCardPanel(parent, title, position)
    outPanel = uipanel(parent, 'Title', title, ...
        'FontWeight', 'bold', 'FontName', 'Segoe UI', 'FontSize', 11, ...
        'Position', position, 'BackgroundColor', [0.97 0.97 0.97], ...
        'BorderType', 'line');
end

function simulatePress(btn)
    origColor = btn.BackgroundColor;
    btn.BackgroundColor = [0.80 0.87 1.00];
    pause(0.15);
    btn.BackgroundColor = origColor;
end

function addFooter(tab)
    uilabel(tab, 'Text', sprintf(['\n© 2025 Yurii Riina, Nicolò Gioacchini, Thomas Marinucci — Tutti i diritti riservati.\n', ...
                                  'Questo software è protetto da copyright.']), ...
        'FontSize', 10, 'FontName', 'Segoe UI', 'HorizontalAlignment', 'center', ...
        'Position', [100, 10, 700, 35], 'FontColor', [0.5 0.5 0.5], ...
        'BackgroundColor', [0.96 0.96 0.96]);

    uiimage(tab, 'ImageSource', 'logo_UNIVPM.png', ...
        'Position', [110 10 80 40], 'ScaleMethod', 'fit');
end

function openPDF(parentfig)
    filepath = fullfile(pwd, 'doc', 'relazione.pdf');
    if isfile(filepath)
        open(filepath);
    else
        uialert(parentfig, 'File PDF non trovato nella cartella /doc.', 'Errore');
    end
end

function launchProblem1(prevFig)
    delete(prevFig);
    staticGestureRecognitionUI();
end
