function closeWindowCallback(childWindows, hObject, eventData)
    msg = sprintf('Close %s window ?', hObject.Name);
    selection = uiconfirm(hObject, msg, 'Close window');
    switch selection
        case 'OK'
            delete(hObject)
            delete(childWindows(:).Figure)
        case 'Cancel'
            return
    end
end