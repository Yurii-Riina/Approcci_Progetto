function simulatePress(btn)
% SIMULATEPRESS  Simula la pressione di un pulsante con un breve cambio di colore.
%
% Sintassi
%   simulatePress(btn)
%
% Input
%   btn : handle del pulsante (uibutton) a cui applicare l'effetto visivo.
%
% Descrizione
%   Cambia temporaneamente il colore di sfondo del pulsante per ~150 ms,
%   simulando la pressione da parte dell'utente. Utile per dare feedback
%   visivo quando il pulsante non ha una callback logica attiva (placeholder).
%
% Note
%   - Non esegue alcuna logica associata, solo l’effetto visivo.
%   - Se il pulsante non è valido o non ha la proprietà 'BackgroundColor',
%     la funzione termina silenziosamente.

    % Verifica che l'handle sia valido
    if ~ishandle(btn) || ~isprop(btn, 'BackgroundColor')
        return; % niente da fare
    end

    % Colore originale e colore "pressed"
    origColor = btn.BackgroundColor;
    pressColor = [0.80 0.87 1.00]; % azzurrino tenue

    try
        % Applica colore "premuto"
        btn.BackgroundColor = pressColor;
        drawnow;
        pause(0.15);

        % Ripristina colore originale
        if ishandle(btn)
            btn.BackgroundColor = origColor;
            drawnow;
        end
    catch
        % In caso di problemi grafici, ignora e ripristina
        if ishandle(btn)
            btn.BackgroundColor = origColor;
        end
    end
end
