function onLoadConfMat(fig)
% Carica una matrice di confusione da .mat o .csv, valida e visualizza.
    [file, path] = uigetfile({'*.mat;*.csv','MAT or CSV'}, 'Seleziona matrice di confusione');
    if isequal(file,0), logP2(fig,'Annullato.'); return; end
    full = fullfile(path,file);

    try
        [C, labels, meta] = importConfMat(full);
        S = validateConfMat(C, labels);
        if ~S.ok
            uialert(fig,S.msg,'Input non valido'); 
            logP2(fig, ['ERRORE: ' S.msg]); 
            return;
        end

        % memorizza stato corrente
        setappdata(fig,'CurrentConfMat', C);
        setappdata(fig,'CurrentLabels', labels);

        % disegna
        opts = getappdata(fig,'CurrentOpts');
        ax   = findobj(fig,'Tag','AxesCM');
        plotConfusionMatrix(ax, C, labels, opts);

        % log
        msg = sprintf('Caricato: %s [%dx%d]%s', meta.name, size(C,1), size(C,2), meta.note);
        logP2(fig,msg);

    catch ME
        uialert(fig, ME.message, 'Errore caricamento');
        logP2(fig, ['ERRORE caricamento: ' ME.message]);
    end
end
