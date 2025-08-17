function onPasteMatrix(fig)
% Apre un dialog per incollare una matrice (csv/spazi); parsea, valida e visualizza.
    prompt = {'Incolla qui la matrice (righe separate da newline):', ...
              'Etichette classi (opzionale, separate da virgola):'};
    titleDlg = 'Incolla matrice';
    dims = [8 80; 1 80];
    def  = {"1,2,0; 0,3,1; 0,1,4",""};  % default di cortesia
    answer = inputdlg(prompt, titleDlg, dims, def);
    if isempty(answer), logP2(fig,'Incolla: annullato.'); return; end

    raw = strtrim(answer{1});
    rawLabels = strtrim(answer{2});

    try
        % parse semplice: supporta ; come separatore di riga e virgola/spazio come colonna
        rows = regexp(raw, '[;\n\r]+', 'split');
        rows = rows(~cellfun('isempty',rows));
        C = [];
        for i = 1:numel(rows)
            cols = regexp(strtrim(rows{i}), '[,\s]+', 'split');
            cols = cols(~cellfun('isempty',cols));
            C(i,:) = str2double(cols); %#ok<AGROW>
        end

        % labels opzionali
        if ~isempty(rawLabels)
            parts = regexp(rawLabels, '\s*,\s*', 'split');
            labels = strtrim(parts);
        else
            labels = arrayfun(@(k)sprintf('Class %d',k), 1:size(C,1), 'UniformOutput', false);
        end

        S = validateConfMat(C, labels);
        if ~S.ok
            uialert(fig,S.msg,'Input non valido'); 
            logP2(fig,['ERRORE incolla: ' S.msg]);
            return;
        end

        setappdata(fig,'CurrentConfMat', C);
        setappdata(fig,'CurrentLabels', labels);
        opts = getappdata(fig,'CurrentOpts');
        ax   = findobj(fig,'Tag','AxesCM');
        plotConfusionMatrix(ax, C, labels, opts);
        logP2(fig, sprintf('Matrice incollata: [%dx%d]', size(C,1), size(C,2)));

    catch ME
        uialert(fig, ME.message, 'Errore parsing');
        logP2(fig, ['ERRORE incolla: ' ME.message]);
    end
end
