% ==============================================
% Chiude la UI corrente del modulo e ritorna alla schermata principale del progetto.
% Al momento richiama direttamente la funzione createApp, ma in futuro potrebbe
% essere adattata per un comportamento più fluido o animato.
% ==============================================

function backToMain(currentFig)
    % Chiude la finestra attuale
    delete(currentFig); 

    % Richiama l'app principale (createApp deve trovarsi nel path)
    createApp();         
end
