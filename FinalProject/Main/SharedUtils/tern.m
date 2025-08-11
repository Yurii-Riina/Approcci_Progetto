function out = tern(cond, a, b)
% TERN  Operatore ternario in stile MATLAB.
%
% Sintassi:
%   out = tern(cond, a, b)
%
% Input:
%   cond : condizione logica (true/false) o espressione booleana.
%   a    : valore restituito se cond è vera.
%   b    : valore restituito se cond è falsa.
%
% Output:
%   out  : 'a' se cond è true, altrimenti 'b'.
%
% Descrizione:
%   Questa funzione implementa un comportamento simile all'operatore
%   ternario presente in altri linguaggi di programmazione (es. C: cond ? a : b).
%   È utile per scrivere in modo compatto assegnazioni condizionali.
%
% Esempio:
%   risultato = tern(x > 0, 'positivo', 'negativo');
%   % Se x > 0 → 'positivo', altrimenti 'negativo'

    if cond
        out = a;
    else
        out = b;
    end
end
