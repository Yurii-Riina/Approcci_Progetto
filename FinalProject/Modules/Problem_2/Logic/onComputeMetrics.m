function onComputeMetrics(fig)
% ONCOMPUTEMETRICS  Calcola metriche sui CONTEGGI correnti e popola la Tab3.
% =====================================================================================
% PURPOSE
%   Dalla matrice di confusione corrente (conteggi grezzi), calcola:
%     - support per classe (somma riga)
%     - true positives per classe (diag)
%     - accuratezza per classe (TP./support, NaN se support=0)
%     - accuratezza globale (sum(diag(C))/sum(C,'all'), NaN se somma totale=0)
%   e aggiorna la UI "📈 Metriche" tramite updateMetricsUI.
%
% CONTRACT
%   AppData richiesti:
%     - 'CurrentConfMat' : matrice NxN dei conteggi
%     - 'CurrentLabels'  : 1xN etichette (cellstr/string)
%
% SCOPE
%   - LOGIC/UI wiring con calcoli O(N) banali e senza I/O.
%   - Nessuna normalizzazione: i calcoli avvengono SEMPRE sui conteggi.
%
% ROBUSTEZZA
%   - Guardie su presenza dati, quadraticità, tipo/finitezza numerica.
%   - Tollerante: usa uialert (best-effort) + logP2; nessun throw fatale.
% =====================================================================================

    %% --- 0) Fetch stato corrente ----------------------------------------------------
    C      = getappdata(fig,'CurrentConfMat');
    labels = getappdata(fig,'CurrentLabels');

    if isempty(C) || isempty(labels)
        try uialert(fig,'Carica prima una matrice.','Nessun dato'); catch, end
        logP2(fig,'[P2] onComputeMetrics: nessuna matrice presente.');
        return;
    end

    %% --- 1) Validazioni minime su forma e valori -----------------------------------
    if ~ismatrix(C) || size(C,1) ~= size(C,2)
        try uialert(fig,'La matrice deve essere quadrata (NxN).','Input non valido'); catch, end
        logP2(fig, sprintf('[P2] onComputeMetrics: matrice non quadrata (%dx%d).', size(C,1), size(C,2)));
        return;
    end
    if ~isnumeric(C) && ~islogical(C)
        try uialert(fig,'La matrice deve essere numerica (o logical).','Input non valido'); catch, end
        logP2(fig,'[P2] onComputeMetrics: matrice non numerica.');
        return;
    end
    if ~all(isfinite(C(:)))
        try uialert(fig,'La matrice contiene NaN/Inf.','Input non valido'); catch, end
        logP2(fig,'[P2] onComputeMetrics: valori NaN/Inf rilevati.');
        return;
    end
    N = size(C,1);
    % Coerenza labels ↔ N (non bloccare; se incoerenti, fermarsi con messaggio chiaro)
    if numel(labels) ~= N
        try uialert(fig,sprintf('Le etichette devono essere %d (trovate %d).',N,numel(labels)),'Labels non coerenti'); catch, end
        logP2(fig, sprintf('[P2] onComputeMetrics: labels incoerenti (N=%d, labels=%d).', N, numel(labels)));
        return;
    end

    %% --- 2) Metriche (sempre su conteggi grezzi) -----------------------------------
    support = sum(C, 2);           % campioni per classe (somma riga)
    TP      = diag(C);             % veri positivi
    acc_i   = nan(N,1);            % accuratezza per classe in [0..1]
    nz      = support > 0;
    acc_i(nz) = TP(nz) ./ support(nz);

    denom = sum(C, 'all');
    if denom > 0
        accG = sum(diag(C)) / denom;
    else
        accG = NaN;
    end

    %% --- 3) Aggiornamento UI Tab3 ---------------------------------------------------
    try
        updateMetricsUI(fig, labels, TP, support, acc_i, accG);
    catch ME
        logP2(fig, sprintf('[P2] updateMetricsUI errore: %s', ME.message));
    end

    %% --- 4) Log sintetico -----------------------------------------------------------
    % Mostra sempre due decimali; se NaN, verrà stampato "NaN%"
    logP2(fig, sprintf('[P2] Metriche calcolate. AccGlobale=%.2f%%', 100*accG));
end
