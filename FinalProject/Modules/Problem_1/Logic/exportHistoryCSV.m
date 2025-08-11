function exportHistoryCSV(fig)
    tbl = findobj(fig,'Tag','HistoryTableFull');
    if isempty(tbl) || isempty(tbl.Data)
        uialert(fig,'Nessun dato in cronologia da esportare.','Info'); return;
    end
    [f,p] = uiputfile('*.csv','Esporta cronologia come CSV','sessione.csv');
    if isequal(f,0), return; end
    outFile = fullfile(p,f);

    fid = fopen(outFile,'w','n','UTF-8');
    if fid<=0, uialert(fig,'Impossibile creare il CSV.','Errore'); return; end
    fprintf(fid,'Nome,Data,Tipo,Dim_KB,Tag,Classe\n');
    D = tbl.Data;
    for i=1:size(D,1)
        nome   = aschar(D{i,1});
        data   = aschar(D{i,2});
        tipo   = aschar(D{i,3});
        dimKB  = D{i,4}; if ischar(dimKB) || isstring(dimKB), dimKB = str2double(dimKB); end
        if isempty(dimKB) || isnan(dimKB), dimKB = 0; end
        tag    = aschar(D{i,5});
        classe = aschar(D{i,6});
        fprintf(fid,'"%s","%s","%s",%.4f,"%s","%s"\n',nome,data,tipo,dimKB,tag,classe);
    end
    fclose(fid);

    writeFullLog(fig, sprintf('Export CSV (tab4): %s', outFile));
    setSessionStatus(fig,'Export CSV (tab4)',true,outFile);
end