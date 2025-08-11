function logMessage(fig, msg)
% LOGMESSAGE  Aggiunge un messaggio di log (con timestamp) alla GUI.
%
% Sintassi:
%   logMessage(fig, msg)
%
% Input:
%   fig : handle della figura principale della GUI.
%   msg : stringa o char contenente il messaggio da registrare.
%
% Output:
%   Nessuno (aggiorna direttamente la text area di log nella GUI).
%
% Descrizione:
%   Questa funzione cerca la text area con tag 'LogBox' all’interno
%   della GUI, crea un messaggio preceduto da un timestamp e lo
%   aggiunge in cima alla lista dei messaggi esistenti.
%
% Note:
%   - Il formato orario è HH:mm:ss (24h).
%   - Se il log box non esiste o non è valido, la funzione non fa nulla.
%   - I messaggi più recenti vengono mostrati in cima alla lista.
%
% Esempio:
%   logMessage(fig, 'Caricamento completato');
%   % Output visivo nella GUI:
%   % "15:04:22 – Caricamento completato"

    % --- Recupera l'area di log dalla GUI ---
    logBox = findobj(fig, 'Tag', 'LogBox');

    % Verifica esistenza e validità dell'oggetto grafico
    if isempty(logBox) || ~isgraphics(logBox)
        warning('logMessage:LogBoxNotFound', ...
                'LogBox non trovato nella GUI. Messaggio non registrato.');
        return;
    end

    % --- Crea il timestamp (es: "15:04:22") ---
    timestamp = char(datetime('now', 'Format', 'HH:mm:ss'));

    % --- Inserisce il nuovo messaggio in cima ---
    % Se Value è vuoto, inizializza come cell array
    if isempty(logBox.Value)
        logBox.Value = {[timestamp ' – ' msg]};
    else
        logBox.Value = [{[timestamp ' – ' msg]}; logBox.Value];
    end
end
