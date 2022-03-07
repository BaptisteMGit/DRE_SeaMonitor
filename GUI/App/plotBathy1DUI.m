classdef plotBathy1DUI < handle 
    %PLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Simulation handle 
        Simulation
        % Graphics handles
        Figure 
        GridLayout
        handleLabel
        handleEditField
        handleDropDown
        handleButton
        handleSpinner
        % Name of the window 
        Name = "Plot bathymetry 1D";
        % Icon 
        Icon = 'Icons\plotBathy1D-icon.png'
    end

  properties (Hidden=true)
    % Size of the main window 
    Width = 300;
    Height = 150;
    % Number of components 
    glNRow = 4;
    glNCol = 4; 
    
    % Labels visual properties 
    LabelFontName = 'Arial';
    LabelFontSize_title = 16;
    LabelFontSize_text = 14;
    LabelFontWeight_title = 'bold';
    LabelFontWeight_text = 'normal';
        
    end

    properties (Dependent)
        % Position of the main figure 
        fPosition 
    end

    
    methods
        function app = plotBathy1DUI(simulation)
            % Pass simulation handle 
            app.Simulation = simulation;
            % Figure 
            app.Figure = uifigure('Name', app.Name, ...
                            'Icon', app.Icon, ...
                            'Visible', 'on', ...
                            'NumberTitle', 'off', ...
                            'Position', app.fPosition, ...
                            'Toolbar', 'none', ...
                            'MenuBar', 'none', ...
                            'Resize', 'on', ...
                            'AutoResizeChildren', 'off', ...
                            'WindowStyle', 'modal');

            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 'fit';
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 100;

            addLabel(app, 'Plot bathymetry 1D', 1, [1, 2], 'title')
            addLabel(app, 'Bearing', 2, 2, 'text')
            
            addSpinner(app, { 'Parent', app.GridLayout, ...
                'Limits',[min(app.Simulation.listAz), max(app.Simulation.listAz)], ...
                'Step', app.Simulation.bearingStep, 'ValueDisplayFormat', '%.1f°', ...
                'LayoutPosition', struct('nRow', 2, 'nCol', 4), ...
                'Editable', 'off'})

            addButton(app, {'Name', 'Plot', ...
                'ButtonPushedFcn', @app.plot1D ...
                'LayoutPosition', struct('nRow', 4, 'nCol', [2, 4]), ...
                'Parent', app.GridLayout})
        end
        
        function plot1D(app, hObject, eventData)
            theta = get(app.handleSpinner(1), 'Value');
            nameProfile = sprintf('%s-%2.1f', app.Simulation.mooring.mooringName, theta);
            app.Simulation.plotBathy1D(nameProfile)
        end
    end

    methods
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end
    end
end

