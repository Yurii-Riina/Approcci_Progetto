function s = toCsvString(x)
% TOCSVSTRING - Converte un valore di qualsiasi tipo in una stringa sicura per l'uso in un file CSV.
%
% Scopo:
%   Garantire che qualsiasi tipo di dato passato (numero, stringa, logico, ecc.)
%   venga trasformato in un formato testo compatibile con CSV, evitando che caratteri
%   speciali (come virgole o doppi apici) compromettano la struttura del file.
%
% Funzionamento:
%   - Numerici: convertiti in testo; vettori separati da spazi.
%   - Logici: convertiti in 'true' o 'false'.
%   - Stringhe/char: racchiusi tra virgolette se contengono caratteri speciali.
%   - Altri tipi: convertiti tramite `string()` e gestiti come char.
%
% Parametri:
%   x  -> variabile da convertire (può essere di qualsiasi tipo).
%
% Output:
%   s  -> stringa sicura per CSV.
%
% Note:
%   - Raddoppia i doppi apici interni per rispettare lo standard CSV.
%   - Riconosce e tratta correttamente valori vuoti e array di qualsiasi dimensione.
%   - Compatibile con UTF-8.

    % === Caso 1: valore vuoto ===
    if isempty(x)
        s = '';
        return;
    end

    % === Caso 2: numerico ===
    if isnumeric(x)
        if isscalar(x)
            % Numero singolo → stringa
            s = num2str(x);
        else
            % Vettore/matrice → valori separati da spazio
            s = strjoin(string(x(:))', ' ');
        end
        return;
    end

    % === Caso 3: logico (true/false) ===
    if islogical(x)
        % Conversione a stringa e normalizzazione in minuscolo
        s = char(lower(string(x)));
        return;
    end

    % === Caso 4: stringa MATLAB (string) ===
    if isstring(x)
        x = char(x); % converte in char per gestione unificata
    end

    % === Caso 5: char array ===
    if ischar(x)
        s = x;

        % Verifica presenza di caratteri speciali (virgola, doppio apice, a capo)
        needQuote = contains(s, {',','"','\n','\r'});

        % Raddoppia eventuali doppi apici interni
        s = strrep(s, '"', '""');

        % Racchiude tra virgolette se necessario
        if needQuote
            s = ['"' s '"'];
        end
        return;
    end

    % === Caso 6: altri tipi di dato (struct, object, ecc.) ===
    try
        % Tentativo di conversione generica
        s = char(string(x));
    catch
        % Se non convertibile, placeholder generico
        s = '<obj>';
    end

    % Passa nuovamente dal ramo "char" per applicare regole CSV
    s = toCsvString(s);

end