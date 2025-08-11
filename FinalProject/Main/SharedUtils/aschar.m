function c = aschar(x)
% ASCHAR  Converte un valore in char array.
%
% Sintassi:
%   c = aschar(x)
%
% Input:
%   x : valore di tipo string, char o altro
%
% Output:
%   c : char array equivalente a x
%
% Descrizione:
%   - Se l'input è una string array (string), la converte con char()
%   - Se è già un char array, lo restituisce invariato
%   - In qualsiasi altro caso, converte prima a string e poi a char
%
% Utilità:
%   Usata per garantire che i valori siano sempre in formato char
%   quando devono essere scritti su file di testo o CSV
%
% Vedi anche: char, string

    if isstring(x)
        % Conversione diretta da string array
        c = char(x);
    elseif ischar(x)
        % Già char array, nessuna modifica
        c = x;
    else
        % Conversione generica: qualsiasi tipo -> string -> char
        c = char(string(x));
    end
end
