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
            app.addLabel('Bathymetry', 1, [1, 2], 'title')
            app.addLabel('Source', 2, 2, 'text')
%             app.addLabel('Reference Frame', 3, 2, 'text')
%             app.addLabel('Resolution', 4, 2, 'text')
%             app.addLabel('m', 4, 6, 'text')
            % Mooring
            app.addLabel('Mooring', 3, [1, 2], 'title')
            app.addLabel('Name', 4, 2, 'text')
            app.addLabel('Position', 5, 2, 'text')
            app.addLabel('Hydrophone Depth', 6, 2, 'text')
            hydrophoneDepthTooltip = ['Hydrophone Depth is counted positive ',...
                                'from surface toward bottom. You can also set ', ...
                                'negative depth to reference an altitude over the seabed.'];
            app.addLabel('m', 6, [6, 11], 'text', 'left', hydrophoneDepthTooltip)
            app.addLabel(app.MooringPosLabel(1), 5, 4, 'text', 'right')
            app.addLabel(app.MooringPosLabel(2), 5, 6, 'text', 'right')
            % Marine mammal 
            app.addLabel('Marine mammal', 7, [1, 2], 'title')
            app.addLabel('Specie', 8, 2, 'text')
            % Detector
            app.addLabel('Equipment', 9, [1, 2], 'title')
            app.addLabel('Hydrophone', 10, 2, 'text')
            % Noise level 
            app.addLabel('Noise level', 11, [1, 2], 'title')
            app.addLabel('Computing model', 12, 2, 'text')
            % Bellhop 
            app.addLabel('Bellhop parameters', 13, [1, 2], 'title')

            % Edit field
            % Mooring
            app.addEditField(app.Simulation.mooring.mooringName, 4, [4, 7], 'Mooring name (name of the simulation)', 'text', {@app.editFieldChanged, 'mooringName'}) % Name
            app.addEditField(app.Simulation.mooring.mooringPos.lon, 5, 5, [], 'numeric', {@app.editFieldChanged, 'XPos'}) % X Pos 
            app.addEditField(app.Simulation.mooring.mooringPos.lat, 5, 7, [], 'numeric', {@app.editFieldChanged, 'YPos'}) % Y Pos 
            app.addEditField(app.Simulation.mooring.hydrophoneDepth, 6, [4, 5], [], 'numeric', {@app.editFieldChanged, 'hydroDepth'}) % Hydro depth
            
            % Drop down 
            % Bathymetry 
            app.addDropDown({'GEBCO2021', 'Userfile'}, app.Simulation.bathyEnvironment.source, 2, [4, 7], @app.bathySourceChanged) % Auto loaded bathy 

            % Specie
            app.addDropDown({'Common bottlenose dolphin', 'Porpoise'}, app.Simulation.marineMammal.name, 8, [4, 7], @app.specieChanged)
            % Hydrophone
            app.addDropDown({'CPOD', 'FPOD', 'SoundTrap'}, app.Simulation.detector.name, 10, [4, 7], @app.detectorChanged)
            % Noise level model
            app.addDropDown({'Measure from recording', 'Model', 'Input value'}, 'Measure from recording', 12, [4, 7], @app.noiseLevelChanged)

            % Buttons
            % Edit specie 
            app.addButton('Edit properties', 8, 9, @app.editMarinneMammalProperties)
            % Edit hydrophone
            app.addButton('Edit properties', 10, 9, @app.editDetectorProperties)
            % Edit noise level 
            app.addButton('Edit properties', 12, 9, @app.editNoiseLevelPorperties)
            
            % Advanced settings 
            app.addButton('Advanced simulation settings', 14, [4, 9], @app.advancedSettings)
            % Save settings 
            app.addButton('Save settings', 16, [5, 8], @app.saveSettings)
        end
    end
    
    %% Set up methods 
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

       function addButton(app, name, nRow, nCol, callbackFunction)
            button = uibutton(app.GridLayout, ...
                        'Text', name, ...
                        'ButtonPushedFcn', callbackFunction);
            % Set edit field position in grid layout 
            button.Layout.Row = nRow;
            button.Layout.Column = nCol;
            app.handleButton = [app.handleButton, button];
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

        function selectBathyFile(app, hObject, eventData)
            [file, path, indx] = uigetfile({'*.nc', 'NETCDF'; ...
                                            '*.csv;*.txt','Text File'}, ...
                                            'Select a File');
            if indx == 1 % File is a csv
                app.Simulation.bathyFileType = 'CSV';                
            elseif indx == 2 % File is a netcdf
                app.Simulation.bathyFileType = 'NETCDF';
            end 

            app.Simulation.bathyEnvironment.rootBathy = path;
            app.Simulation.bathyEnvironment.bathyFile = file;
            
            set(app.handleEditField(1), 'Value', file)
        end
        
        function bathySourceChanged(app, hObject, eventData)
            newSource =  get(app.handleDropDown(1), 'Value');
            app.Simulation.bathyEnvironment.source = newSource;
            if strcmp(newSource, 'Userfile')
                app.subWindows{end+1} = bathyAdvancedSettingsUI(app.Simulation);
            end
        end

        function specieChanged(app, hObject, eventData)
            switch get(app.handleDropDown(2), 'Value')
                case 'Common bottlenose dolphin'
                    newSpecie = CommonDolphin;
                case 'Porpoise'
                    newSpecie = Porpoise;
            end
            app.Simulation.marineMammal = newSpecie;
        end

        function detectorChanged(app, hObject, eventData)
            switch get(app.handleDropDown(3), 'Value')
                case 'CPOD'
                    newDetector = CPOD;
                case 'FPOD'
                    newDetector = FPOD;
               case 'SoundTrap'
                    newDetector = SoundTrap;
            end
            app.Simulation.detector = newDetector;
        end

        function noiseLevelChanged(app, hObject, eventData)
            switch get(app.handleDropDown(3), 'Value')
                case 'Measure from recording'
                    % TODO: open recording window to select the file 
                case 'Model'
                    % TODO: compute with model 
               case 'Input value'
                    % TODO: open window to input value 
            end
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
        function assertDialogBox(app, cond, message, title, icon)
            % icon = 'error', 'warning', 'info'
            if ~cond
                for msg = message
                    uialert(app.Figure, message, title, 'Icon', icon);
                end
            end
        end

        function checkBathyEnvironment(app)
            [bool, msg] = app.Simulation.bathyEnvironment.checkParametersValidity;
            app.assertDialogBox(bool, msg, 'Bathymetry environment warning', 'warning')
        end

        function checkNoiseEnvironment(app)
%             [bool, msg] = app.Simulation.bathyEnvironment.checkParametersValidity;
%             app.assertDialogBox(bool, msg, 'Bathymetry environment failed', 'warning')
        end


        function checkMooring(app)
            [bool, msg] = app.Simulation.mooring.checkParametersValidity;
            app.assertDialogBox(bool, msg, 'Mooring environment warning', 'warning')
        end


        function checkDetector(app)
            
        end


        function checkMarineMammal(app)
            
        end

        
        function checkBellhopParameters(app)
            
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