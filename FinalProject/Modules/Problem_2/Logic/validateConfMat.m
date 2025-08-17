function S = validateConfMat(C, labels)
% Controlli robusti sulla matrice di confusione.
    S = struct('ok',false,'msg','', 'info',struct());
    if isempty(C) || ~ismatrix(C) || ~isnumeric(C)
        S.msg = 'Matrice vuota o non numerica.'; return;
    end
    [r,c] = size(C);
    if r~=c
        S.msg = sprintf('La matrice deve essere quadrata (NxN). Trovato %dx%d.', r, c); return;
    end
    if any(isnan(C),'all') || any(isinf(C),'all')
        S.msg = 'La matrice contiene NaN o Inf.'; return;
    end
    if any(C(:) < 0)
        S.msg = 'Valori negativi non ammessi.'; return;
    end
    if isempty(labels), labels = arrayfun(@(k)sprintf('Class %d',k),1:r,'UniformOutput',false); end
    if numel(labels) ~= r
        S.msg = sprintf('labels deve avere %d elementi.', r); return;
    end
    % tutto ok
    S.ok = true;
    S.info.N = r;
    S.info.zeroRows = find(sum(C,2)==0).';
    S.info.total = sum(C,'all');
end
