function launchModule(prevFig, ~, buildFcn, opts)
% LAUNCHMODULE  Transizione con splash/progress verso Home o un modulo.
%   launchModule(prevFig,'home',@createApp)           % torna alla Home
%   launchModule(prevFig,'p1',  @staticGestureRecognitionUI)
%   launchModule(prevFig,'p2',  @confusionMatrixUI)
%
% opts (facoltativo): struct con campi:
%   .Title        (char) titolo del dialog [default: 'Avvio modulo']
%   .ShowDelaySec (double) ritardo artificiale prima di chiudere splash [0..]
%   .ClosePrev    (logical) chiudere prevFig? [true]

    if nargin < 4 || isempty(opts), opts = struct; end
    titleStr     = getfielddef(opts,'Title','Avvio modulo');
    minShowSec   = getfielddef(opts,'MinShowSec',0.80);   % durata minima percepita
    extraDelay   = getfielddef(opts,'ShowDelaySec',0.00); % eventuale ritardo addizionale

    % 1) Host splash indipendente (NON legato a prevFig)
    host = uifigure('Name', titleStr, ...
                    'Position', centerBox([380 120]), ...
                    'Color', [0.97 0.97 0.97], ...
                    'Visible','on');   % rimane in primo piano
    dlg  = uiprogressdlg(host, ...
            'Title', titleStr, ...
            'Message','Preparazione risorse…', ...
            'Indeterminate','on', ...
            'Cancelable','off');
    drawnow;

    t0 = tic;  err = [];
    % 2) Costruisci la nuova UI
    try
        feval(buildFcn);                 % crea createApp / Modulo 1 / Modulo 2
        drawnow;                         % rende visibile subito la nuova UI
    catch ME
        err = ME;
    end

    % 3) Mantieni lo splash per un tempo minimo uniforme
    while toc(t0) < (minShowSec + extraDelay)
        drawnow limitrate;
    end

    % 4) Chiudi splash e poi la finestra precedente (atomico)
    try
        if isvalid(dlg)
            close(dlg); 
        end
    catch
    end
    try
        if isvalid(host)
            delete(host); 
        end
    catch
    end
    try
        if ~isempty(prevFig) && isvalid(prevFig)
            delete(prevFig); 
        end
    catch
    end

    % 5) Propaga eventuale errore
    if ~isempty(err)
        rethrow(err); 
    end
end

% ------- helpers locali
function v = getfielddef(S,f,def)
    if isstruct(S) && isfield(S,f), v = S.(f); else, v = def; end
end

function pos = centerBox(sz)
% centro-lo splash sullo schermo principale
    r = get(0,'ScreenSize');  % [x y w h]
    w = sz(1); h = sz(2);
    x = r(1) + (r(3)-w)/2;  y = r(2) + (r(4)-h)/2;
    pos = [x y w h];
end