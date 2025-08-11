function v = safeCell(S, field)
    if isfield(S,field) && ~isempty(S.(field))
        v = S.(field); 
    else
        if strcmp(field, 'FullLog')
            v = {''}; %per uitexarea
        else
            v = {}; 
        end
    end
end