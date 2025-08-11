function backToMain(currentFig)
% BACKTOMAIN  Chiude il modulo corrente e ritorna alla schermata principale.
%
% Sintassi:
%   backToMain(currentFig)
%
% Input:
%   currentFig : handle alla figura/UI corrente da chiudere
%
% Descrizione:
%   - Chiude la finestra del modulo attualmente aperto
%   - Richiama la funzione principale `createApp` per mostrare la
%     schermata iniziale del progetto
%
% Note:
%   - `createApp` deve trovarsi nel MATLAB path, altrimenti verrà generato un errore.
%   - In futuro, questa funzione può essere estesa per:
%       • Aggiungere transizioni animate
%       • Salvare automaticamente lo stato della sessione
%       • Mostrare conferme prima di abbandonare il modulo
%
% Esempio:
%   backToMain(gcf);   % Chiude la finestra attuale e riapre la home
%
% Vedi anche: createApp, delete

    % --- Chiude la finestra del modulo corrente ---
    delete(currentFig); 

    % --- Avvia la schermata principale ---
    createApp();
end
