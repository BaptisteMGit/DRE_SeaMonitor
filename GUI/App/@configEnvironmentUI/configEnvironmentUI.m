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
            titleLabelFont = getLabelFont(app, 'Title');
            textLabelFont = getLabelFont(app, 'Text');

            % Bathymetry 
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Bathymetry', 'LayoutPosition', struct('nRow', 1, 'nCol', [1, 2]), 'Font', titleLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Source', 'LayoutPosition', struct('nRow', 2, 'nCol', 2), 'Font', textLabelFont})

            % Mooring
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Equipment', 'LayoutPosition', struct('nRow', 3, 'nCol', [1, 2]), 'Font', titleLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Name of the study', 'LayoutPosition', struct('nRow', 4, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Position', 'LayoutPosition', struct('nRow', 5, 'nCol', 2), 'Font', textLabelFont})

            hydrophoneDepthTooltip = ['Hydrophone depth is counted positive ',...
                    'from surface toward bottom. You can also set ', ...
                    'negative depth to reference an altitude over the seabed.'];
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Hydrophone depth', 'LayoutPosition', struct('nRow', 6, 'nCol', 2), ...
                'Font', textLabelFont, 'Tooltip', hydrophoneDepthTooltip})

            addLabel(app, {'Parent', app.GridLayout, 'Text', 'lon (dd)', 'LayoutPosition', struct('nRow', 5, 'nCol', 4), 'Font', textLabelFont, 'HorizontalAlignment', 'right'})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'lat (dd)', 'LayoutPosition', struct('nRow', 5, 'nCol', 6), 'Font', textLabelFont, 'HorizontalAlignment', 'right'})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Hydrophone', 'LayoutPosition', struct('nRow', 7, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Deployement (start-stop)', 'LayoutPosition', struct('nRow', 8, 'nCol', 2), 'Font', textLabelFont})
            
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
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Marine mammal', 'LayoutPosition', struct('nRow', 9, 'nCol', [1, 2]), 'Font', titleLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Specie', 'LayoutPosition', struct('nRow', 10, 'nCol', 2), 'Font', textLabelFont})

            % Noise level 
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Ambient noise', 'LayoutPosition', struct('nRow', 11, 'nCol', [1, 2]), 'Font', titleLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Option', 'LayoutPosition', struct('nRow', 12, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Noise level', 'LayoutPosition', struct('nRow', 13, 'nCol', 2), 'Font', textLabelFont})
            
            % Seabed 
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Seabed', 'LayoutPosition', struct('nRow', 14, 'nCol', [1, 2]), 'Font', titleLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Sediment', 'LayoutPosition', struct('nRow', 15, 'nCol', 2), 'Font', textLabelFont})

            % Bellhop 
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Simulation parameters', 'LayoutPosition', struct('nRow', 16, 'nCol', [1, 2]), 'Font', titleLabelFont})

            azimuthResolutionTooltip = ['The azimuth resolution is the angle between to consecutive profiles.',...
                'Please note that reducing the resolution increases drastically the computing time.'];
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Azimuth resolution', 'LayoutPosition', struct('nRow', 17, 'nCol', 2), ...
                'Font', textLabelFont, 'Tooltip', azimuthResolutionTooltip})
            
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Bellhop settings', 'LayoutPosition', struct('nRow', 18, 'nCol', 2), 'Font', textLabelFont})

            % Detection function 
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Detection range', 'LayoutPosition', struct('nRow', 19, 'nCol', [1, 2]), 'Font', titleLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Threshold', 'LayoutPosition', struct('nRow', 20, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Off-axis distribution', 'LayoutPosition', struct('nRow', 21, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Off-axis attenuation', 'LayoutPosition', struct('nRow', 22, 'nCol', 2), 'Font', textLabelFont})

            %%% Edit field %%%
            % Mooring
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'text', 'Value', app.Simulation.mooring.mooringName, 'Placeholder', 'Name of the simulation', ...
                'LayoutPosition', struct('nRow', 4, 'nCol', [4, 7]), 'ValueChangedFcn', {@app.editFieldChanged, 'mooringName'}})
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.mooring.mooringPos.lon, ...
                'LayoutPosition', struct('nRow', 5, 'nCol', 5), 'ValueChangedFcn', {@app.editFieldChanged, 'lon'}, 'ValueDisplayFormat', '%.2f°'})
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.mooring.mooringPos.lat, ...
                'LayoutPosition', struct('nRow', 5, 'nCol', 7), 'ValueChangedFcn', {@app.editFieldChanged, 'lat'}, 'ValueDisplayFormat', '%.2f°'})
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.mooring.hydrophoneDepth, ...
                'LayoutPosition', struct('nRow', 6, 'nCol', [4, 5]), 'ValueChangedFcn', {@app.editFieldChanged, 'hydroDepth'}, 'ValueDisplayFormat', '%.1f m'})
            % Noise
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.noiseEnvironment.noiseLevel, ...
                'LayoutPosition', struct('nRow', 13, 'nCol', [4, 5]), 'ValueChangedFcn', {@app.editFieldChanged, 'noiseLevel'}, 'ValueDisplayFormat', '%d dB'})
            % Simulation 
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.bearingStep, ...
                'LayoutPosition', struct('nRow', 17, 'nCol', [4, 5]), 'ValueChangedFcn', {@app.editFieldChanged, 'AzResolution'}, 'ValueDisplayFormat', '%.1f°'})

            %%% Drop down %%%
            % Bathymetry 
            addDropDown(app, {'Parent', app.GridLayout, 'Items', {'GEBCO2021', 'Userfile'}, 'Value', app.Simulation.bathyEnvironment.source, ...
                'ValueChangedFcn', @app.bathySourceChanged, 'LayoutPosition',  struct('nRow', 2, 'nCol', [4, 7])})
            % Hydrophone
            addDropDown(app, {'Parent', app.GridLayout, 'Items', app.Simulation.availableDetectors, 'Value', app.Simulation.detector.name, ...
                'ValueChangedFcn', @app.detectorChanged, 'LayoutPosition',  struct('nRow', 7, 'nCol', [4, 7])})
            % Specie
            addDropDown(app, {'Parent', app.GridLayout, 'Items', app.Simulation.availableSources, 'Value', app.marineMammalName, ...
                'ValueChangedFcn', @app.specieChanged, 'LayoutPosition',  struct('nRow', 10, 'nCol', [4, 7])})
            % Noise level model
            addDropDown(app, {'Parent', app.GridLayout, 'Items', {'Derived from recording', 'Derived from Wenz model', 'Input value'}, 'Value', app.Simulation.noiseEnvironment.computingMethod, ...
                'ValueChangedFcn', @app.noiseOptionChanged, 'LayoutPosition',  struct('nRow', 12, 'nCol', [4, 7])})
             % Sediment
             addDropDown(app, {'Parent', app.GridLayout, 'Items', app.Simulation.availableSediments, 'Value', app.sedimentType, ...
                'ValueChangedFcn', @app.sedimentTypeChanged, 'LayoutPosition',  struct('nRow', 15, 'nCol', [4, 7])})
            % Detection range 
            addDropDown(app, {'Parent', app.GridLayout, 'Items', app.Simulation.availableDRThreshold, 'Value', app.Simulation.detectionRangeThreshold, ...
                'ValueChangedFcn', @app.detectionRangeThresholdChanged, 'LayoutPosition',  struct('nRow', 20, 'nCol', [4, 7])})
            addDropDown(app, {'Parent', app.GridLayout, 'Items', app.Simulation.availableOffAxisDistribution, 'Value', app.Simulation.offAxisDistribution, ...
                'ValueChangedFcn', @app.offAxisDistributionChanged, 'LayoutPosition',  struct('nRow', 21, 'nCol', [4, 7])})
            addDropDown(app, {'Parent', app.GridLayout, 'Items', app.Simulation.availableOffAxisAttenuation, 'Value', app.Simulation.offAxisAttenuation, ...
                'ValueChangedFcn', @app.offAxisAttenuationChanged, 'LayoutPosition',  struct('nRow', 22, 'nCol', [4, 7])})

            %%% Buttons %%%
            % Edit hydrophone
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Edit properties', 'ButtonPushedFcn', @app.editDetectorProperties, 'LayoutPosition', struct('nRow', 7, 'nCol', 9)})
            % Edit specie 
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Edit properties', 'ButtonPushedFcn', @app.editMarineMammalProperties, 'LayoutPosition', struct('nRow', 10, 'nCol', 9)})
            % Edit noise level 
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Edit properties', 'ButtonPushedFcn', @app.editNoiseLevelPorperties, 'LayoutPosition', struct('nRow', 12, 'nCol', 9)})
            % Edit sediment
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Edit properties', 'ButtonPushedFcn', @app.editSedimentProperties, 'LayoutPosition', struct('nRow', 15, 'nCol', 9)})
            
            % Advanced settings 
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Advanced simulation settings', 'ButtonPushedFcn', @app.advancedSettings, 'LayoutPosition', struct('nRow', 18, 'nCol', [4, 9])})
            % Save settings 
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Close', 'ButtonPushedFcn', @app.closeUI, 'LayoutPosition', struct('nRow', 24, 'nCol', [4, 7])})
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