function setSessionStatus(fig, lastOp, isActive, lastExportPath, varargin)
% setSessionStatus(fig, lastOp, isActive, lastExportPath, [statusType])
% statusType (opzionale): 'ok' | 'warning' | 'error' | 'neutral'
% - Se omesso, il colore viene scelto in base a isActive (verde/rosso).
%
% Esempi:
%   setSessionStatus(fig,'Classificazione immagine',true,[])
%   setSessionStatus(fig,'Export CSV',true,outFile,'ok')
%   setSessionStatus(fig,'Nessuna nuova immagine',true,[],'warning')

    % Trova la label di stato
    lbl = findobj(fig,'Tag','SessionStatusLabel');
    if isempty(lbl) || ~isgraphics(lbl)
        return;
    end

    % Parametri opzionali
    if nargin < 4 || isempty(lastExportPath)
        lastExportPath = '--';
    end
    statusType = 'neutral';
    if nargin >= 5 && ~isempty(varargin{1})
        statusType = lower(string(varargin{1}));
    end

    % Timestamp leggibile (usa datetime, più moderno di datestr)
    ts = char(datetime('now','Format','dd-MM-yyyy HH:mm:ss'));

    % Testo stato
    stateTxt = tern(isActive,'Attiva','Inattiva');
    lbl.Text = sprintf(['- Ultima operazione: %s\n',...
                        '- Stato sessione: %s\n',...
                        '- Ultimo export: %s\n',...
                        '- Aggiornato: %s'], ...
                        char(lastOp), stateTxt, char(lastExportPath), ts);

    % Colore in base allo status (fallback su isActive)
    switch statusType
        case {'ok','success'}
            color = [0.00 0.55 0.00];   % verde
        case {'warning','warn'}
            color = [0.85 0.55 0.00];   % arancione
        case {'error','err'}
            color = [0.80 0.00 0.00];   % rosso
        otherwise  % 'neutral' o non specificato
            color = tern(isActive, [0.00 0.55 0.00], [0.60 0.00 0.00]);
    end
    lbl.FontColor = color;
end