function addLabel(app, varargin)
% ADDLABEL add uilabel componnent to app window. 
% varargin = {'Parent', app.GridLayout, 'Text', 'Bellhop',
% 'LayoutPosition', struct('nRow', 2, 'nCol', 3))}
    %% Check varargin format 
    if  all(size(varargin) == [1, 1])
        varargin = varargin{:};
    end

    %% Get arguments
    parent = getVararginValue(varargin, 'Parent', []);
    text = getVararginValue(varargin, 'Text', 'Label');
    fontName = getVararginValue(varargin, 'FontName', 'Arial');
    horizontalAlignment = getVararginValue(varargin, 'HorizontalAlignment', 'left');
    verticalAlignment = getVararginValue(varargin, 'verticalAlignment', 'center');
    layoutPosition = getVararginValue(varargin, 'LayoutPosition', struct('nRow', [], 'nCol', []));
    enable = getVararginValue(varargin, 'Enable', 'on');
    font = getVararginValue(varargin, 'Font', struct('Size', 12, 'Weight', 'normal'));
    tooltip = getVararginValue(varargin, 'Tooltip', '');

    %% Create component 
    label = uilabel(parent, ...
                'Text', text, ...
                'FontName', fontName, ...
                'HorizontalAlignment', horizontalAlignment, ...
                'VerticalAlignment', verticalAlignment, ...
                'Enable', enable, ...
                'FontSize', font.Size, ...
                'FontWeight', font.Weight, ...
                'Tooltip', tooltip);


    if ~(isempty(layoutPosition.nRow) || isempty(layoutPosition.nCol))
        % Set label position in grid layout 
        label.Layout.Row = layoutPosition.nRow;
        label.Layout.Column = layoutPosition.nCol;
    end

    % Set Font parameters depending of type 
%     if strcmp(labelType, 'title')
%         label.FontSize = app.LabelFontSize_title;
%         label.FontWeight = app.LabelFontWeight_title;
%     elseif strcmp(labelType, 'text')
%         label.FontWeight = app.LabelFontWeight_text;
%         label.FontSize = app.LabelFontSize_text;
%     end
    % Store handle to created label
    app.handleLabel = [app.handleLabel, label];
end

