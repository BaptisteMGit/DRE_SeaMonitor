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
        handleLabel
        handleEditField
        handleDropDown
        handleButton
        % Name of the window 
        Name = "Configure environment";
    end 
    
    properties (Dependent)

        % Position of the main figure 
        fPosition 
        % Position of the labels for Mooring Positon 
        MooringPosLabel
       
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 575;
        Height = 600;
        % Number of components 
        glNRow = 16;
        glNCol = 9;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 14;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';
        
        % Subwindow open to kill when this window is closed 
        subWindows = {};

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
                            'WindowStyle', 'modal', ...
                            'CloseRequestFcn', @closeWindowCallback);
%             app.Figure.WindowState = 'fullscreen';
            
            % Grid Layout
            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 'fit';
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 50;
            app.GridLayout.ColumnWidth{5} = 50;
            app.GridLayout.ColumnWidth{6} = 50;
            app.GridLayout.ColumnWidth{7} = 50;
            app.GridLayout.ColumnWidth{8} = 5;
            app.GridLayout.ColumnWidth{9} = 110;

            app.GridLayout.RowHeight{15} = 30;


            % Labels 
            % Bathymetry 
            addLabel(app, 'Bathymetry', 1, [1, 2], 'title')
            addLabel(app, 'Source', 2, 2, 'text')
%             addLabel(app, 'Reference Frame', 3, 2, 'text')
%             addLabel(app, 'Resolution', 4, 2, 'text')
%             addLabel(app, 'm', 4, 6, 'text')
            % Mooring
            addLabel(app, 'Equipment', 3, [1, 2], 'title')
            addLabel(app, 'Name of the study', 4, 2, 'text')
            addLabel(app, 'Position', 5, 2, 'text')
            addLabel(app, 'Hydrophone depth', 6, 2, 'text')
            hydrophoneDepthTooltip = ['Hydrophone depth is counted positive ',...
                                'from surface toward bottom. You can also set ', ...
                                'negative depth to reference an altitude over the seabed.'];
            addLabel(app, 'm', 6, [6, 11], 'text', 'left', hydrophoneDepthTooltip)
            addLabel(app, app.MooringPosLabel(1), 5, 4, 'text', 'right')
            addLabel(app, app.MooringPosLabel(2), 5, 6, 'text', 'right')
            % Marine mammal 
            addLabel(app, 'Marine mammal', 8, [1, 2], 'title')
            addLabel(app, 'Specie', 9, 2, 'text')
            % Detector
%             addLabel(app, 'Equipment', 9, [1, 2], 'title')
            addLabel(app, 'Hydrophone', 7, 2, 'text')
            % Noise level 
            addLabel(app, 'Ambient noise', 10, [1, 2], 'title')
            addLabel(app, 'Option', 11, 2, 'text')
            addLabel(app, 'Noise level', 12, 2, 'text')  
            % Bellhop 
            addLabel(app, 'Bellhop parameters', 13, [1, 2], 'title')

            % Edit field
            % Mooring
            addEditField(app, app.Simulation.mooring.mooringName, 4, [4, 7], 'Name of the simulation', 'text', {@app.editFieldChanged, 'mooringName'}) % Name
            addEditField(app, app.Simulation.mooring.mooringPos.lon, 5, 5, [], 'numeric', {@app.editFieldChanged, 'XPos'}) % X Pos 
            addEditField(app, app.Simulation.mooring.mooringPos.lat, 5, 7, [], 'numeric', {@app.editFieldChanged, 'YPos'}) % Y Pos 
            addEditField(app, app.Simulation.mooring.hydrophoneDepth, 6, [4, 5], [], 'numeric', {@app.editFieldChanged, 'hydroDepth'}) % Hydro depth
            addEditField(app, app.Simulation.noiseEnvironment.noiseLevel, 12, [4, 5], [], 'numeric', {@app.editFieldChanged, 'noiseLevel'}) % Hydro depth

            % Drop down 
            % Bathymetry 
            addDropDown(app, {'GEBCO2021', 'Userfile'}, app.Simulation.bathyEnvironment.source, 2, [4, 7], @app.bathySourceChanged) % Auto loaded bathy 
            % Hydrophone
            addDropDown(app, {'CPOD', 'FPOD', 'SoundTrap'}, app.Simulation.detector.name, 7, [4, 7], @app.detectorChanged)
            % Specie
            addDropDown(app, {'Common dolphin', 'Bottlenose dolphin', 'Porpoise'}, app.Simulation.marineMammal.name, 9, [4, 7], @app.specieChanged)
            % Noise level model
            addDropDown(app, {'Derived from recording', 'Derived from Wenz model', 'Input value'}, app.Simulation.noiseEnvironment.computingMethod, 11, [4, 7], @app.noiseOptionChanged)

            % Buttons
            % Edit hydrophone
            addButton(app, 'Edit properties', 7, 9, @app.editDetectorProperties)
            % Edit specie 
            addButton(app, 'Edit properties', 9, 9, @app.editMarinneMammalProperties)
            % Edit noise level 
            addButton(app, 'Edit properties', 11, 9, @app.editNoiseLevelPorperties)
            
            % Advanced settings 
            addButton(app, 'Advanced simulation settings', 14, [4, 9], @app.advancedSettings)
            % Save settings 
            addButton(app, 'Save settings', 16, [5, 8], @app.saveSettings)
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
        
        function bathySourceChanged(app, hObject, eventData)
            newSource =  hObject.Value;
            app.Simulation.bathyEnvironment.source = newSource;
            if strcmp(newSource, 'Userfile')
                app.subWindows{end+1} = bathyAdvancedSettingsUI(app.Simulation);
            end
        end

        function specieChanged(app, hObject, eventData)
            switch hObject.Value
                case 'Common dolphin'
                    newSpecie = CommonDolphin;
                case 'Bottlenose dolphin'
                    newSpecie = BottlenoseDolphin;
                case 'Porpoise'
                    newSpecie = Porpoise;
            end
            app.Simulation.marineMammal = newSpecie;
        end

        function detectorChanged(app, hObject, eventData)
            switch hObject.Value
                case 'CPOD'
                    newDetector = CPOD;
                case 'FPOD'
                    newDetector = FPOD;
               case 'SoundTrap'
                    newDetector = SoundTrap;
            end
            app.Simulation.detector = newDetector;
        end

        function noiseOptionChanged(app, hObject, eventData)
            app.Simulation.noiseEnvironment.computingMethod = hObject.Value;
            switch hObject.Value
                case 'Derived from recording'
                    if isempty(app.Simulation.noiseEnvironment.recording)
                        app.Simulation.noiseEnvironment.recording = Recording(app.Simulation.marineMammal.centroidFrequency); 
                    end
                    app.subWindows{end+1} = selectRecordingUI(app.Simulation, app.handleEditField(5));
                    bool = 0;
                case 'Derived from Wenz model'
                    % TODO: compute with model 
                    bool = 0;
               case 'Input value'
                    % TODO: open window to input value 
                    bool = 1;
            end
            set(app.handleEditField(5), 'Editable', bool)
        end

        function editFieldChanged(app, hObject, eventData, type)
            switch type 
                case 'mooringName'
                    app.Simulation.mooring.mooringName = regexprep(hObject.Value, ' ', ''); % Remove blanks
                case 'XPos'
                    app.Simulation.mooring.mooringPos.lat = hObject.Value;
                case 'YPos'
                    app.Simulation.mooring.mooringPos.lon = hObject.Value;
                case 'hydroDepth'
                    app.Simulation.mooring.hydrophoneDepth = hObject.Value;
            end
        end

        function editMarinneMammalProperties(app, hOject, eventData)
            % Open editUI
        end

        function editDetectorProperties(app, hObject, eventData)
            % Open editUI
        end

        function editNoiseLevelPorperties(app, hObject, eventData)
            switch get(app.handleDropDown(4), 'Value')
                case 'Derived from recording'
                    if isempty(app.Simulation.noiseEnvironment.recording)
                        app.Simulation.noiseEnvironment.recording = Recording(app.Simulation.marineMammal.centroidFrequency); 
                    end
                    app.subWindows{end+1} = selectRecordingUI(app.Simulation, app.handleEditField(5));
                case 'Derived from Wenz model'
                case 'Input value'
            end
            % Open editUI
        end

        function advancedSettings(app, hObject, eventData)
            % Open advancedSettingsUI
            app.subWindows{end+1} = advancedSettingsUI(app.Simulation);
        end
        
        function closeWindow(app, hObject, eventData)
            closeWindowCallback(app, hObject, eventData)
        end
        
        function saveSettings(app, hObject, eventData)
            % Check user choices 
            app.checkAll
            % Close UI
            close(app.Figure)
        end
    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function moorPosLabels = get.MooringPosLabel(app)
            switch app.Simulation.bathyEnvironment.inputCRS
                case 'WGS84'
                    moorPosLabels = {'lat(DD)', 'lon(DD)', 'hgt(m)'};
                case 'ENU'
                    moorPosLabels = {'E(m)', 'N(m)', 'U(m)'};
                otherwise
                    moorPosLabels = {'X(m)', 'Y(m)', 'Z(m)'};
            end
        end
    end 

    %% Set methods 
    methods 
        function set.MooringPosLabel(app, moorPosLabels)
            set(app.handleLabel(11), 'Text', moorPosLabels(1))
            set(app.handleLabel(12), 'Text', moorPosLabels(2))
            set(app.handleLabel(13), 'Text', moorPosLabels(3))
        end
    end

    %% Check functions 
    % Functions to ensure all parameters are fitting with the program
    % expectations 
    methods
        function checkBathyEnvironment(app)
            [bool, msg] = app.Simulation.bathyEnvironment.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Bathymetry environment warning', 'warning')
        end

        function checkNoiseEnvironment(app)
%             [bool, msg] = app.Simulation.bathyEnvironment.checkParametersValidity;
%             aassertDialogBox(app, bool, msg, 'Bathymetry environment failed', 'warning')
        end


        function checkMooring(app)
            [bool, msg] = app.Simulation.mooring.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Mooring environment warning', 'warning')
        end


        function checkDetector(app)
            
        end


        function checkMarineMammal(app)
            
        end

        
        function checkBellhopParameters(app)
            [bool, msg] = app.Simulation.mooring.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Mooring environment warning', 'warning')
        end

        function checkAll(app)
            app.checkBathyEnvironment
            app.checkNoiseEnvironment
            app.checkMooring
            app.checkDetector
            app.checkMarineMammal
            app.checkBellhopParameters
        end
    end
    
end