function outPanel = styleCardPanel(parent, title, position)
% STYLECARDPANEL  Crea un pannello (card) con stile coerente per la GUI.
%
% Sintassi
%   outPanel = styleCardPanel(parent, title, position)
%
% Input
%   parent   : handle al container padre (figura, tab o pannello) in cui inserire la card.
%   title    : stringa con il titolo da mostrare nella barra superiore del pannello.
%   position : vettore [x y w h] in pixel con la posizione e dimensioni del pannello.
%
% Output
%   outPanel : handle del pannello creato, utile per aggiungere elementi interni.
%
% Descrizione
%   Crea un pannello con:
%     - Titolo in grassetto
%     - Font coerente con il resto della GUI ('Segoe UI', 11 pt)
%     - Sfondo grigio chiaro
%     - Bordo visibile ('line')
%
% Note
%   - Questa funzione serve a mantenere coerenza visiva tra i moduli.
%   - È pensata per essere usata in tutte le schermate che richiedono
%     contenitori con titolo (es. schede di descrizione, box di opzioni).
%
% Vedi anche: UIPANEL, UIFIGURE, CREATEAPP

    % Creazione pannello stilizzato
    outPanel = uipanel(parent, ...
        'Title', title, ...
        'FontWeight', 'bold', ...
        'FontName', 'Segoe UI', ...
        'FontSize', 11, ...
        'Position', position, ...
        'BackgroundColor', [0.97 0.97 0.97], ... % grigio molto chiaro
        'BorderType', 'line');
end
