function addFooter(parent, style)
% ADDFOOTER  Aggiunge un footer standard a una GUI del progetto.
%
% Sintassi:
%   addFooter(parent)
%   addFooter(parent, style)
%
% Input:
%   parent : handle a figura o pannello
%   style  : (opzionale) 'default' | 'createApp'
%
% Descrizione:
%   Aggiunge il footer con copyright e logo UNIVPM.
%   Cambia leggermente aspetto in base allo stile selezionato.

    if nargin < 2
        style = 'default'; % usato in staticGesture
    end

    % --- Etichetta copyright ---
    if strcmpi(style, 'createApp')
        % Stile usato in createApp
        uilabel(parent, ...
            'Text', sprintf(['\n© 2025 Yurii Riina, Nicolò Gioacchini, Thomas Marinucci — Tutti i diritti riservati.\n', ...
                             'Questo software è protetto da copyright.']), ...
            'FontSize', 10, 'FontName', 'Segoe UI', ...
            'HorizontalAlignment', 'center', ...
            'Position', [100, 10, 700, 35], ...
            'FontColor', [0.5 0.5 0.5], ...
            'BackgroundColor', [0.96 0.96 0.96]);
    else
        % Stile usato in staticGesture e altri moduli
        uilabel(parent, ...
            'Text', sprintf(['\n© 2025 Yurii Riina, Nicol\xf2 Gioacchini, Thomas Marinucci — Tutti i diritti riservati.\n', ...
                             'Questo software è protetto da copyright.']), ...
            'FontSize', 10, ...
            'FontName', 'Segoe UI', ...
            'HorizontalAlignment', 'center', ...
            'Position', [100, 10, 700, 35], ...
            'FontColor', [0.5 0.5 0.5], ...
            'BackgroundColor', [0.96 0.96 0.96]);
    end

    % --- Logo UNIVPM ---
    logoPath = which('logo_UNIVPM.png');
    if isempty(logoPath)
        % Se non trovato, prova a cercarlo nelle Assets del progetto
        here = mfilename('fullpath');
        root = fileparts(fileparts(here));
        candidates = { ...
            fullfile(root,'Main','Assets','logo_UNIVPM.png'), ...
            fullfile(root,'Assets','logo_UNIVPM.png'), ...
            fullfile(root,'Modules','Problem_1','Assets','logo_UNIVPM.png')};
        for k = 1:numel(candidates)
            if exist(candidates{k},'file')
                logoPath = candidates{k};
                break;
            end
        end
    end

    if ~isempty(logoPath)
        uiimage(parent, 'ImageSource', logoPath, ...
            'Position', [110 10 80 40], ...
            'ScaleMethod', 'fit');
    else
        warning('addFooter:LogoNotFound', ...
            'Logo UNIVPM non trovato.');
    end
end
