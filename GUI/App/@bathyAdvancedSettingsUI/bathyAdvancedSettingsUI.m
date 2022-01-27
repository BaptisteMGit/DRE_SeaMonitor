classdef bathyAdvancedSettingsUI < handle
% bathyAdvancedSettingsUI: App window dedicated to the configuration of the
% bathymetry advanced settings environment 
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
        Name = "Bathymetry advanced settings";
    end 
    
    properties (Dependent)
        % Position of the main figure 
        fPosition 
        % Position of the labels for Mooring Positon 
        MooringPosLabel
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 900;
        Height = 200;
        % Number of components 
        glNRow = 6;
        glNCol = 11;
        
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
        function app = bathyAdvancedSettingsUI(simulation)
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
            app.GridLayout.ColumnWidth{2} = 210;
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 70;
            app.GridLayout.ColumnWidth{5} = 100;
            app.GridLayout.ColumnWidth{6} = 180;
            app.GridLayout.ColumnWidth{7} = 5;
            app.GridLayout.ColumnWidth{8} = 220;

            app.GridLayout.RowHeight{5} = 10;

            % Labels 
            % Bathymetry 
            app.addLabel('Bathymetry', 1, [1, 2], 'title')
            app.addLabel('File', 2, 2, 'text')
            app.addLabel('Coordinate Reference System', 3, 2, 'text')
            app.addLabel('Resolution of interpolated profiles', 4, 2, 'text')
            app.addLabel('m', 4, 5, 'text')
           
            % Edit field
            % Bathy
            app.addEditField(app.Simulation.bathyEnvironment.bathyFile, 2, [4, 6], '', 'text') % Bathy file 
            app.addEditField(app.Simulation.bathyEnvironment.drBathy, 4, 4, [], 'numeric', {@app.editFieldChanged, 'drBathy'}) % Bathy resolution 
           
            % Drop down 
            % CRS
            app.addDropDown({'WGS84'}, app.Simulation.bathyEnvironment.inputCRS, 3, [4, 5], @app.referenceFrameChanged) % Update 20/01/2022 to limit the input crs to WGS84

            % Buttons
            % Bathy file
            app.addButton('Select file', 2, 8, @app.selectBathyFile)

            % Save settings 
            app.addButton('Save settings', 6, [4, 6], @app.saveSettings)
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
                app.Simulation.bathyEnvironment.bathyFileType = 'CSV';                
            elseif indx == 2 % File is a netcdf
                app.Simulation.bathyEnvironment.bathyFileType = 'NETCDF';
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
            app.Simulation.bathyEnvironment.inputCRS = newRefFrame;
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


        function editDetectorProperties(app, hObject, eventData)
            % Open editUI
        end

        function editNoiseLevelPorperties(app, hObject, eventData)
            % Open editUI
        end

        
        function closeWindowCallback(app, hObject, eventData)
            closeWindowCallback(app.subWindows, hObject, eventData)
        end

        function saveSettings(app, hObject, eventData)
            % Close UI
            close(app.Figure)
        end

        function checkBathyEnvironment(app)
            [bool, msg] = app.Simulation.bathyEnvironment.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Bathymetry environment warning', 'warning')
        end
    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end
    end 
end