% ==============================================
% Aggiunge una riga di log (con timestamp) alla text area
% della GUI con tag 'LogBox'. Viene usato per dare feedback
% all'utente su azioni completate, errori, caricamenti ecc.
% ==============================================

function logMessage(fig, msg)
    % Recupera l'area di log dalla GUI tramite il tag
    logBox = findobj(fig, 'Tag', 'LogBox');

    % Crea timestamp (es: "15:04:22")
    timestamp = char(datetime('now', 'Format', 'HH:mm:ss'));

    % Inserisce il nuovo messaggio in cima
    logBox.Value = [{[timestamp ' – ' msg]}; logBox.Value];
end
