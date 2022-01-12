classdef configEnvironmentUI < handle
% configEnvironementUI: App window dedicated to the configuration of the
% simulation environment 
%
% Baptiste Menetrier    

    properties
        % Simulation handle 
        Simulation
        % Graphics handles
        Figure
        GridLayout 
        handleLabels
        handleEditField
        handleDropDown
        % Name of the window 
        Name = "Configure environment";
    end 
    
    properties (Dependent)

        % Position of the main figure 
        fPosition 
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 600;
        Height = 500;
        % Number of components 
        glNRow = 15;
        glNCol = 7;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 14;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';
    end
    
    %% Constructor of the class 
    methods       
        function app = configEnvironmentUI(simulation)
            % Pass simulation handle 
            app.Simulation = simulation;
            % Figure 
            app.Figure = uifigure('Name', app.Name, ...
                            'Visible', 'on', ...
                            'NumberTitle', 'off', ...
                            'Position', app.fPosition, ...
                            'Toolbar', 'none', ...
                            'MenuBar', 'none', ...
                            'Resize', 'on', ...
                            'AutoResizeChildren', 'off', ...
                            'WindowStyle', 'normal', ...
                            'WindowState', 'maximized', ...
                            'CloseRequestFcn', @closeWindowCallback);
            
            % Grid Layout
            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 'fit';
            app.GridLayout.ColumnWidth{3} = 10;

            % Labels 
            % Bathymetry 
            app.addLabel('Bathymetry', 1, [1, 2], 'title')
            app.addLabel('File', 2, 2, 'text')
            app.addLabel('Reference Frame', 3, 2, 'text')
            app.addLabel('Resolution', 4, 2, 'text')
            % Mooring
            app.addLabel('Mooring', 5, [1, 2], 'title')
            app.addLabel('Name', 6, 2, 'text')
            app.addLabel('Position', 7, 2, 'text')
            app.addLabel('Hydrophone Depth', 8, 2, 'text')
            % Marine mammal 
            app.addLabel('Marine mammal', 9, [1, 2], 'title')
            app.addLabel('Specie', 10, 2, 'text')
            % Detector
            app.addLabel('Equipment', 11, [1, 2], 'title')
            app.addLabel('Hydrophone', 12, 2, 'text')
            % Noise level 
            app.addLabel('Noise level', 13, [1, 2], 'title')
            app.addLabel('Computing model', 14, 2, 'text')

            % Edit field
            % Bathy
            app.addEditField(app.Simulation.bathyEnvironment.bathyFile, 2, [4, 6], '', 'text') % Bathy file 
            app.addEditField(app.Simulation.bathyEnvironment.drBathy, 4, 4, [], 'numeric') % Bathy resolution 
            % Mooring
            app.addEditField('', 6, [4, 6], 'Mooring name (name of the simulation)', 'text') % Name 
            app.addEditField([], 7, 4, 'X', 'numeric') % X Pos 
            
            % Drop down 
            app.addDropDown({'WGS84', 'ENU', 'UTM'}, 'WGS84', 3, 4)
        end
    end
    
    %% Set up methods 
    methods
        function addLabel(app, txt, nRow, nCol, labelType)
            % Create label 
            label = uilabel(app.GridLayout, ...
                        'Text', txt, ...
                        'HorizontalAlignment', 'left', ...
                        'FontName', app.LabelFontName, ...
                        'VerticalAlignment', 'center');
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
            app.handleLabels = [app.handleLabels, label];
        end

        function addEditField(app, val, nRow, nCol, placeHolder, style)
            editField = uieditfield(app.GridLayout, style, ...
                        'Value', val);
            if isempty(val) && ~isempty(placeHolder)
                editField.Placeholder = placeHolder;
            end
            % Set edit field position in grid layout 
            editField.Layout.Row = nRow;
            editField.Layout.Column = nCol;
            app.handleEditField = [app.handleEditField, editField];
        end

        function addDropDown(app, items, val, nRow, nCol)
            dropDown = uidropdown(app.GridLayout, ...
                        'Items', items, ...
                        'Value', val);
            % Set edit field position in grid layout 
            dropDown.Layout.Row = nRow;
            dropDown.Layout.Column = nCol;
            app.handleDropDown = [app.handleDropDown, dropDown];
        end
    end

    %% Callback functions 
    methods
        function resizeWindow(app, hObject, eventData)
            currentPos = get(app.Figure, 'Position');
            app.Width = currentPos(3);
            app.Height = currentPos(4);
            pause(0.01) % Little pause to avoid freeze ending in visuals bugs           
            app.updateLabel
            app.updateButtons
        end

        function updateButtons(app)
            for i_b = 1:length(app.ListButtons)
                button = app.ListButtons(i_b);
                app.currButtonID = i_b-1;
                set(button, 'Position', app.bPosition)
            end
        end

        function updateLabel(app)
            app.Label.Position = app.lPosition;
        end
    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end
    end 
end