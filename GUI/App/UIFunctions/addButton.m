function addButton(app, name, nRow, nCol, callbackFunction)
    try
        button = uibutton(app.GridLayout, ...
                    'Text', name, ...
                    'ButtonPushedFcn', callbackFunction);
    catch
        button = uibutton(app.ButtonGroup, ...
            'Text', name, ...
            'ButtonPushedFcn', callbackFunction);
    end
    
    % Set edit field position in grid layout 
    button.Layout.Row = nRow;
    button.Layout.Column = nCol;
    app.handleButton = [app.handleButton, button];
end

