function addDropDown(app, items, val, nRow, nCol, callbackFunction)
    dropDown = uidropdown(app.GridLayout, ...
                'Items', items, ...
                'Value', val, ...
                'ValueChangedFcn', callbackFunction);
    % Set dropdown position in grid layout 
    dropDown.Layout.Row = nRow;
    dropDown.Layout.Column = nCol;
    app.handleDropDown = [app.handleDropDown, dropDown];
end