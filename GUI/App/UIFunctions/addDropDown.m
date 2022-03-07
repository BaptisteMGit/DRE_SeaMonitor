function addDropDown(app, varargin)
% ADDDROPDOWN add uidropdown componnent to app window. 
% varargin = {'Parent', app.GridLayout, 'Items', {}, 'Value', '',
% 'ValueChangedFcn', @, 'LayoutPosition',  struct('nRow', [], 'nCol', [])}
    %% Check varargin format 
    if  all(size(varargin) == [1, 1])
        varargin = varargin{:};
    end

    %% Get arguments
    parent = getVararginValue(varargin, 'Parent', []);
    items = getVararginValue(varargin, 'Items', {});
    value = getVararginValue(varargin, 'Value', '');
    valueChangedFcn = getVararginValue(varargin, 'ValueChangedFcn', []);
    layoutPosition = getVararginValue(varargin, 'LayoutPosition', struct('nRow', [], 'nCol', []));
    enable = getVararginValue(varargin, 'Enable', 'on');

    %% Create component 
    dropDown = uidropdown(parent, ...
                'Items', items, ...
                'Value', value, ...
                'Enable', enable);

    if  ~isempty(valueChangedFcn)
        set(dropDown, 'ValueChangedFcn', valueChangedFcn)
    end

    if ~(isempty(layoutPosition.nRow) || isempty(layoutPosition.nCol))
        % Set dropdown position in grid layout 
        dropDown.Layout.Row = layoutPosition.nRow;
        dropDown.Layout.Column = layoutPosition.nCol;
    end
    app.handleDropDown = [app.handleDropDown, dropDown];
end