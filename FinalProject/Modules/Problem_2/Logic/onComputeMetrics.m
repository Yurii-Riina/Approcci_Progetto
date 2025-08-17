function onComputeMetrics(fig)
% Calcola metriche dalla matrice corrente (sempre sui CONTEGGI) e popola la Tab3.

    % --- fetch stato corrente
    C      = getappdata(fig,'CurrentConfMat');
    labels = getappdata(fig,'CurrentLabels');

    if isempty(C) || isempty(labels)
        try uialert(fig,'Carica prima una matrice.','Nessun dato');
        catch
        end
        logP2(fig,'[P2] onComputeMetrics: nessuna matrice presente.');
        return;
    end

    % --- validazioni minime
    if ~ismatrix(C) || size(C,1)~=size(C,2)
        try uialert(fig,'La matrice deve essere quadrata (NxN).','Input non valido');
        catch
        end
        logP2(fig,sprintf('[P2] onComputeMetrics: matrice non quadrata (%dx%d).',size(C,1),size(C,2)));
        return;
    end

    % --- metriche (sempre su conteggi grezzi)
    N = size(C,1);
    support = sum(C,2);              % campioni per classe (somma riga)
    TP      = diag(C);               % veri positivi
    acc_i   = nan(N,1);
    nz      = support>0;
    acc_i(nz) = TP(nz) ./ support(nz);

    denom   = sum(C(:));
    if denom>0
        accG = sum(diag(C)) / denom;
    else
        accG = NaN;
    end

    % --- aggiorna UI Tab3
    try
        updateMetricsUI(fig, labels, TP, support, acc_i, accG);
    catch ME
        logP2(fig, sprintf('[P2] updateMetricsUI errore: %s', ME.message));
    end

    % --- log
    logP2(fig, sprintf('[P2] Metriche calcolate. AccGlobale=%.2f%%', 100*accG));
end
