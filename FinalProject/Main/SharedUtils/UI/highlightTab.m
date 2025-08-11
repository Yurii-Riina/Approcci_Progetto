function highlightTab(iconLabels, selectedTitle)
% HIGHLIGHTTAB  Evidenzia l'icona della tab attualmente selezionata nel menu verticale.
%
% Sintassi
%   highlightTab(iconLabels, selectedTitle)
%
% Input
%   iconLabels    : array di handle ai pulsanti/etichette del menu verticale (uno per tab)
%   selectedTitle : stringa del titolo della tab attualmente selezionata
%
% Descrizione
%   Confronta il titolo della tab attiva con l'elenco di icone predefinite
%   e modifica il colore e il peso del font per evidenziare quella corrente.
%   Le altre icone tornano allo stato "normale".
%
% Note
%   - Il match avviene tramite `contains`, quindi funziona anche se il titolo
%     contiene testo aggiuntivo oltre all’icona (es. "🏠 Home").
%   - Richiede che `iconLabels` e `icone` abbiano lo stesso ordine delle tab.

    % --- Icone in ordine di tab ---
    icone = {'🏠','👥','📄','🧩'};
    
    % --- Aggiorna stile di ciascun pulsante ---
    for i = 1:numel(icone)
        if contains(selectedTitle, icone{i})
            % Tab attiva → blu e grassetto
            iconLabels(i).FontColor  = [0.10 0.35 0.80];
            iconLabels(i).FontWeight = 'bold';
        else
            % Tab inattiva → grigio e normale
            iconLabels(i).FontColor  = [0.4 0.4 0.4];
            iconLabels(i).FontWeight = 'normal';
        end
    end
end
