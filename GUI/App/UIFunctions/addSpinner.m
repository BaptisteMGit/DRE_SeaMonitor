function addSpinner(app, varargin)
% ADDSPINNER add uispinner componnent to app window. 

    %% Check varargin format 
    if  all(size(varargin) == [1, 1])
        varargin = varargin{:};
    end

    %% Get arguments
    limits = getVararginValue(varargin, 'Limits', [-Inf Inf]);
    step = getVararginValue(varargin, 'Step', 1);
    valueDisplayFormat = getVararginValue(varargin, 'ValueDisplayFormat', '%11.4g');
    valueChangedFcn = getVararginValue(varargin, 'ValueChangedFcn', '');
    valueChangingFcn = getVararginValue(varargin, 'ValueChangingFcn', '');
    layoutPosition = getVararginValue(varargin, 'LayoutPosition', struct('nRow', [], 'nCol', []));
    editable = getVararginValue(varargin, 'Editable', 'on');
    enable = getVararginValue(varargin, 'Enable', 'on');
    parent = getVararginValue(varargin, 'Parent', []);

    %% Create component 
    spinner = uispinner(parent, ...
                'Limits', limits, ...
                'Step', step, ...
                'ValueDisplayFormat', valueDisplayFormat, ...
                'Editable', editable, ...
                'Enable', enable);

    if  ~isempty(valueChangedFcn)
        set(spinner, 'ValueChangedFcn', valueChangedFcn)
    end
    
    if  ~isempty(valueChangingFcn)
        set(spinner, 'ValueChangingFcn', valueChangingFcn)
    end
    
    if ~(isempty(layoutPosition.nRow) || isempty(layoutPosition.nCol))
        % Set spinner position in grid layout 
        spinner.Layout.Row = layoutPosition.nRow;
        spinner.Layout.Column = layoutPosition.nCol;
    end
    app.handleSpinner = [app.handleSpinner, spinner];
end