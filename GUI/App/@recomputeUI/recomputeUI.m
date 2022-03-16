classdef recomputeUI < handle
% recomputeUI: App window to select new parameters NL, DT to recompute
% detection range
%
% Baptiste Menetrier    

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
        Name = "Recompute detection range";
    end 
    
    properties (Dependent)

        % Position of the main figure 
        fPosition 
        % Position of the labels for Mooring Positon 
        MooringPosLabel
       
    end

    properties (Hidden=true)
        % Size of the window 
        Width = 400;
        Height = 170;
        % Define font style
        FontSize = 16;
        FontName = 'Arial';
        % Number of components 
        glNRow = 6;
        glNCol = 5;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 16;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';
        
        % Sub-windows 
        subWindows = {};
    end
    
    %% Constructor of the class 
    methods       
        function app = recomputeUI(simulation)
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
                            'CloseRequestFcn', @closeWindowCallback);
%             app.Figure.WindowState = 'fullscreen';
            
            % Grid Layout
            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);

            app.GridLayout.ColumnWidth{1} = 60;
            app.GridLayout.ColumnWidth{2} = 130;
            app.GridLayout.ColumnWidth{3} = 60;
            app.GridLayout.ColumnWidth{4} = 20;
            app.GridLayout.ColumnWidth{5} = 120;

            app.GridLayout.RowHeight{1} = 10;
            app.GridLayout.RowHeight{2} = 20;
            app.GridLayout.RowHeight{3} = 5;
            app.GridLayout.RowHeight{4} = 20;
            app.GridLayout.RowHeight{5} = 10;
            app.GridLayout.RowHeight{6} = 30;

            %%% Labels %%%
            titleLabelFont = getLabelFont(app, 'Title');
            textLabelFont = getLabelFont(app, 'Text');
            
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Noise level', 'LayoutPosition', struct('nRow', 2, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Detection threshold', 'LayoutPosition', struct('nRow', 4, 'nCol', 2), 'Font', textLabelFont})

            %%% Edit field %%%
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.noiseEnvironment.noiseLevel, ...
                'LayoutPosition', struct('nRow', 2, 'nCol', 3), 'ValueChangedFcn', {@app.editFieldChanged, 'NL'}, 'ValueDisplayFormat', '%.1f dB'})            % Simulation 
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.detector.detectionThreshold, ...
                'LayoutPosition', struct('nRow', 4, 'nCol', 3), 'ValueChangedFcn', {@app.editFieldChanged, 'DT'}, 'ValueDisplayFormat', '%.1f dB'})
            
            %%% Button %%%
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Recompute', 'ButtonPushedFcn', @app.recomputeButtonPushed, 'LayoutPosition', struct('nRow', 6, 'nCol', [2, 4])})

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

        function editFieldChanged(app, hObject, eventData, type)
            switch type 
                case 'NL'
                    app.Simulation.noiseLevel = hObject.Value;
                case 'DT'
                    app.Simulation.detector.detectionThreshold = hObject.Value;
            end
        end
        
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function recomputeButtonPushed(app, hObject, eventData)
            app.Simulation.recomputeDRE
        end

        function closeWindowCallback(app, hObject, eventData)
            closeWindowCallback(app.subWindows, hObject, eventData)
        end
    end

end