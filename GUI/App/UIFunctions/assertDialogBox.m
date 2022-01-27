function assertDialogBox(app, cond, message, title, icon)
    % icon = 'error', 'warning', 'info'
    if ~cond
        for msg = message
            uialert(app.Figure, message, title, 'Icon', icon);
        end
    end
end