function assertDialogBox(app, cond, message, title, icon)
    % icon = 'error', 'warning', 'info'
    if ~cond
        for msg = message
            uialert(app.Figure, msg, title, 'Icon', icon, 'CloseFcn', @alertCallback);
        end
        uiwait(app.Figure);
    end

    function alertCallback(src, event)
        uiresume(app.Figure)
    end
end