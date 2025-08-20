function plan = moduleInitPlans(moduleId)
% MODULEINITPLANS  Registry centrale dei passi di inizializzazione per moduli e home.
% --------------------------------------------------------------------------------------
% INPUT
%   moduleId : 1..5 per i problemi, oppure 'createApp'
%
% OUTPUT
%   plan : struct array con campi .Name .Weight .Fn (vedi initModule)
% --------------------------------------------------------------------------------------

    struct('Name',{},'Weight',{},'Fn',{});

    switch string(moduleId)
        case "createApp"
            plan = [
               step('Init percorsi',  0.35, @safeInitPaths)     % initPaths() se presente
               step('Warmup UI',      0.40, @() pause(0.15))     % piccola attesa UI-gradevole
               step('Aggancio utils', 0.25, @() pause(0.05))
            ];

        case "1"
            plan = [
               step('Init percorsi',  0.25, @safeInitPaths)
               step('Asset base',     0.30, @() pause(0.10))     % placeholder leggero
               step('Preferenze',     0.20, @() pause(0.05))
               step('Warm cache',     0.25, @() pause(0.05))
            ];

        case "2"
            plan = [
               step('Init percorsi',    0.20, @safeInitPaths)
               step('Struttura dati',   0.25, @safeResolvePathsP2)  % resolvePathsP2 se c’è
               step('Demo matrices',    0.35, @safeCreateP2Demos)   % createP2Demos se c’è
               step('Warmup storia',    0.20, @() pause(0.05))      % il popolamento vero lo fa la UI
            ];

        % === esempi placeholder per futuri moduli ===
        case "3"
            plan = [ step('Init percorsi',1.0, @safeInitPaths) ];

        case "4"
            plan = [ step('Init percorsi',1.0, @safeInitPaths) ];

        case "5"
            plan = [ step('Init percorsi',1.0, @safeInitPaths) ];

        otherwise
            % default minimalista
            plan = [ step('Inizializzazione',1.0, @() pause(0.05)) ];
    end

    % ----- nested helpers: costruzione step e safe-call -----
    function s = step(name, w, fn)
        s = struct('Name',name,'Weight',w,'Fn',fn);
    end

    function safeInitPaths()
        if exist('initPaths','file')==2
            initPaths();
        end
    end

    function safeResolvePathsP2()
        if exist('resolvePathsP2','file')==2
            try resolvePathsP2(); catch, end
        end
    end

    function safeCreateP2Demos()
        if exist('createP2Demos','file')==2
            try createP2Demos(); catch, end
        end
    end
end
