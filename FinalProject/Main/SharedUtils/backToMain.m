function backToMain(currentFig)
% BACKTOMAIN  Chiude il modulo corrente e ritorna alla schermata principale.
%
% Sintassi:
%   backToMain(currentFig)
%
% Descrizione:
%   - Usa launchModule per garantire coerenza con il caricamento dei moduli.
%   - Mostra splash screen anche nel ritorno alla home.
%
% Vedi anche: launchModule, createApp

    try
        launchModule(currentFig, 'home', @createApp, struct('Title','Home'));
    catch ME
        % Fallback di sicurezza: se launchModule fallisce, apri direttamente
        delete(currentFig);
        createApp();
        warning('%s - backToMain: fallback attivato: %s', ME.identifier, ME.message);
    end
end
