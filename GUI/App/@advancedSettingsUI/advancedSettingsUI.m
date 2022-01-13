classdef advancedSettingsUI < handle
    %ADVANCEDSETTINGSUI Summary of this class goes here
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
        % Name of the window 
        Name = "Advanced settings";
    end
    
    properties (Hidden=true)
        % Size of the main window 
        Width = 700;
        Height = 600;
        % Number of components 
        glNRow = 18;
        glNCol = 11;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 14;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';
    end

    properties (Dependent)
        fPosition
        InterpMethod
        SurfaceType
        BeamType
    end

    methods
        function app = advancedSettingsUI(simulation)
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
                            'CloseRequestFcn', @closeWindowCallback);

            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 'fit';

            % Bellhop parameters 
            app.addLabel('Bellhop parameters', 1, [1, 2], 'title')

            app.addLabel('Horizontal resolution', 2, 2, 'text')
            app.addEditField(app.Simulation.drSimu, 2, [4, 5], [], 'numeric', {@app.editFieldChanged, 'dr'})
            app.addLabel('km', 2, 6, 'text')

            app.addLabel('Vertical resolution', 3, 2, 'text')
            app.addEditField(app.Simulation.dzSimu, 3, [4, 5], [], 'numeric', {@app.editFieldChanged, 'dz'})
            app.addLabel('m', 3, 6, 'text')

            app.addLabel('Interpolation methods', 4, 2, 'text')
            app.addDropDown({'Cubic spline', 'C-linear', 'N-2-linear', 'Quadratic'}, app.InterpMethod, 4, [4, 7], @app.referenceFrameChanged)
            
            app.addLabel('Type of surface', 5, 2, 'text')
            app.addDropDown({'Vacuum above surface', 'Perfectly rigid media above surface', 'Acoustic half-space'}, app.SurfaceType, 5, [4, 7], @app.referenceFrameChanged)

            app.addLabel('Beam type', 6, 2, 'text')
            app.addDropDown({'Gaussian beams', 'Geometric beams'}, app.BeamType, 6, [4, 7], @app.referenceFrameChanged)


        end
    end

    methods
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

        function addEditField(app, val, nRow, nCol, placeHolder, style, varargin)
            editField = uieditfield(app.GridLayout, style, ...
                        'Value', val);
            if isempty(val) && ~isempty(placeHolder)
                editField.Placeholder = placeHolder;
            end
            if length(varargin) >= 1
                editField.ValueChangedFcn = varargin{1};
            end
            % Set edit field position in grid layout 
            editField.Layout.Row = nRow;
            editField.Layout.Column = nCol;
            app.handleEditField = [app.handleEditField, editField];
        end

        function addDropDown(app, items, val, nRow, nCol, callbackFunction)
            dropDown = uidropdown(app.GridLayout, ...
                        'Items', items, ...
                        'Value', val, ...
                        'ValueChangedFcn', callbackFunction);
            % Set dropdown position in grid layout 
            dropDown.Layout.Row = nRow;
            dropDown.Layout.Column = nCol;
            app.handleDropDown = [app.handleDropDown, dropDown];
        end
    end

    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function intMethod = get.InterpMethod(app)
            switch app.Simulation.topOption(1)
                case 'S'
                    intMethod = 'Cubic spline';
                case 'C' 
                    intMethod = 'C-linear';
                case 'N' 
                    intMethod = 'N-2-linear';
                case 'Q'
                    intMethod = 'Quadratic';
            end
        end

        function sType = get.SurfaceType(app)
            switch app.Simulation.topOption(2)
                case 'V'
                    sType = 'Vacuum above surface';
                case 'R' 
                    sType = 'Perfectly rigid media above surface';
                case 'A' 
                    sType = 'Acoustic half-space';
            end
        end

        function bType = get.BeamType(app)
            switch app.Simulation.beam.RunType(2)
                case 'G'
                    bType = 'Geometric beams';
                case 'B' 
                    bType = 'Gaussian beams';
            end
        end
    end

    methods
    
        function editFieldChanged(app, hObject, eventData, type)
            switch type 
                case 'dr'
                    app.Simulation.drSimu = hObject.Value;
                case 'dz'
                    app.Simulation.dzSimu = hObject.Value;
                case 'XPos'
                    app.Simulation.mooring.mooringPos(1) = hObject.Value;
                case 'YPos'
                    app.Simulation.mooring.mooringPos(2) = hObject.Value;
                case 'ZPos'
                    app.Simulation.mooring.mooringPos(3) = hObject.Value;
                case 'hydroDepth'
                    app.Simulation.mooring.hydrophoneDepth = hObject.Value;
            end
        end
    end
end

