function addEditField(app, varargin)
% ADDEDITFIELD add uieditfield componnent to app window. 
% varargin = {'Parent', app.GridLayout, 'Style', 'text', 'Value', '',
% 'Placeholder', '', 'ValueDisplayFormat', '', 'LayoutPosition',
% struct('nRow', [], 'nCol', []), 'ValueChangedFcn', {@}}
    %% Check varargin format 
    if  all(size(varargin) == [1, 1])
        varargin = varargin{:};
    end

    %% Get arguments
    parent = getVararginValue(varargin, 'Parent', []);
    style = getVararginValue(varargin, 'Style', 'text');
    value = getVararginValue(varargin, 'Value', '');
    placeholder = getVararginValue(varargin, 'Placeholder', 1);
    valueChangedFcn = getVararginValue(varargin, 'ValueChangedFcn', '');

    valueDisplayFormat = getVararginValue(varargin, 'ValueDisplayFormat', '%11.4g');
    layoutPosition = getVararginValue(varargin, 'LayoutPosition', struct('nRow', [], 'nCol', []));
    editable = getVararginValue(varargin, 'Editable', 'on');
    enable = getVararginValue(varargin, 'Enable', 'on');

    %% Create component
    editField = uieditfield(parent, style, ...
                'Value', value, ...
                'Editable', editable, ...
                'Enable', enable);

    if  ~isempty(valueChangedFcn)
        set(editField, 'ValueChangedFcn', valueChangedFcn)
    end
    
    if strcmp(style, 'numeric')
        set(editField, 'ValueDisplayFormat', valueDisplayFormat)
    else
        set(editField, 'Placeholder', placeholder)
    end

    if ~(isempty(layoutPosition.nRow) || isempty(layoutPosition.nCol))
        % Set edit field position in grid layout 
        editField.Layout.Row = layoutPosition.nRow;
        editField.Layout.Column = layoutPosition.nCol;
    end
    app.handleEditField = [app.handleEditField, editField];
end

