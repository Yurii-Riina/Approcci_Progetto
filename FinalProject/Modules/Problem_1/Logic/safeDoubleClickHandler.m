function safeDoubleClickHandler(src, evt, fig)
    try
        onDoubleClickRow(src, evt, fig);  % tua funzione di gestione
    catch ME
        uialert(fig, sprintf('Errore nel doppio click:\n%s', ME.message), 'Errore');
    end
end