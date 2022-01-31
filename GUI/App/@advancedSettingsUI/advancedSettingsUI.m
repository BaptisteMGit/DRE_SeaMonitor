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
        Width = 500;
        Height = 350;
        % Number of components 
        glNRow = 9;
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
                            'WindowStyle', 'modal', ...
                            'CloseRequestFcn', @closeWindowCallback);

            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 200;
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 200;

            app.GridLayout.RowHeight{8} = 5;

            % Bellhop parameters 
            addLabel(app, 'Bellhop parameters', 1, [1, 2], 'title')

            addLabel(app, 'Horizontal resolution', 2, 2, 'text')
            addEditField(app, app.Simulation.bellhopEnvironment.drSimu, 2, 4, [], 'numeric', {@app.editFieldChanged, 'dr'})
            set(app.handleEditField(1), 'ValueDisplayFormat', '%.4f km') 

            addLabel(app, 'Vertical resolution', 3, 2, 'text')
            addEditField(app, app.Simulation.bellhopEnvironment.dzSimu, 3, 4, [], 'numeric', {@app.editFieldChanged, 'dz'})
            set(app.handleEditField(2), 'ValueDisplayFormat', '%.1f m')     

            addLabel(app, 'SSP interpolation method', 4, 2, 'text')
            addDropDown(app, {'Cubic spline', 'C-linear', 'N-2-linear'}, app.Simulation.bellhopEnvironment.SspInterpMethodLabel, 4, 4, @app.interpMethodChanged)
            
            addLabel(app, 'Type of surface', 5, 2, 'text')
            addDropDown(app, {'Vacuum above surface', 'Perfectly rigid media above surface', 'Acoustic half-space'}, app.Simulation.bellhopEnvironment.SurfaceTypeLabel, 5, 4, @app.surfaceTypeChanged)

            addLabel(app, 'Attenuation in the bottom', 6, 2, 'text')
            addDropDown(app, {'dB/m', 'dB/lambda'}, app.Simulation.bellhopEnvironment.AttenuationUnitLabel, 6, 4, @app.attenuationUnitChanged)

            addLabel(app, 'Beam type', 7, 2, 'text')
            addDropDown(app, {'Gaussian beams', 'Geometric rays'}, app.Simulation.bellhopEnvironment.beamTypeLabel, 7, 4, @app.beamTypeChanged)

            % Save settings 
            addButton(app, 'Save settings', 9, [2, 4], @app.saveSettings)
        

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

    end

    methods
    
        function editFieldChanged(app, hObject, eventData, type)
            switch type 
                case 'dr'
                    app.Simulation.bellhopEnvironment.drSimu = hObject.Value;
                case 'dz'
                    app.Simulation.bellhopEnvironment.dzSimu = hObject.Value;
            end
        end

        function closeWindowCallback(app, hObject, eventData)
            closeWindowCallback(app.childWindows, hObject, eventData)
        end

        function interpMethodChanged(app)
            switch hOject.Value
                case 'Cubic spline'
                    app.Simulation.bellhopEnvironment.SspOption(1) = 'S';
                case 'C-linear' 
                    app.Simulation.bellhopEnvironment.SspOption(1) = 'C';
                case 'N-2-linear' 
                    app.Simulation.bellhopEnvironment.SspOption(1) = 'N';
                    % Quadratic interpolation requires the creation of the
                    % a *.ssp file containing the field. Not considered for
                    % the moment dur to more complexity.
%                 case 'Quadratic'
%                     intMethod = 'Q';
            end
        end

        function beamTypeChanged(app, hObject, eventData)
            switch hOject.Value
                case 'Gaussian beams'
                    app.Simulation.bellhopEnvironment.beam.RunType(2) = 'B';
                case 'Geometric rays'
                    app.Simulation.bellhopEnvironment.beam.RunType(2) = 'G';
            end
        end
        
        function surfaceTypeChanged(app)
            % TODO: handle different type of surface ? 
            % Is it really relevant to let the user choose ? 
        end

        function attenuationUnitChanged(app, hOject, eventData)
            switch hOject.Value
                case 'db/m'
                    app.Simulation.bellhopEnvironment.SspOption(3) = 'M';
                case 'db/lambda'
                    app.Simulation.bellhopEnvironment.SspOption(3) = 'W';
            end
        end

        function saveSettings(app, hObject, eventData)
            close(app.Figure)
        end 
    end
end

