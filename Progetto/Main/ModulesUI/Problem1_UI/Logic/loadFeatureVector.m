% ==============================================
% Carica/classifica un vettore di feature.
% Uso:
%   loadFeatureVector(fig)                          % come prima: chiede scelta, scrive su Tab2
%   loadFeatureVector(fig,'mode','manual')          % input manuale, scrive su Tab2
%   loadFeatureVector(fig,'mode','mat')             % da .mat, scrive su Tab2
%   loadFeatureVector(fig,'mode','existing')        % usa dati già in tabella di Tab2
%   loadFeatureVector(fig,'mode','manual','target','tab3')   % scrive su Tab3
%   loadFeatureVector(fig,'mode','mat','target','tab3')      % scrive su Tab3
%   loadFeatureVector(fig,'mode','existing','target','tab3') % rilegge Tab3
% ==============================================
function loadFeatureVector(fig, varargin)
    % ---- Parse opzioni ----
    mode   = 'ask';     % 'ask' | 'manual' | 'mat' | 'existing'
    target = 'tab2';    % 'tab2' | 'tab3'
    for k = 1:2:numel(varargin)
        key = lower(string(varargin{k}));
        val = varargin{k+1};
        switch key
            case 'mode',   mode   = lower(string(val));
            case 'target', target = lower(string(val));
        end
    end

    % ---- Selettore controlli in base al target ----
    switch target
        case 'tab3'
            tagTbl = 'FeatureTableVector';
            tagLbl = 'ResultLabelVector';
        otherwise
            tagTbl = 'FeatureTable';
            tagLbl = 'ResultLabel';
    end
    tbl = findobj(fig,'Tag',tagTbl);
    lbl = findobj(fig,'Tag',tagLbl);
    if isempty(tbl) || isempty(lbl)
        uialert(fig,'Controlli destinazione non trovati.','Errore'); return;
    end

    % ---- Acquisizione fv in base al mode ----
    fv = [];
    switch mode
        case 'manual'
            answer = inputdlg('Inserisci il feature vector [es: 0.12 1.04 0]:', ...
                              'Input manuale', 1, {''});
            if isempty(answer), return; end
            fv = str2num(answer{1}); %#ok<ST2NM>
            if isempty(fv) || ~isnumeric(fv)
                uialert(fig,'Input non valido.','Errore'); return;
            end
            fv = fv(:);

        case 'mat'
            try
                [file, path] = uigetfile('*.mat','Seleziona file .mat con vettore fv');
                if isequal(file,0), return; end
                S = load(fullfile(path,file));
                fn = fieldnames(S);
                for i=1:numel(fn)
                    val = S.(fn{i});
                    if isnumeric(val) && isvector(val)
                        fv = val(:); break;
                    end
                end
                if isempty(fv)
                    uialert(fig,'Il file non contiene alcun vettore numerico.','Errore'); return;
                end
            catch ME
                uialert(fig,['Errore durante il caricamento: ' ME.message],'Errore'); return;
            end

        case 'existing'
            D = tbl.Data;
            if isempty(D)
                uialert(fig,'Nessun dato in tabella.','Info'); return;
            end
            if iscell(D), D = cell2mat(D); end
            fv = D(:);

        otherwise % 'ask'
            choice = uiconfirm(fig,'Come vuoi inserire il feature vector?', 'Input feature', ...
                'Options', {'Carica da file .mat','Inserisci manualmente','Annulla'}, ...
                'DefaultOption',1,'CancelOption',3);
            if strcmp(choice,'Annulla'), return; end
            if strcmp(choice,'Carica da file .mat')
                loadFeatureVector(fig,'mode','mat','target',target); return;
            else
                loadFeatureVector(fig,'mode','manual','target',target); return;
            end
    end

    % ---- Classificazione ----
    gesture = classifyGestureFromVector(fv);

    % ---- Aggiorna UI di destinazione ----
    tbl.Data       = fv;
    tbl.ColumnName = {'Valore'};
    tbl.RowName    = buildFeatureNames(numel(fv));
    lbl.Text       = ['Risultato: ' char(gesture)];

    % → aggiorna Tab 4
    addHistoryRowTab4(fig, sprintf('fv(%d)', numel(fv)), 'FV', '', '', gesture);
    writeFullLog(fig, sprintf('Feature vector (%s) → %s', char(mode), char(gesture)));
    setSessionStatus(fig, 'Classificazione vettore', true, []);

    % ---- Log (se disponibile) ----
    if exist('logMessage','file')==2
        src = struct('manual','manuale','mat','MAT','existing','tabella');
        logMessage(fig, sprintf('Feature vector (%s) → %s', ...
            src.(char(mode)), char(gesture)));
    end
end

function names = buildFeatureNames(n)
    base = ["Compattezza","Protrusion ratio"];  % qui metti i nomi *reali* che vuoi
    if n <= numel(base)
        names = base(1:n);
    else
        names = [base, "feat_" + string(1:(n-numel(base)))];
    end
    names = cellstr(names);
end
