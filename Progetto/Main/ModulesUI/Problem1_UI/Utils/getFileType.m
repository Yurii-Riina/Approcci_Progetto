% ==============================================
% Estrae e restituisce l'estensione del file in maiuscolo
% (es. "JPG", "PNG", "MAT"). Utile per classificare e
% mostrare il tipo di file caricato nella cronologia.
% ==============================================

function type = getFileType(filename)
    % Estrae l'estensione dal nome file
    [~, ~, ext] = fileparts(filename);

    % Rimuove il punto e converte in maiuscolo
    type = upper(strrep(ext, '.', ''));
end
