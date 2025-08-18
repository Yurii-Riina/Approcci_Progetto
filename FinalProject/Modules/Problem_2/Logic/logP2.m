function logP2(fig, msg, kind)
% logP2  Scrive una singola riga di log compatta nel box della Tab Matrice.
% kind (opz.): 'ok' (default) | 'warn' | 'err'

    if nargin<3 || isempty(kind), kind = 'ok'; end
    try
        box = findobj(fig,'Tag','LogBoxP2');
        if isempty(box) || ~isvalid(box), return; end

        ts  = char(datetime('now','Format','dd-MM-yyyy HH:mm'));
        tag = "";
        switch lower(kind)
            case 'warn', tag = " [WARN]";
            case 'err',  tag = " [ERR]";
            otherwise,   tag = "";
        end

        line = sprintf('[%s]%s %s', ts, tag, msg);

        old = box.Value;
        if ischar(old) || isstring(old), old = cellstr(old); end
        box.Value = [line; old(:)];
        drawnow limitrate;
    catch
        % silenzioso
    end
end
