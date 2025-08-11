function c = aschar(x)
    if isstring(x), c = char(x); elseif ischar(x), c = x; else, c = char(string(x)); end
end