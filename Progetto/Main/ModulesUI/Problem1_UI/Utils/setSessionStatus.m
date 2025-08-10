function setSessionStatus(fig, lastOp, isActive, lastExportPath)
    lbl = findobj(fig,'Tag','SessionStatusLabel');
    if isempty(lbl), return; end
    if nargin<4 || isempty(lastExportPath), lastExportPath = '--'; end
    stateTxt = tern(isActive,'Attiva','Inattiva');
    lbl.Text = sprintf('- Ultima operazione: %s\n- Stato sessione: %s\n- Ultimo export: %s', ...
                       char(lastOp), stateTxt, char(lastExportPath));
    if isActive
        lbl.FontColor = [0 0.55 0];   % verde
    else
        lbl.FontColor = [0.6 0 0];    % rosso
    end
end