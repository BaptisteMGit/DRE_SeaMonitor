function addEditField(app, val, nRow, nCol, placeHolder, style, varargin)
    editField = uieditfield(app.GridLayout, style, ...
                'Value', val);
    if isempty(val) && ~isempty(placeHolder)
        editField.Placeholder = placeHolder;
    end
    if length(varargin) >= 1
        editField.ValueChangedFcn = varargin{1};
    end
    % Set edit field position in grid layout 
    editField.Layout.Row = nRow;
    editField.Layout.Column = nCol;
    app.handleEditField = [app.handleEditField, editField];
end

