function launchProblem1(prevFig)
% LAUNCHPROBLEM1  Chiude la schermata principale e avvia il modulo "Problema 1".
%
% Sintassi
%   launchProblem1(prevFig)
%
% Input
%   prevFig : handle alla finestra (UI figure) attualmente aperta, di solito la
%             schermata principale dell'applicazione creata da createApp().
%
% Descrizione
%   Questa funzione:
%     1. Chiude la finestra principale dell'applicazione.
%     2. Avvia la GUI dedicata al "Problema 1 – Riconoscimento gesti statici"
%        richiamando la funzione `staticGestureRecognitionUI`.
%
% Note
%   - La chiusura della finestra precedente evita di avere più finestre aperte
%     contemporaneamente e riduce il consumo di risorse.
%   - La funzione `staticGestureRecognitionUI` deve trovarsi nel path del progetto.
%
% Vedi anche: CREATEAPP, STATICGESTURERECOGNITIONUI

    % Chiude la finestra principale dell'app
    delete(prevFig);

    % Avvia il modulo del Problema 1
    staticGestureRecognitionUI();
end
