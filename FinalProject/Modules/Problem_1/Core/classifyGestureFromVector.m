function gesture = classifyGestureFromVector(fv)
    % CLASSIFYGESTUREFROMVECTOR  Classifica un gesto statico dato un vettore di feature.
    %
    % Sintassi
    %   gesture = classifyGestureFromVector(fv)
    %
    % Input
    %   fv : vettore numerico con almeno i primi 2 elementi:
    %        fv(1) = compactness (c)
    %        fv(2) = protrusionRatio (pr)
    %        fv(3) = altra feature opzionale (non usata qui)
    %
    % Output
    %   gesture : string ("sinistra" | "destra" | "stop" | "riposo")
    %
    % Logica (regole IF–THEN, priorità laterale → stop → riposo)
    %   - Se pr > pr_right   → "destra"
    %   - Se pr < pr_left    → "sinistra"
    %   - Altrimenti, se c < c_stop e pr ∈ [pr_stop_low, pr_stop_high] → "stop"
    %   - Altrimenti → "riposo"
    %
    % Note operative
    %   - Le soglie sono da calibrare su un dataset reale: iniziare con questi valori
    %     e poi fare grid-search o validazione incrociata per ottimizzarle.
    %   - Se fv è invalido (non numerico, troppo corto, NaN/Inf) restituisce "riposo".
    %
    % Esempio
    %   gesture = classifyGestureFromVector([0.04, 1.10, 0.7]);
    %   % => "stop" (compattezza bassa e pr vicino a 1)
    %
    
    %% Validazione input
    gesture = "riposo";              % default prudente
    if nargin < 1 || isempty(fv) || ~isnumeric(fv)
        return;
    end
    fv = fv(:);                      % forza vettore colonna
    if numel(fv) < 2
        return;
    end
    if any(~isfinite(fv(1:2)))       % NaN/Inf → risposta neutra
        return;
    end
    
    %% Soglie (calibrabili)
    % Compat. tipica dello STOP: molto bassa (mano aperta appiattisce il contorno)
    c_stop      = 0.05;
    
    % Lateralità: pr > 1 sbilanciato a destra, pr < 1 a sinistra
    pr_right    = 1.20;
    pr_left     = 0.90;
    
    % Finestra di pr in cui considerare "stop" (vicino a 1, quindi non laterale)
    pr_stop_low  = 1.05;
    pr_stop_high = 1.20;
    
    %% Estrazione feature minime
    c  = fv(1);
    pr = fv(2);
    % fv(3) eventualmente usabile per affinare la decisione
    
    %% Regole decisionali (priorità: destra/sinistra > stop > riposo)
    if pr > pr_right
        gesture = "destra";
    elseif pr < pr_left
        gesture = "sinistra";
    elseif c < c_stop && pr >= pr_stop_low && pr <= pr_stop_high
        gesture = "stop";
    else
        gesture = "riposo";
    end

end