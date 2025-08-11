function clearHistory(fig)
% CLEARHISTORY - Reset completo di cronologia, risultati, feature e stato UI.
%
% Scopo
%   Ripristina il modulo ai valori iniziali:
%     - Pulisce cronologie (Tab 2 + Tab 4)
%     - Azzera tabelle, label, anteprima e log
%     - Reset di appdata interni (stati correnti e ausiliari)
%     - Aggiorna lo stato della sessione
%
% Flusso
%   1) Conferma utente
%   2) Pulizia Tab 2 (anteprima, info, feature, log parziale, cronologia parziale)
%   3) Pulizia Tab 3 (tabella fv e label risultato)
%   4) Pulizia Tab 4 (tabella cronologia completa e log dettagliato)
%   5) Reset AppData (stati e flag interni, incl. doppio click emulato)
%   6) Aggiorna stato sessione e log
%
% Note
%   - Le uitextarea vanno svuotate con {''} (non {}), altrimenti MATLAB
%     può segnalare errore di validazione sul valore assegnato.
%   - Le tabelle possono essere svuotate assegnando {} a .Data.
%   - I campi appdata creati per il doppio‑click (LastRowClick/LastClickTime)
%     vengono ripuliti per coerenza.
%
% Autore: [Tuo Nome]
% Data:   [Data]
% -------------------------------------------------------------------------

%% 1) Conferma utente
    choice = uiconfirm(fig, ...
        'Cancellare cronologia, log e stato della sessione?', ...
        'Conferma', ...
        'Options', {'Sì','No'}, ...
        'DefaultOption', 2, ...
        'CancelOption', 2);

    if ~strcmp(choice, 'Sì')
        setSessionStatus(fig, 'Pulisci cronologia annullato', true, [], 'warning');
        return;
    end

%% 2) TAB 2 — Anteprima, info immagine, risultato, feature, log e cronologia parziale
    % Etichetta info immagine
    imgLbl = findobj(fig, 'Tag', 'ImgInfoLabel');
    if isgraphics(imgLbl), imgLbl.Text = ''; end

    % Etichetta risultato
    resLbl = findobj(fig, 'Tag', 'ResultLabel');
    if isgraphics(resLbl), resLbl.Text = 'Risultato: –'; end

    % Tabella feature
    featTb = findobj(fig, 'Tag', 'FeatureTable');
    if isgraphics(featTb)
        featTb.Data    = {};
        featTb.RowName = {};
    end

    % Log parziale
    logBox = findobj(fig, 'Tag', 'LogBox');
    if isgraphics(logBox), logBox.Value = {''}; end

    % Anteprima immagine
    ax = getappdata(fig, 'PreviewAxes');
    if ~isempty(ax) && isgraphics(ax)
        cla(ax);
        axis(ax, 'off');
    end

    % Cronologia parziale (Tab 2)
    hist2 = findobj(fig, 'Tag', 'HistoryTable');
    if isgraphics(hist2), hist2.Data = {}; end

%% 3) TAB 3 — Vettori di feature
    t3Tbl = getappdata(fig, 'FeatureTableVector');
    if isgraphics(t3Tbl)
        t3Tbl.Data    = {};
        t3Tbl.RowName = {};
    end

    t3Lbl = getappdata(fig, 'ResultLabelVector');
    if isgraphics(t3Lbl), t3Lbl.Text = 'Risultato: –'; end

%% 4) TAB 4 — Cronologia completa + log dettagliato
    histFull = findobj(fig, 'Tag', 'HistoryTableFull');
    if isgraphics(histFull), histFull.Data = {}; end

    fullLog = findobj(fig, 'Tag', 'FullLogBox');
    if isgraphics(fullLog), fullLog.Value = {''}; end

%% 5) AppData / Stato — reset dei dati di sessione e degli stati ausiliari
    % Dati sessione
    setappdata(fig, 'ImageHistoryData', {});
    setappdata(fig, 'CurrentImagePath', '');
    setappdata(fig, 'CurrentImage', []);

    % Stati per emulazione doppio click su HistoryTableFull (se presenti)
    if isappdata(fig, 'LastRowClick'),  rmappdata(fig, 'LastRowClick');  end
    if isappdata(fig, 'LastClickTime'), rmappdata(fig, 'LastClickTime'); end

%% 6) Feedback utente — stato sessione + log
    % Stato sessione: qui ha senso segnare la sessione come "Inattiva"
    % e usare un colore neutro/ok (operazione volontaria riuscita).
    setSessionStatus(fig, 'Cronologia pulita', false, [], 'ok');

    % Log sintetico (Tab 2)
    logMessage(fig, 'Feature e risultato azzerati.');

    % Log dettagliato (Tab 4)
    writeFullLog(fig, 'Cronologia e log della sessione cancellati.');
end