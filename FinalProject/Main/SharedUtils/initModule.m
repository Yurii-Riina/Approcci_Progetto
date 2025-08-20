function initModule(plan, progress)
% INITMODULE  Esegue un piano di inizializzazione modulare con avanzamento.
% --------------------------------------------------------------------------------------
% INPUT
%   plan     : struct array dei passi, ciascuno con i campi:
%                .Name (char)   descrizione step (mostrata nella barra)
%                .Weight (0..1) peso relativo (sommatoria normale o non critica)
%                .Fn (function_handle) da eseguire: @() ...  (niente input/return)
%   progress : @(p,msg) che riceve p in [0..1] e messaggio opzionale
%
% NOTE
%   - Ogni .Fn può essere "pesante": accesso disco, preload, migrazioni, ecc.
%   - Gli errori dei singoli step vengono rilanciati (fallisce init) per scelta esplicita;
%     se vuoi “best-effort”, wrappa tu lo step nel piano gestendo i catch.
% --------------------------------------------------------------------------------------

    if nargin<2 || isempty(progress), progress = @(varargin)[]; end
    if isempty(plan), progress(1,'Pronto.'); return; end

    % normalizza i pesi (se non sommano a 1, scala)
    w = [plan.Weight];
    if any(~isfinite(w) | w<0), error('initModule: pesi invalidi nel piano.'); end
    total = sum(w);
    if total <= 0, w = ones(1,numel(plan))/numel(plan); total = 1; end
    w = w / total;

    acc = 0;
    for k = 1:numel(plan)
        msg = plan(k).Name;
        progress(acc, msg); drawnow;

        plan(k).Fn();  % esegui step

        acc = acc + w(k);
        progress(min(acc,1), msg);
    end

    progress(1, 'Pronto.');
end
