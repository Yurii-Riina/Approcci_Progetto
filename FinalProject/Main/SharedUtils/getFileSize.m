function kb = getFileSize(filepath)
% GETFILESIZE  Restituisce la dimensione di un file in kilobyte (KB).
%
% Sintassi:
%   kb = getFileSize(filepath)
%
% Input:
%   filepath : stringa o char contenente il percorso del file.
%
% Output:
%   kb       : dimensione del file in KB (double).
%              Se il file non esiste o non è leggibile, restituisce NaN.
%
% Descrizione:
%   Questa funzione utilizza `dir` per recuperare le informazioni sul file
%   specificato e calcolare la dimensione in kilobyte. È utile per mostrare
%   il peso di un file nella tabella di cronologia della GUI.
%
% Note:
%   - Il valore restituito è in kilobyte (1 KB = 1024 byte).
%   - In caso di errore (file non trovato o permessi negati), viene restituito NaN.
%
% Esempio:
%   size_kb = getFileSize('immagine.png');

    % --- Controllo esistenza file ---
    if ~isfile(filepath)
        kb = NaN;
        return;
    end

    % --- Recupera informazioni sul file ---
    info = dir(filepath);

    % --- Calcola dimensione in KB ---
    kb = info.bytes / 1024;
end
