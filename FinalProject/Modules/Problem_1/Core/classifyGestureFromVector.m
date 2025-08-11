function gesture = classifyGestureFromVector(fv)
% classifyGestureFromVector Classifica un gesto statico da feature vector
%   fv = [compactness, protrusionRatio, otherFeature]
%   gesture = 'sinistra' | 'destra' | 'stop' | 'riposo'

    % Soglie (da calibrare):
    %c_stop   = 0.45;   % compattezza tipica del gesto STOP
    %pr_right = 1.2;    % protrusionRatio > soglia → destra
    %pr_left  = 0.8;    % protrusionRatio < soglia → sinistra

    c_stop   = 0.05;   % compattezza tipica del gesto STOP
    pr_right = 1.2;    % protrusionRatio > soglia → destra
    pr_left  = 0.9;    % protrusionRatio < soglia → sinistra
    pr_stop_low  = 1.05;  % limiti di pr per riconoscere lo stop
    pr_stop_high = 1.20;

    c  = fv(1);
    pr = fv(2);
    % fv(3) = otherFeature;  % eventualmente ampliare le regole

    % Regole IF–THEN
    if pr > pr_right
        gesture = "destra";
    elseif pr < pr_left
        gesture = "sinistra";
    elseif c < c_stop && pr >= pr_stop_low && pr <= pr_stop_high
        % open-palm solo se pr non è già un gesto laterale
        gesture = "stop";
    else
        gesture = "riposo";
    end
end
