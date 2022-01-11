function closeWindowCallback(src, event)
    msg = 'Close app ?';
    selection = uiconfirm(src, msg, 'Close app');
    switch selection
        case 'OK'
            delete(src)
        case 'Cancel'
            return
    end
end