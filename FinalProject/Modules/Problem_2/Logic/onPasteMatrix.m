function onPasteMatrix(fig)
% ONPASTEMATRIX  Dialogo “incolla matrice” → parse, validazione e visualizzazione.
% =====================================================================================
% PURPOSE
%   Consente di incollare una matrice di confusione (testo) e opzionali etichette,
%   quindi:
%     1) effettua il parsing robusto del testo in una matrice numerica C
%     2) costruisce/normalizza le etichette (se fornite)
%     3) valida C+labels tramite validateConfMat (Core)
%     4) aggiorna AppData e ridisegna la heatmap in Tab2
%
% INPUT
%   fig : handle della uifigure principale (richiesto).
%
% UX
%   - Supporta separatori riga = ';' e newline; colonna = virgola/spazi.
%   - Esempio di default nel dialog per guidare l’utente.
%   - Messaggi d’errore chiari su parsing/validazione.
%
% NON-GOALS
%   - Nessuna normalizzazione statistica, nessun salvataggio su file.
% =====================================================================================

    % --- 0) Dialog input -------------------------------------------------------------
    prompt   = {'Incolla qui la matrice (righe separate da newline):', ...
                'Etichette classi (opzionale, separate da virgola):'};
    titleDlg = 'Incolla matrice';
    dims     = [8 80; 1 80];
    def      = {"1,2,0; 0,3,1; 0,1,4",""};  % default di cortesia

    answer = inputdlg(prompt, titleDlg, dims, def);
    if isempty(answer)
        logP2(fig,'Incolla: annullato.');
        return;
    end

    raw       = strtrim(answer{1});
    rawLabels = strtrim(answer{2});

    try
        % --- 1) Parsing testo → matrice numerica C -----------------------------------
        % Righe: separatori ';' o newline
        rows = regexp(raw, '[;\n\r]+', 'split');
        rows = rows(~cellfun('isempty',rows));

        C = [];
        expectedCols = -1;
        for i = 1:numel(rows)
            % Colonne: separatori virgola o spazio (uno o più)
            cols = regexp(strtrim(rows{i}), '[,\s]+', 'split');
            cols = cols(~cellfun('isempty',cols));
            if expectedCols < 0
                expectedCols = numel(cols);
            elseif numel(cols) ~= expectedCols
                error('Riga %d ha %d colonne ma ci si aspetta %d: matrice non rettangolare.', ...
                      i, numel(cols), expectedCols);
            end
            % str2double → numerico (può produrre NaN su input non numerici)
            C(i,:) = str2double(cols); %#ok<AGROW>
        end

        % Check NaN dal parsing (prima della validazione “Core”)
        if any(isnan(C), 'all')
            error('La matrice contiene valori non numerici: controlla separatori e decimali.');
        end

        % --- 2) Labels opzionali -----------------------------------------------------
        if ~isempty(rawLabels)
            parts  = regexp(rawLabels, '\s*,\s*', 'split');
            labels = strtrim(parts);
        else
            labels = arrayfun(@(k)sprintf('Class %d',k), 1:size(C,1), 'UniformOutput', false);
        end

        % --- 3) Validazione “core” ---------------------------------------------------
        S = validateConfMat(C, labels);
        if ~S.ok
            uialert(fig, S.msg, 'Input non valido');
            logP2(fig, ['ERRORE incolla: ' S.msg]);
            return;
        end

        % --- 4) Stato + Render -------------------------------------------------------
        setappdata(fig,'CurrentConfMat', C);
        setappdata(fig,'CurrentLabels',  labels);

        % Opzioni correnti (fallback a default se mancanti)
        opts = getappdata(fig,'CurrentOpts');
        if isempty(opts)
            opts = struct('normalizeRows',false,'showCounts',true,'showPerc',false,'cmap','parula','highlightDiag',true);
        end

        % Axes target: usa AppData se presente, altrimenti cerca per Tag
        ax = getappdata(fig,'AxesCMHandle');
        if isempty(ax) || ~isvalid(ax)
            axAll = findobj(fig,'Type','uiaxes','-and','Tag','AxesCM');
            if isempty(axAll)
                uialert(fig,'Axes della matrice non trovato. Apri la Tab Matrice e riprova.','UI non pronta');
                logP2(fig,'ERRORE incolla: AxesCM non trovato.');
                return;
            end
            ax = axAll(1);
            setappdata(fig,'AxesCMHandle', ax);
        end

        plotConfusionMatrix(ax, C, labels, opts);
        logP2(fig, sprintf('Matrice incollata: [%dx%d]', size(C,1), size(C,2)));
        drawnow limitrate;

    catch ME
        % Errori di parsing/validazione/plot: alert + log, no crash
        try uialert(fig, ME.message, 'Errore parsing'); catch, end
        logP2(fig, ['ERRORE incolla: ' ME.message]);
    end
end
