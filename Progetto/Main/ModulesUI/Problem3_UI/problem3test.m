function problem3test(parentTab)
    uilabel(parentTab, 'Text', 'Lavori in corso...', 'FontSize',20, ...
           'Position',[200 300 300 50]);
    uibutton(parentTab, 'Text', '◀ Torna a Progetti', 'Position',[10 550 120 30], ...
             'ButtonPushedFcn', @(~,~) parentTab.Parent.SelectedTab = parentTab.Parent.Children(4));
    addFooter(parentTab);
end