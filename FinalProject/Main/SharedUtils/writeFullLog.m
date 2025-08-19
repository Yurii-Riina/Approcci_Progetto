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

    if nargin < 2 || isempty(msg) || ~ishandle(fig), return; end

    % 1) Priorità dei tag (puoi cambiare l'ordine se vuoi)
    tagOrder = {'FullLogBoxP2','FullLogBoxP1','FullLogBoxP3','FullLogBoxP4','FullLogBoxP5','FullLogBox'};

    % 2) Trova il primo box valido
    box = [];
    for k = 1:numel(tagOrder)
        h = findobj(fig,'Tag',tagOrder{k});
        if ~isempty(h) && isgraphics(h)
            box = h; break;
        end
    end
    % 2b) Fallback molto generico: qualunque tag che inizi con "FullLogBox"
    if isempty(box) || ~isgraphics(box)
        try
            h = findobj(fig,'-regexp','Tag','^FullLogBox');
            if ~isempty(h) && isgraphics(h(1)), box = h(1); end
        catch
        end
    end
    if isempty(box) || ~isgraphics(box), return; end

    % 3) Timestamp + sanificazione messaggio
    ts   = char(datetime('now','Format','HH:mm:ss'));
    sMsg = char(string(msg));
    sMsg = regexprep(sMsg,'\s+',' ');
    sMsg = regexprep(sMsg,'^\[[^\]]+\]\s*','');  % rimuove eventuali [TAG]
    line = sprintf('%s — %s', ts, sMsg);

    % 4) Append in fondo (ordine cronologico crescente)
    old = box.Value;
    if ischar(old) || isstring(old), old = cellstr(old); end
    if isempty(old), old = {}; end
    box.Value = [old(:); {line}];

    drawnow limitrate;
end
