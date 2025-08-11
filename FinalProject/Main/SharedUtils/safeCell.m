function v = safeCell(S, field)
% SAFECELL  Restituisce il contenuto sicuro di un campo di una struttura.
%
% Sintassi:
%   v = safeCell(S, field)
%
% Input:
%   S     : struttura dalla quale leggere il campo.
%   field : nome del campo (stringa o char) da estrarre.
%
% Output:
%   v     : valore del campo se esiste e non è vuoto;
%           altrimenti viene restituito un valore predefinito in base al campo.
%
% Descrizione:
%   Questa funzione viene usata per leggere campi di una struttura in
%   modo sicuro, evitando errori nel caso il campo non esista o sia vuoto.
%   - Se il campo esiste e contiene dati, viene restituito il valore.
%   - Se il campo non esiste o è vuoto:
%       → Se il campo è 'FullLog', restituisce `{'')}` per evitare errori
%         con componenti `uitextarea`.
%       → In tutti gli altri casi, restituisce `{}` (vuoto generico).
%
% Esempio:
%   logVal = safeCell(S, 'FullLog');  % ritorna almeno {''}
%   historyVal = safeCell(S, 'HistoryTable'); % ritorna {} se vuoto

    % Verifica che il campo esista e non sia vuoto
    if isfield(S, field) && ~isempty(S.(field))
        v = S.(field); 
    else
        % Valore predefinito in base al nome del campo
        if strcmp(field, 'FullLog')
            v = {''};  % Evita errore: uitextarea.Value non può essere {}
        else
            v = {};    % Vuoto generico
        end
    end
end
