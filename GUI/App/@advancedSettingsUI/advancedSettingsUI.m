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
        glNRow = 11;
        glNCol = 4;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 14;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';

        % Sub-windows 
        subWindows = {};

        % Flag to check if properties have been updated 
        flagChanges = 0;
    end

    properties (Dependent)
        fPosition
        interpMethod
        surfaceType
        attenuationUnit
        beamType
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
                            'CloseRequestFcn', @app.closeWindowCallback);

            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 200;
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 200;

            app.GridLayout.RowHeight{10} = 5;

            % Bellhop parameters 
            addLabel(app, 'Bellhop parameters', 1, [1, 2], 'title')

            addLabel(app, 'Horizontal resolution', 2, 2, 'text')
            addEditField(app, app.Simulation.bellhopEnvironment.drSimu, 2, 4, [], 'numeric', @app.propertyChanged)
            set(app.handleEditField(1), 'ValueDisplayFormat', '%.4f km') 

            addLabel(app, 'Vertical resolution', 3, 2, 'text')
            addEditField(app, app.Simulation.bellhopEnvironment.dzSimu, 3, 4, [], 'numeric', @app.propertyChanged)
            set(app.handleEditField(2), 'ValueDisplayFormat', '%.1f m')     

            addLabel(app, 'SSP interpolation method', 4, 2, 'text')
            addDropDown(app, {'Cubic spline', 'C-linear', 'N-2-linear'}, app.Simulation.bellhopEnvironment.SspInterpMethodLabel, 4, 4, @app.propertyChanged)
            
            addLabel(app, 'Type of surface', 5, 2, 'text')
            addDropDown(app, {'Vacuum above surface', 'Perfectly rigid media above surface', 'Acoustic half-space'}, app.Simulation.bellhopEnvironment.SurfaceTypeLabel, 5, 4, @app.propertyChanged)
            set(app.handleDropDown(2), 'Enable', 'off') % Not editable for the moment 

            addLabel(app, 'Attenuation in the bottom', 6, 2, 'text')
            addDropDown(app, {'dB/m', 'dB/lambda'}, app.Simulation.bellhopEnvironment.AttenuationUnitLabel, 6, 4, @app.propertyChanged)
            set(app.handleDropDown(3), 'Enable', 'off') % Not editable for the moment 

            addLabel(app, 'Beam type', 7, 2, 'text')
            addDropDown(app, {'Gaussian beams', 'Geometric rays'}, app.Simulation.bellhopEnvironment.beamTypeLabel, 7, 4, @app.propertyChanged)

            addLabel(app, 'Number of beams', 8, 2, 'text')
            addEditField(app, app.Simulation.bellhopEnvironment.beam.Nbeams, 8, 4, [], 'numeric', @app.propertyChanged)
            set(app.handleEditField(3), 'ValueDisplayFormat', '%d')     

            addLabel(app, 'Beam aperture', 9, 2, 'text')
            addEditField(app, abs(app.Simulation.bellhopEnvironment.beam.alpha(1)), 9, 4, [], 'numeric', @app.propertyChanged)
            set(app.handleEditField(4), 'ValueDisplayFormat', '+/- %.1f°')     

            % Save settings 
            addButton(app, 'Save settings', 11, [2, 4], @app.saveSettings)
        end
    end

    methods
         function closeWindowCallback(app, hObject, eventData)
            if app.flagChanges
                msg = 'Do you want to save the changes ?';
                options = {'Save and quit', 'Quit without saving', 'Cancel'};
                selection = uiconfirm(app.Figure, msg, 'Save settings ?', ...
                                'Options', options, ...
                                'DefaultOption',1,'CancelOption',3);
                switch selection
                    case options{1}
                        app.saveProperties()
                        delete(app.Figure)
                    case options{2}
                        delete(app.Figure)
                    otherwise
                        return
                end
            else
                delete(app.Figure)
            end
         end

        function propertyChanged(app, hObject, eventData)
            app.flagChanges = 1;
        end

        function saveProperties(app)
            app.Simulation.bellhopEnvironment.drSimu = get(app.handleEditField(1), 'Value');
            app.Simulation.bellhopEnvironment.dzSimu = get(app.handleEditField(2), 'Value');
            app.Simulation.bellhopEnvironment.SspOption(1) = app.interpMethod;
            app.Simulation.bellhopEnvironment.SspOption(2) = app.surfaceType;
            app.Simulation.bellhopEnvironment.SspOption(3) = app.attenuationUnit;
            app.Simulation.bellhopEnvironment.beam.RunType(2) = app.beamType;
            app.Simulation.bellhopEnvironment.beam.Nbeams = get(app.handleEditField(3), 'Value');
            app.Simulation.bellhopEnvironment.beam.alpha(1) = abs(get(app.handleEditField(4), 'Value'));
            app.Simulation.bellhopEnvironment.beam.alpha(2) = abs(get(app.handleEditField(4), 'Value'));
        end

        function saveSettings(app, hObject, eventData)
            app.saveProperties()
            delete(app.Figure)
        end 
    end

    %% Get methods 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function interpMethod = get.interpMethod(app)
            switch get(app.handleDropDown(1), 'Value')
                case 'Cubic spline'
                    interpMethod = 'S';
                case 'C-linear' 
                    interpMethod = 'C';
                case 'N-2-linear' 
                    interpMethod = 'N';
                    % Quadratic interpolation requires the creation of the
                    % a *.ssp file containing the field. Not considered for
                    % the moment dur to more complexity.
%                 case 'Quadratic'
%                     interpMethod = 'Q';
            end
        end
        
        function surfaceType = get.surfaceType(app)
            switch get(app.handleDropDown(2), 'Value')
                case 'Vacuum above surface'
                    surfaceType = 'V';
                case 'Perfectly rigid media above surface'
                    surfaceType = 'R';
                case 'Acoustic half-space'
                    surfaceType = 'A';
            end 
        end

        function attenuationUnit = get.attenuationUnit(app)
            switch get(app.handleDropDown(3), 'Value')
                case 'dB/m'
                    attenuationUnit = 'M';
                case 'dB/lambda'
                    attenuationUnit = 'W';
            end
        end

        function beamType = get.beamType(app)
            switch get(app.handleDropDown(4), 'Value')
                case 'Gaussian beams'
                    beamType = 'B';
                case 'Geometric rays'
                    beamType = 'G';
            end
        end
    end
end

