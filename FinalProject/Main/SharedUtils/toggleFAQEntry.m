function toggleFAQEntry(button, answerBox, ~)
    visible = strcmp(answerBox.Visible, 'on');
    if visible
        answerBox.Visible = 'off';
        button.Text = strrep(button.Text, '➖', '➕');
    else
        answerBox.Visible = 'on';
        button.Text = strrep(button.Text, '➕', '➖');
    end
end
