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
                            'WindowStyle', 'normal', ...
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
            app.GridLayout.ColumnWidth{8} = 50;
            app.GridLayout.ColumnWidth{9} = 50;
            app.GridLayout.ColumnWidth{10} = 5;
            app.GridLayout.ColumnWidth{11} = 110;

            app.GridLayout.RowHeight{15} = 5;
            app.GridLayout.RowHeight{16} = 30;
            app.GridLayout.RowHeight{17} = 5;
            app.GridLayout.RowHeight{18} = 30;

            % Labels 
            % Bathymetry 
            app.addLabel('Bathymetry', 1, [1, 2], 'title')
            app.addLabel('File', 2, 2, 'text')
            app.addLabel('Reference Frame', 3, 2, 'text')
            app.addLabel('Resolution', 4, 2, 'text')
            app.addLabel('m', 4, 6, 'text')
            % Mooring
            app.addLabel('Mooring', 5, [1, 2], 'title')
            app.addLabel('Name', 6, 2, 'text')
            app.addLabel('Position', 7, 2, 'text')
            app.addLabel('Hydrophone Depth', 8, 2, 'text')
            hydrophoneDepthTooltip = ['Hydrophone Depth is counted positive ',...
                                'from surface toward bottom. You can also set ', ...
                                'negative depth to reference an altitude over the seabed.'];
            app.addLabel('m', 8, [6, 11], 'text', 'left', hydrophoneDepthTooltip)
            app.addLabel(app.MooringPosLabel(1), 7, 4, 'text', 'right')
            app.addLabel(app.MooringPosLabel(2), 7, 6, 'text', 'right')
            app.addLabel(app.MooringPosLabel(3), 7, 8, 'text', 'right')
            % Marine mammal 
            app.addLabel('Marine mammal', 9, [1, 2], 'title')
            app.addLabel('Specie', 10, 2, 'text')
            % Detector
            app.addLabel('Equipment', 11, [1, 2], 'title')
            app.addLabel('Hydrophone', 12, 2, 'text')
            % Noise level 
            app.addLabel('Noise level', 13, [1, 2], 'title')
            app.addLabel('Computing model', 14, 2, 'text')

            % Edit field
            % Bathy
            app.addEditField(app.Simulation.bathyEnvironment.bathyFile, 2, [4, 9], '', 'text') % Bathy file 
            app.addEditField(app.Simulation.bathyEnvironment.drBathy, 4, [4, 5], [], 'numeric', {@app.editFieldChanged, 'drBathy'}) % Bathy resolution 
            % Mooring
            app.addEditField(app.Simulation.mooring.mooringName, 6, [4, 9], 'Mooring name (name of the simulation)', 'text', {@app.editFieldChanged, 'mooringName'}) % Name
            app.addEditField(app.Simulation.mooring.mooringPos.lon, 7, 5, [], 'numeric', {@app.editFieldChanged, 'XPos'}) % X Pos 
            app.addEditField(app.Simulation.mooring.mooringPos.lat, 7, 7, [], 'numeric', {@app.editFieldChanged, 'YPos'}) % Y Pos 
            app.addEditField(app.Simulation.mooring.mooringPos.hgt, 7, 9, [], 'numeric', {@app.editFieldChanged, 'ZPos'}) % Z Pos 
            app.addEditField(app.Simulation.mooring.hydrophoneDepth, 8, [4, 5], [], 'numeric', {@app.editFieldChanged, 'hydroDepth'}) % Hydro depth
            
            % Drop down 
            % Reference frame
%             app.addDropDown({'WGS84', 'ENU', 'UTM'}, app.Simulation.bathyEnvironment.inputSRC, 3, [4, 7], @app.referenceFrameChanged)
            app.addDropDown({'WGS84'}, app.Simulation.bathyEnvironment.inputSRC, 3, [4, 7], @app.referenceFrameChanged) % Update 20/01/2022 to limit the input crs to WGS84

            % Specie
            app.addDropDown({'Common bottlenose dolphin', 'Porpoise'}, app.Simulation.marineMammal.name, 10, [4, 9], @app.specieChanged)
            % Hydrophone
            app.addDropDown({'CPOD', 'FPOD', 'SoundTrap'}, app.Simulation.detector.name, 12, [4, 7], @app.detectorChanged)
            % Noise level model
            app.addDropDown({'Computed from data', 'basic model'}, 'basic model', 14, [4, 7], @app.noiseLevelChanged)

            % Buttons
            % Bathy file
            app.addButton('Select file', 2, 11, @app.selectBathyFile)
            % Edit specie 
            app.addButton('Edit properties', 10, 11, @app.editMarinneMammalProperties)
            % Edit hydrophone
            app.addButton('Edit properties', 12, 11, @app.editDetectorProperties)
            % Edit noise level 
            app.addButton('Edit properties', 14, 11, @app.editNoiseLevelPorperties)
            
            % Advanced settings 
            app.addButton('Advanced simulation settings', 16, [9, 11], @app.advancedSettings)
            % Save settings 
            app.addButton('Save settings', 18, [5, 8], @app.saveSettings)
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

        function RFChanged()
            % Update mooring position labels 
            % if WGS84 -> lon, lat, hgt 
            % elseif ENU -> X, Y, Z
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
                % Copy to input folder 
%                 copy(fullfile(path, file), fullfile(app.Simulation.rootSaveInput, file))
                app.Simulation.bathyFileType = 'CSV';
                
            elseif indx == 2 % File is a netcdf
%                 fNETCDF = fullfile(path, file);
%                 fileCSV = [file(1:end-2), 'csv'];
%                 fCSV = fullfile(app.Simulation.rootSaveInput, fileCSV);
                % Convert file to csv and save it in the inout folder   
%                 bathyNETCDFtoCSV(fNETCDF, fCSV)
                app.Simulation.bathyFileType = 'NETCDF';
            end 

            app.Simulation.bathyEnvironment.rootBathy = path;
            app.Simulation.bathyEnvironment.bathyFile = file;
            
            set(app.handleEditField(1), 'Value', file)
        end
        
        function referenceFrameChanged(app, hObject, eventData)
            newRefFrame =  get(app.handleDropDown(1), 'Value');
            switch newRefFrame
                case 'WGS84'
                    app.MooringPosLabel = {'lat(DD)', 'lon(DD)', 'hgt(m)'};
                case 'ENU'
                    app.MooringPosLabel = {'E(m)', 'N(m)', 'U(m)'};
                otherwise
                    app.MooringPosLabel = {'X(m)', 'Y(m)', 'Z(m)'};
            end
            app.Simulation.bathyEnvironment.inputSRC = newRefFrame;
        end

        function specieChanged(app, hObject, eventData)
            switch get(app.handleDropDown(2), 'Value')
                case 'Common bottlenose dolphin'
                    newSpecie = CommonBottlenoseDolphin;
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
                case 'CPOD'
                    newDetector = CPOD;
                case 'FPOD'
                    newDetector = FPOD;
               case 'SoundTrap'
                    newDetector = SoundTrap;
            end
%             app.Simulation.noise
        end

        function editFieldChanged(app, hObject, eventData, type)
            switch type 
                case 'drBathy'
                    app.Simulation.bathyEnvironment.drBathy = hObject.Value;
                case 'mooringName'
                    app.Simulation.mooring.mooringName = regexprep(hObject.Value, ' ', ''); % Remove blanks
                case 'XPos'
                    app.Simulation.mooring.mooringPos.lat = hObject.Value;
                case 'YPos'
                    app.Simulation.mooring.mooringPos.lon = hObject.Value;
                case 'ZPos'
                    app.Simulation.mooring.mooringPos.hgt = hObject.Value;
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
            advancedSettingsUI(app.Simulation)
        end

        function saveSettings(app, hObject, eventData)
            % Open editUI
            close(app.Figure)
        end
    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function moorPosLabels = get.MooringPosLabel(app)
            switch app.Simulation.bathyEnvironment.inputSRC
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
end