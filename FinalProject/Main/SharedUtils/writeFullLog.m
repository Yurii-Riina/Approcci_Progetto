function writeFullLog(fig, msg)
% WRITEFULLLOG  Aggiunge un messaggio dettagliato al log esteso (Tab 4) della GUI.
%
% Sintassi:
%   writeFullLog(fig, msg)
%
% Input:
%   fig : handle della finestra principale (UI figure).
%   msg : messaggio da registrare (stringa o char).
%
% Descrizione:
%   Questa funzione scrive un nuovo messaggio nella casella di log estesa
%   (identificata dal tag 'FullLogBox').  
%   Il messaggio è preceduto da un timestamp (HH:mm:ss) per indicare
%   l'orario dell'evento.
%
% Note:
%   - I nuovi messaggi vengono inseriti in cima alla lista.
%   - Se la casella non esiste nella GUI, la funzione termina senza errori.

    % Recupera il componente di log esteso
    box = findobj(fig, 'Tag', 'FullLogBox');
    if isempty(box)
        return; % nessun log presente nella GUI
    end

    % Timestamp corrente (es: "15:04:22")
    ts = char(datetime('now', 'Format', 'HH:mm:ss'));

    % Inserisce il nuovo messaggio in cima alla lista esistente
    box.Value = [{[ts ' – ' char(msg)]}; box.Value];
end
