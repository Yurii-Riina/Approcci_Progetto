function toggleFAQEntry(button, answerBox, ~)
% TOGGLEFAQENTRY  Mostra o nasconde la risposta associata a una FAQ.
%
% Sintassi:
%   toggleFAQEntry(button, answerBox, ~)
%
% Input:
%   button     : handle del pulsante associato alla domanda (FAQ).
%   answerBox  : handle del componente UI che contiene la risposta.
%   ~          : argomento ignorato (placeholder per callback standard MATLAB).
%
% Descrizione:
%   Questa funzione viene usata come callback per pulsanti "FAQ".
%   Quando l'utente clicca sul pulsante:
%       - se la risposta è visibile → viene nascosta e il pulsante
%         mostra l'icona "➕".
%       - se la risposta è nascosta → viene mostrata e il pulsante
%         mostra l'icona "➖".
%
% Note:
%   Serve per rendere le FAQ espandibili/comprimibili, migliorando
%   la leggibilità e riducendo l'ingombro nella UI.

    % Controlla lo stato attuale di visibilità della risposta
    visible = strcmp(answerBox.Visible, 'on');

    if visible
        % Nascondi risposta
        answerBox.Visible = 'off';
        % Cambia simbolo sul pulsante (da meno a più)
        button.Text = strrep(button.Text, '➖', '➕');
    else
        % Mostra risposta
        answerBox.Visible = 'on';
        % Cambia simbolo sul pulsante (da più a meno)
        button.Text = strrep(button.Text, '➕', '➖');
    end
end
