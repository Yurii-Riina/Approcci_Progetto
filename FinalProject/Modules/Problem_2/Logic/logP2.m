function logP2(fig, msg)
% Appende una riga al log breve della Tab2.
    ta = findobj(fig,'Tag','LogBoxP2');
    if isempty(ta) || ~isvalid(ta), return; end
    val = ta.Value;
    timestamp = char(datetime('now','Format','dd-MM-yyyy HH:mm'));
    if ischar(val) || isstring(val), val = cellstr(val); end
    ta.Value = [{sprintf('[%s] %s', timestamp, msg)}; val(:)];
end
