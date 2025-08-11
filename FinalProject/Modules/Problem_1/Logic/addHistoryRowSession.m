function addHistoryRowSession(fig, name, typeStr, sizeKB, tagStr, classStr)

    tbl = findobj(fig,'Tag','HistoryTableFull');
    if isempty(tbl), return; end

    D = tbl.Data;
    if isempty(D), D = {}; end

    if nargin<4 || isempty(sizeKB), sizeKB = ''; end
    if nargin<5, tagStr = ''; end

    ts = char(datetime('now','Format','dd-MM-yyyy HH:mm'));
    newRow = {name, ts, upper(typeStr), sizeKB, tagStr, char(classStr)};
    
    tbl.Data = [D; newRow];
end