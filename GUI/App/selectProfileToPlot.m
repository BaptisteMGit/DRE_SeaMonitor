classdef selectProfileToPlot < handle 
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
        Name = "Select profile to plot";
        % Icon 
        Icon = 'Icons\plotBathy1D-icon.png'
        % Type of plot
    plotType
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
        function app = selectProfileToPlot(simulation, type)
            % Pass simulation handle 
            app.Simulation = simulation;
            % Plot function
            app.plotType = type;
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

            app.GridLayout.RowHeight{3} = 5;

            
            % Label
            titleLabelFont = getLabelFont(app, 'Title');
            textLabelFont = getLabelFont(app, 'Text');

            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Select profile to plot', 'LayoutPosition', struct('nRow', 1, 'nCol', [1, 2]), 'Font', titleLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Bearing', 'LayoutPosition', struct('nRow', 2, 'nCol', 2), 'Font', textLabelFont})
            
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
            figure;
            switch app.plotType 
                    case 'bathy1D'
                        app.Simulation.plotBathy1D(nameProfile);
                    case 'tl1D'
                        app.Simulation.plotTL1D(nameProfile);
                    case 'spl1D'
                        app.Simulation.plotSPL1D(nameProfile);
                    case 'se1D'
                        app.Simulation.plotSE1D(nameProfile);
            end
        end
    end

    methods
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end
    end
end

