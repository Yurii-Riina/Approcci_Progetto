% ==============================================
% Calcola la dimensione del file specificato e la restituisce
% in kilobyte (KB). Utile per visualizzare il peso dei file
% nella tabella di cronologia.
% ==============================================

function kb = getFileSize(filepath)
    % Recupera informazioni sul file
    info = dir(filepath);

    % Calcola la dimensione in kilobyte
    kb = info.bytes / 1024;
end