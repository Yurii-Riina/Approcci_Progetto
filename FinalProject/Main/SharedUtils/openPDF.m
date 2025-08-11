function openPDF(parentfig)
% OPENPDF  Apre il file PDF della relazione del progetto, se disponibile.
%
% Sintassi
%   openPDF(parentfig)
%
% Input
%   parentfig : handle alla finestra (UI figure) che richiama la funzione.
%               Utilizzato per visualizzare eventuali messaggi di errore.
%
% Descrizione
%   Questa funzione cerca la relazione del progetto in una delle seguenti posizioni:
%     1. /Documentation/relazione.pdf
%     2. /Documentation/Problem_1/relazione.pdf
%
%   Se trova un file PDF valido in uno di questi percorsi, lo apre utilizzando
%   l'applicazione predefinita del sistema operativo per i file PDF.
%   Se nessun file viene trovato, mostra un messaggio di avviso all'utente.
%
% Note
%   - Il percorso di base del progetto viene calcolato risalendo di due livelli
%     rispetto alla posizione di questo file.
%   - È possibile aggiungere ulteriori percorsi ai candidati modificando la cella `cand`.
%
% Vedi anche: FULLFILE, ISFILE, UIALERT

    % === Determina la cartella base del progetto ===
    base = fileparts(fileparts(mfilename('fullpath')));

    % === Elenco percorsi candidati per il file PDF ===
    cand = { ...
        fullfile(base, 'Documentation', 'relazione.pdf'), ...
        fullfile(base, 'Documentation', 'Problem_1', 'relazione.pdf') ...
    };

    % === Ricerca e apertura del primo file PDF valido ===
    didOpen = false;
    for k = 1:numel(cand)
        if isfile(cand{k})
            open(cand{k});
            didOpen = true;
            break;
        end
    end

    % === Avviso se nessun file trovato ===
    if ~didOpen
        uialert(parentfig, ...
            'Relazione non trovata in /Documentation.', ...
            'File mancante');
    end
end
