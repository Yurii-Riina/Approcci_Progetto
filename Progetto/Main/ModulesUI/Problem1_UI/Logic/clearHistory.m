% ==============================================
% Reset completo della cronologia caricata, risultati e feature.
% Svuota tabella, azzera label e anteprima immagine. Aggiorna log.
% ==============================================

function clearHistory(fig)
    set(findobj(fig, 'Tag', 'ImgInfoLabel'), 'Text', '');
    set(findobj(fig, 'Tag', 'ResultLabel'), 'Text', 'Risultato: –');
    set(findobj(fig, 'Tag', 'FeatureTable'), 'Data', {});
    set(findobj(fig, 'Tag', 'LogBox'), 'Value', {''});
    cla(getappdata(fig, 'PreviewAxes'));
    logMessage(fig, 'Feature e risultato azzerati.');
end