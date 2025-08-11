function writeFullLog(fig, msg)
    box = findobj(fig,'Tag','FullLogBox');
    if isempty(box), return; end
    ts = char(datetime('now','Format','HH:mm:ss'));
    box.Value = [{[ts ' – ' char(msg)]}; box.Value];
end