classdef configEnvironmentUI < handle
% CONFIGENVIORNMENTUI: App window dedicated to the configuration of the
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
        % Icon 
        Icon = 'Icons\icons8-settings-58.png'
    end 
    
    properties (Dependent)
        % Position of the main figure 
        fPosition 
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 600;
        Height = 725;
        % Number of components 
        glNRow = 24;
        glNCol = 9;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 14;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';
        
        % Subwindow open to kill when this window is closed 
        subWindows = {};
        
        % Handle issue with unsaved custom source / sediment 
        marineMammalName
        sedimentType
    end
    
    %% Constructor of the class 
    methods       
        function app = configEnvironmentUI(simulation)
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

            app.GridLayout.RowHeight{23} = 10;


            %%% Labels %%%
            % Bathymetry 
            addLabel(app, 'Bathymetry', 1, [1, 2], 'title')
            addLabel(app, 'Source', 2, 2, 'text')

            % Mooring
            addLabel(app, 'Equipment', 3, [1, 2], 'title')
            addLabel(app, 'Name of the study', 4, 2, 'text')
            addLabel(app, 'Position', 5, 2, 'text')
            hydrophoneDepthTooltip = ['Hydrophone depth is counted positive ',...
                    'from surface toward bottom. You can also set ', ...
                    'negative depth to reference an altitude over the seabed.'];
            addLabel(app, 'Hydrophone depth', 6, 2, 'text', 'left', hydrophoneDepthTooltip)
            addLabel(app, 'lon (dd)', 5, 4, 'text', 'right')
            addLabel(app, 'lat (dd)', 5, 6, 'text', 'right')          
            addLabel(app, 'Hydrophone', 7, 2, 'text') % Detector
            addLabel(app, 'Deployement (start-stop) ', 8, 2, 'text')
            
            startDatePicker = uidatepicker(app.GridLayout, ...
                "DisplayFormat", 'yyyy-MM-dd', ...
                "ValueChangedFcn", {@app.deployementDateChanged, 'start'}, ...
                "Limits", [datetime('1993-01-01', 'InputFormat', 'yyyy-MM-dd'), ...
                           datetime('today')]);
            startDatePicker.Value = datetime(app.Simulation.mooring.deploymentDate.startDate, 'InputFormat','yyyy-MM-dd');

            startDatePicker.Layout.Row = 8;
            startDatePicker.Layout.Column = [4, 5];

            stopDatePicker = uidatepicker(app.GridLayout, ...
                "DisplayFormat", 'yyyy-MM-dd', ...
                "ValueChangedFcn", {@app.deployementDateChanged, 'stop'}, ...
                "Limits", [startDatePicker.Value, ...
                           datetime('today')], ...
                "Value", datetime(app.Simulation.mooring.deploymentDate.stopDate, 'InputFormat', 'yyyy-MM-dd'));
            stopDatePicker.Layout.Row = 8;
            stopDatePicker.Layout.Column = [6, 7];

            % Marine mammal 
            addLabel(app, 'Marine mammal', 9, [1, 2], 'title')
            addLabel(app, 'Specie', 10, 2, 'text')

            % Noise level 
            addLabel(app, 'Ambient noise', 11, [1, 2], 'title')
            addLabel(app, 'Option', 12, 2, 'text')
            addLabel(app, 'Noise level', 13, 2, 'text')  
            
            % Seabed 
            addLabel(app, 'Seabed', 14, [1, 2], 'title')
            addLabel(app, 'Sediment', 15, 2, 'text')

            % Bellhop 
            addLabel(app, 'Simulation parameters', 16, [1, 2], 'title')
            azimuthResolutionTooltip = ['The azimuth resolution is the angle between to consecutive profiles.',...
                'Please note that reducing the resolution increases drastically the computing time.'];
            addLabel(app, 'Azimuth resolution', 17, 2, 'text', 'left', azimuthResolutionTooltip)
            addLabel(app, 'Bellhop settings', 18, 2, 'text')

            % Detection function 
            addLabel(app, 'Detection range', 19, [1, 2], 'title')
            addLabel(app, 'Threshold', 20, 2, 'text')
            addLabel(app, 'Off-axis distribution', 21, 2, 'text')
            addLabel(app, 'Off-axis attenuation', 22, 2, 'text')


            %%% Edit field %%%
            % Mooring
            addEditField(app, app.Simulation.mooring.mooringName, 4, [4, 7], 'Name of the simulation', 'text', {@app.editFieldChanged, 'mooringName'}) % Name
            addEditField(app, app.Simulation.mooring.mooringPos.lon, 5, 5, [], 'numeric', {@app.editFieldChanged, 'lon'}) % lon 
            set(app.handleEditField(2), 'ValueDisplayFormat', '%.2f°') 
            addEditField(app, app.Simulation.mooring.mooringPos.lat, 5, 7, [], 'numeric', {@app.editFieldChanged, 'lat'}) % lat
            set(app.handleEditField(3), 'ValueDisplayFormat', '%.2f°') 
            addEditField(app, app.Simulation.mooring.hydrophoneDepth, 6, [4, 5], [], 'numeric', {@app.editFieldChanged, 'hydroDepth'}) % Hydro depth
            set(app.handleEditField(4), 'ValueDisplayFormat', '%.1f m') 
            % Noise
            addEditField(app, app.Simulation.noiseEnvironment.noiseLevel, 13, [4, 5], [], 'numeric', {@app.editFieldChanged, 'noiseLevel'}) % Hydro depth
            set(app.handleEditField(5), 'ValueDisplayFormat', '%d dB') 
            % Simulation 
            addEditField(app, abs(app.Simulation.listAz(2)-app.Simulation.listAz(1)), 17, [4, 5], [], 'numeric', {@app.editFieldChanged, 'AzResolution'}) % Hydro depth
            set(app.handleEditField(6), 'ValueDisplayFormat', '%.1f°') 

            %%% Drop down %%%
            % Bathymetry 
            addDropDown(app, {'GEBCO2021', 'Userfile'}, app.Simulation.bathyEnvironment.source, 2, [4, 7], @app.bathySourceChanged) % Auto loaded bathy 
            % Hydrophone
            addDropDown(app, app.Simulation.availableDetectors, app.Simulation.detector.name, 7, [4, 7], @app.detectorChanged)
            % Specie
            addDropDown(app, app.Simulation.availableSources, app.marineMammalName, 10, [4, 7], @app.specieChanged)
            % Noise level model
            addDropDown(app, {'Derived from recording', 'Derived from Wenz model', 'Input value'}, app.Simulation.noiseEnvironment.computingMethod, 12, [4, 7], @app.noiseOptionChanged)
             % Sediment
            addDropDown(app, app.Simulation.availableSediments, app.sedimentType, 15, [4, 7], @app.sedimentTypeChanged)
            % Detection range 
            addDropDown(app, app.Simulation.availableDRThreshold, app.Simulation.detectionRangeThreshold, 20, [4, 7], @app.detectionRangeThresholdChanged) % criterion 
            addDropDown(app, app.Simulation.availableOffAxisDistribution, app.Simulation.offAxisDistribution, 21, [4, 7], @app.offAxisDistributionChanged) % Off-axis distribution  
            addDropDown(app, app.Simulation.availableOffAxisAttenuation, app.Simulation.offAxisAttenuation, 22, [4, 7], @app.offAxisAttenuationChanged) % Off-axis distribution  

            %%% Buttons %%%
            % Edit hydrophone
            addButton(app, 'Edit properties', 7, 9, @app.editDetectorProperties)
            % Edit specie 
            addButton(app, 'Edit properties', 10, 9, @app.editMarineMammalProperties)
            % Edit noise level 
            addButton(app, 'Edit properties', 12, 9, @app.editNoiseLevelPorperties)
            % Edit sediment
            addButton(app, 'Edit properties', 15, 9, @app.editSedimentProperties)
            
            % Advanced settings 
            addButton(app, 'Advanced simulation settings', 18, [4, 9], @app.advancedSettings)
            % Save settings 
            addButton(app, 'Close', 24, [4, 7], @app.closeUI)
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
                app.subWindows{end+1} = selectBathymetryUI(app.Simulation);
            end
        end
        
        function deployementDateChanged(app, hObject, evendData, moment)
            switch moment
                case 'start'
                    app.Simulation.mooring.deploymentDate.startDate = hObject.Value;
                case 'stop'
                    app.Simulation.mooring.deploymentDate.stopDate = hObject.Value;
            end
        end
        
        function specieChanged(app, hObject, eventData)
            switch hObject.Value
                case 'Common dolphin'
                    app.Simulation.marineMammal = CommonDolphin;
                case 'Bottlenose dolphin'
                    app.Simulation.marineMammal = BottlenoseDolphin;
                case 'Porpoise'
                    app.Simulation.marineMammal = Porpoise;
                case 'New custom source'
                    app.Simulation.marineMammal = MarineMammal;
                    app.editMarineMammalProperties()
                otherwise
                    app.loadMarineMammal(hObject.Value)
            end
        end

        function loadMarineMammal(app, sourceName) % Load properties of a custom source 
            % Create a default mammal
            app.Simulation.marineMammal = MarineMammal;
            % Load custom properties 
            file = sprintf('%s.mat', sourceName);
            structMarineMammal= importdata(fullfile(app.Simulation.rootSources, file));
            props = fieldnames(structMarineMammal);
            for i=1:numel(props)
                property = props{i};
                app.Simulation.marineMammal.(property) = structMarineMammal.(property);
            end
            app.Simulation.marineMammal.setSignal()
            cd(app.Simulation.rootApp)
        end


        function detectorChanged(app, hObject, eventData)
            switch hObject.Value
                case 'CPOD'
                    app.Simulation.detector = CPOD;
                case 'FPOD'
                    app.Simulation.detector = FPOD;
               case 'SoundTrap'
                    app.Simulation.detector = SoundTrap;
                case 'New custom detector'
                    app.Simulation.detector = Detector;
                    app.editDetectorProperties()
                otherwise
                    app.loadDetector(hObject.Value)
            end
        end

        function loadDetector(app, detectorName) % Load properties of a custom detector 
            % Create a default detector
            app.Simulation.detector = Detector;
            % Load custom properties 
            file = sprintf('%s.mat', detectorName);
            structDetector= importdata(fullfile(app.Simulation.rootDetectors, file));
            props = fieldnames(structDetector);
            for i=1:numel(props)
                property = props{i};
                app.Simulation.detector.(property) = structDetector.(property);
            end
            cd(app.Simulation.rootApp)
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
                    if isempty(app.Simulation.oceanEnvironment)
                        oceanEnvironment = struct('temperatureC', 13, 'pH', 8.1, 'salinity', 34, 'depth', 15);
                    else
                        oceanEnvironment = app.Simulation.oceanEnvironment;
                    end
                    app.Simulation.noiseEnvironment.wenzModel = WenzModel(oceanEnvironment);
                    
                    app.subWindows{end+1} = selectWenzUI(app.Simulation, app.handleEditField(5));
                    bool = 0;
               case 'Input value'
                    % TODO: open window to input value 
                    bool = 1;
            end
            set(app.handleEditField(5), 'Editable', bool)
        end
        
        function sedimentTypeChanged(app, hObject, eventData)
            if strcmp(hObject.Value, 'New custom sediment')
                app.editSedimentProperties()
            elseif any(strcmp(hObject.Value, app.Simulation.availableSediments))
                app.Simulation.seabedEnvironment.sedimentType = hObject.Value;
                app.Simulation.seabedEnvironment.setBottom();
            else
                app.loadedSeabedEnvironment(hObject.Value);
            end
%             app.loadedSeabedEnvironment(hObject.Value);
%             app.Simulation.seabedEnvironment.sedimentType = hObject.Value;
        end 

        function loadSeabedEnvironment(app, sedimentType) % Load properties of a custom source 
            % Create a default seabed environment
            app.Simulation.seabedEnvironment = SeabedEnvironment;
            % Load custom properties 
            file = sprintf('%s.mat', sedimentType);
            structSeabedEnvironment= importdata(fullfile(app.Simulation.rootSources, file));
            props = fieldnames(structSeabedEnvironment);
            for i=1:numel(props)
                property = props{i};
                app.Simulation.seabedEnvironment.(property) = structSeabedEnvironment.(property);
            end
            cd(app.Simulation.rootApp)
        end

        function editFieldChanged(app, hObject, eventData, type)
            switch type 
                case 'mooringName'
                    app.Simulation.mooring.mooringName = regexprep(hObject.Value, ' ', ''); % Remove blanks

                case 'lon'
                    if hObject.Value < -180 || hObject.Value > 180
                        msg = {['Invalid longitude. ' ...
                            'Please enter a longitude between -180° and 180°.']};
                        assertDialogBox(app, 0, msg, 'Invalid longitude', 'warning')
                    end
                    app.Simulation.mooring.mooringPos.lon = hObject.Value;

                case 'lat'
                    if hObject.Value < -90 || hObject.Value > 90
                        msg = {['Invalid latitude. ' ...
                            'Please enter a latitude between -90° and 90°.']};
                        assertDialogBox(app, 0, msg, 'Invalid latitude', 'warning')
                    end
                    app.Simulation.mooring.mooringPos.lat = hObject.Value;


                case 'hydroDepth'
                    app.Simulation.mooring.hydrophoneDepth = hObject.Value;

                case 'noiseLevel'
                    if hObject.Value < 10|| hObject.Value > 210
                        msg = {['Invalid ambient noise level. ' ...
                            'Ambient noise level must belong to the interval [10, 210]dB. ' ...
                            'Noise level has been set to default value 75dB.']};
                        assertDialogBox(app, 0, msg, 'Invalid noise level', 'warning')
                        set(hObject, 'Value', 75)
                        app.Simulation.noiseEnvironment.noiseLevel = 75;
                    else
                        app.Simulation.noiseEnvironment.noiseLevel = hObject.Value;
                    end

                case 'AzResolution'
                    if hObject.Value < 0.1 || hObject.Value > 90
                        msg = {['Invalid azimuth resolution. ' ...
                            'Azimuth resolution must belong to the interval [0.1, 90]°. ' ...
                            'Resolution has been set to default value 5°.']};
                        assertDialogBox(app, 0, msg, 'Invalid azimuth resolution', 'warning')
                        set(hObject, 'Value', 5)
                        app.Simulation.listAz = 0.1:5:360.1;
                    else
                        app.Simulation.listAz = 0.1:hObject.Value:360.1;
                    end
            end
        end

        function editDetectorProperties(app, hObject, eventData)
            app.subWindows{end+1} = editDetectorUI(app.Simulation, app.handleDropDown(2));
        end

        function editMarineMammalProperties(app, hOject, eventData)
            app.subWindows{end+1} = editMarineMammalUI(app.Simulation, app.handleDropDown(3));        
        end

        function editSedimentProperties(app, hObject, eventData)
            app.subWindows{end+1} = editSeabedEnvironmentUI(app.Simulation, app.handleDropDown(5));
        end

        function detectionRangeThresholdChanged(app, hObject, eventData)
            app.Simulation.detectionRangeThreshold = hObject.Value;
        end
        
        function offAxisDistributionChanged(app, hObject, eventData)
            app.Simulation.offAxisDistribution = hObject.Value;
        end

        function offAxisAttenuationChanged(app, hObject, eventData)
            app.Simulation.offAxisAttenuation = hObject.Value;
        end

        function editNoiseLevelPorperties(app, hObject, eventData)
            switch get(app.handleDropDown(4), 'Value')
                case 'Derived from recording'
                    if isempty(app.Simulation.noiseEnvironment.recording)
                        app.Simulation.noiseEnvironment.recording = Recording(app.Simulation.marineMammal.centroidFrequency); 
                    end
                    app.subWindows{end+1} = selectRecordingUI(app.Simulation, app.handleEditField(5));
                case 'Derived from Wenz model'
                    if isempty(app.Simulation.noiseEnvironment.wenzModel)
                        app.Simulation.noiseEnvironment.wenzModel = WenzModel; 
                    end
                    app.subWindows{end+1} = selectWenzUI(app.Simulation, app.handleEditField(5));
                case 'Input value'
                    msg = {'No editable properties for "Input value" option'};
                    assertDialogBox(app, 0, msg, 'Edit properties failed', 'info')
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
        
        function closeUI(app, hObject, eventData)
            % Check user choices 
            bool = app.checkAll();
            if bool 
                % Close UI
                delete(app.Figure)
            else 
                return 
            end
        end

        function sedimentType = get.sedimentType(app)
            if ~any(strcmp(app.Simulation.availableSediments, app.Simulation.seabedEnvironment.sedimentType))
                sedimentType = 'New custom sediment';
            else
                sedimentType = app.Simulation.seabedEnvironment.sedimentType;
            end
        end


        function name = get.marineMammalName(app)
            if ~any(strcmp(app.Simulation.availableSources, app.Simulation.marineMammal.name))
                name = 'New custom source';
            else
                name = app.Simulation.marineMammal.name;
            end
        end
    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end
    end 

    %% Set methods 
    methods 
    end

    %% Check functions 
    % Functions to ensure all parameters are fitting with the program
    % expectations 
    methods
        function bool = checkBathyEnvironment(app)
            [bool, msg] = app.Simulation.bathyEnvironment.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Bathymetry environment warning', 'warning')
        end

        function bool = checkNoiseEnvironment(app)
            [bool, msg] = app.Simulation.bathyEnvironment.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Bathymetry environment failed', 'warning')
            % Information to user when using CPOD detector 
            if any(strcmp(app.Simulation.detector.name, {'CPOD', 'FPOD'}))
                msg = {sprintf(['You have selected a %s detector. ' ...
                    'Please note that as no information is available on ' ...
                    'the way ambient noise level influences CPOD and FPOD detections, ' ...
                    'noise level will not be taken in account to derive detection probability.'],...
                    app.Simulation.detector.name)};
                assertDialogBox(app, 0, msg, 'Noise level information', 'info')
            end
        end


        function bool = checkMooring(app)
            [bool, msg] = app.Simulation.mooring.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Mooring environment warning', 'warning')
        end


        function bool = checkDetector(app)
            [bool, msg] = app.Simulation.detector.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Bellhop environment warning', 'warning')
        end


        function bool = checkMarineMammal(app)
            [bool, msg] = app.Simulation.marineMammal.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Marine mammal warning', 'warning')
        end

        
        function bool = checkBellhopParameters(app)
            [bool, msg] = app.Simulation.bellhopEnvironment.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Bellhop environment warning', 'warning')
        end

        function bool = checkAll(app)
            b1 = app.checkBathyEnvironment();
            b2 = app.checkNoiseEnvironment();
            b3 = app.checkMooring();
            b4 = app.checkDetector();
            b5 = app.checkMarineMammal();
            b6 = app.checkBellhopParameters();
            bool = b1 & b2 & b3 & b4 & b5 & b6; % Assert everything is allright
        end
    end
    
end