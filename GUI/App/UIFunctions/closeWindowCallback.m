function closeWindowCallback(hObject, eventData)
    msg = sprintf('Close %s window ?', hObject.Name);
    selection = uiconfirm(hObject, msg, 'Close window');
    switch selection
        case 'OK'
            delete(eventData.Source)
%             delete(hObject)
%             if ~isempty(subWindows)
%                 for i_w = 0:numel(subWindows)-1
%                     w = subWindows(end-i_w); % Going backward
%                     close(w.Figure)
%                     delete(w)
%                 end
%             end

%             for i_w = 0:numel(subWindows)-1
%                 w = subWindows(end-i_w); % Going backward
%                 close(w.Figure)
%                 delete(w)
%             end
        case 'Cancel'
            return
    end
end