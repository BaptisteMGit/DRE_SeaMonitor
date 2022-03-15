classdef selectSigmaHUI < handle 
    %SELECTSIGMAHUI Summary of this class goes here
    %   Detailed explanation goes here
    %   Baptiste Menetrier    

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
        % Name of the window 
        Name = "Head angle standard deviation";
        % Icon 
        Icon = 'Icons\PlottingTools-icon.png'
    end 
    
    properties (Dependent)
        % Position of the main figure 
        fPosition 
        % Position of the labels for Mooring Positon 
        MooringPosLabel
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 300;
        Height = 200;
        % Number of components 
        glNRow = 4;
        glNCol = 4;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 14;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';

        % Sub-windows 
        subWindows = {};

    end
    
    %% Constructor of the class 
    methods       
        function app = selectSigmaHUI(simulation)
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
                            'WindowStyle', 'modal', ...
                            'CloseRequestFcn', @closeWindowCallback, ...
                            'Icon', app.Icon);
                        
            % Grid Layout
            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 'fit';
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 100;

            app.GridLayout.RowHeight{3} = 10;

            % Labels 
            titleLabelFont = getLabelFont(app, 'Title');
            textLabelFont = getLabelFont(app, 'Text');

            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Head angle', 'LayoutPosition', struct('nRow', 1, 'nCol', [1, 2]), 'Font', titleLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Standard deviation', 'LayoutPosition', struct('nRow', 2, 'nCol', 2), 'Font', textLabelFont})
            
            % Edit field

            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.sigmaH, ...
                'LayoutPosition', struct('nRow', 2, 'nCol', 4), 'ValueChangedFcn', @app.sigmaHChanged, 'ValueDisplayFormat', '%d °'})

            % Save settings 
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Save settings', 'ButtonPushedFcn', @app.saveSettings, 'LayoutPosition', struct('nRow', 4, 'nCol', [2, 4])})

        end
    end

    %% Callback functions 
    methods       
        function saveSettings(app, hObject, eventData)
            % Delete UI
            delete(app.Figure)
        end

        function sigmaHChanged(app, hObject, eventData)
            app.Simulation.sigmaH = hObject.Value;
        end
    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end
    end 
end

