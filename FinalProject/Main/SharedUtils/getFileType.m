function type = getFileType(filename)
% GETFILETYPE  Restituisce l'estensione di un file in maiuscolo.
%
% Sintassi:
%   type = getFileType(filename)
%
% Input:
%   filename : stringa o char contenente il nome o il percorso del file.
%
% Output:
%   type     : estensione del file (senza punto) in maiuscolo.
%              Se il file non ha estensione, restituisce '' (stringa vuota).
%
% Descrizione:
%   Questa funzione estrae l'estensione da un nome file o path completo,
%   rimuove il punto iniziale e converte il risultato in lettere maiuscole.
%   È utile per classificare e visualizzare il tipo di file nella cronologia.
%
% Note:
%   - Funziona anche con nomi file senza estensione (ritorna stringa vuota).
%   - Non verifica l’esistenza fisica del file.
%
% Esempio:
%   getFileType('immagine.png')   → "PNG"
%   getFileType('C:\path\file.mat') → "MAT"

    % --- Estrae l'estensione dal nome file ---
    [~, ~, ext] = fileparts(filename);

    % --- Rimuove il punto e converte in maiuscolo ---
    type = upper(strrep(ext, '.', ''));
end
