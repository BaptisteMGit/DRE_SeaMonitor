function addButton(app, varargin)
% ADDBUTTON add uibutton componnent to app window. 
% varargin = {'Parent', app.GridLayout, 'Name', '', 'ButtonPushedFcn', @,
% 'LayoutPosition',  struct('nRow', [], 'nCol', [])}
    %% Check varargin format 
    if  all(size(varargin) == [1, 1])
        varargin = varargin{:};
    end

    %% Get arguments
    parent = getVararginValue(varargin, 'Parent', []);
    name = getVararginValue(varargin, 'Name', 'Button');
    buttonPushedFcn = getVararginValue(varargin, 'ButtonPushedFcn', '');
    layoutPosition = getVararginValue(varargin, 'LayoutPosition', struct('nRow', [], 'nCol', []));
    enable = getVararginValue(varargin, 'Enable', 'on');

    %% Create component 
    button = uibutton(parent, ...
            'Text', name, ...
            'ButtonPushedFcn', buttonPushedFcn, ...
            'Enable', enable);
    
    if ~(isempty(layoutPosition.nRow) || isempty(layoutPosition.nCol))
        % Set button position in grid layout 
        button.Layout.Row = layoutPosition.nRow;
        button.Layout.Column = layoutPosition.nCol;
    end
    app.handleButton = [app.handleButton, button];
end

