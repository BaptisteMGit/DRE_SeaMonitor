function addLabel(app, txt, nRow, nCol, labelType, varargin)
    % Create label 
    label = uilabel(app.GridLayout, ...
                'Text', txt, ...
                'HorizontalAlignment', 'left', ...
                'FontName', app.LabelFontName, ...
                'VerticalAlignment', 'center');
    if length(varargin) >= 1
        label.HorizontalAlignment = varargin{1};
    end
    if length(varargin) >= 2
        label.Tooltip = varargin{2};
    end
    % Set label position in grid layout 
    label.Layout.Row = nRow;
    label.Layout.Column = nCol;
    % Set Font parameters depending of type 
    if strcmp(labelType, 'title')
        label.FontSize = app.LabelFontSize_title;
        label.FontWeight = app.LabelFontWeight_title;
    elseif strcmp(labelType, 'text')
        label.FontWeight = app.LabelFontWeight_text;
        label.FontSize = app.LabelFontSize_text;
    end
    % Store handle to created label
    app.handleLabel = [app.handleLabel, label];
end

