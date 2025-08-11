function s = toCsvString(x)
    % Converte un valore in stringa sicura per CSV:
    % - numeri -> stringa
    % - logical -> "true"/"false"
    % - string/char -> citata se contiene virgole/virgolette/CRLF
    if isempty(x)
        s = '';
        return;
    end
    if isnumeric(x)
        if isscalar(x)
            s = num2str(x);
        else
            s = strjoin(string(x(:))', ' '); % vettori -> "v1 v2 v3"
        end
        return;
    end
    if islogical(x)
        s = string(x);
        s = char(lower(s));
        return;
    end
    if isstring(x), x = char(x); end
    if ischar(x)
        s = x;
        % raddoppia le virgolette interne e racchiudi tra doppi apici se necessario
        needQuote = contains(s, {',','"','\n','\r'});
        s = strrep(s, '"', '""');
        if needQuote, s = ['"' s '"']; end
        return;
    end
    % fallback generico
    try
        s = char(string(x));
    catch
        s = '<obj>';
    end
    s = toCsvString(s); % passa dal ramo char per quoting
end