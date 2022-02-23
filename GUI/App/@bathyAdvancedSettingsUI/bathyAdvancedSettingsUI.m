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
            addLabel(app, 'Bathymetry', 1, [1, 2], 'title')
            addLabel(app, 'File', 2, 2, 'text')
            addLabel(app, 'Coordinate Reference System', 3, 2, 'text')
            addLabel(app, 'Resolution of interpolated profiles', 4, 2, 'text')
            addLabel(app, 'm', 4, 5, 'text')
           
            % Edit field
            % Bathy
            addEditField(app, app.Simulation.bathyEnvironment.bathyFile, 2, [4, 6], 'Bathymetry file (csv, netdcf)', 'text') % Bathy file 
            addEditField(app, app.Simulation.bathyEnvironment.drBathy, 4, 4, [], 'numeric', {@app.editFieldChanged, 'drBathy'}) % Bathy resolution 
           
            % Drop down 
            % CRS
            addDropDown(app, {'WGS84'}, app.Simulation.bathyEnvironment.inputCRS, 3, [4, 5], @app.referenceFrameChanged) % Update 20/01/2022 to limit the input crs to WGS84

            % Buttons
            % Bathy file
            addButton(app, 'Select file', 2, 8, @app.selectBathyFile)

            % Save settings 
            addButton(app, 'Save settings', 6, [4, 6], @app.saveSettings)
        end
    end

    %% Callback functions 
    methods
        function selectBathyFile(app, hObject, eventData)
            [file, path, indx] = uigetfile({'*.nc', 'NETCDF'; ...
                                            '*.csv;*.txt','Text File'}, ...
                                            'Select a file');
            if ~isnumeric(file) % Check if a file has been selected 
                if indx == 1 % File is a csv
                    app.Simulation.bathyEnvironment.bathyFileType = 'CSV';                
                elseif indx == 2 % File is a netcdf
                    app.Simulation.bathyEnvironment.bathyFileType = 'NETCDF';
                end 
     
                app.Simulation.bathyEnvironment.rootBathy = path;
                app.Simulation.bathyEnvironment.bathyFile = file;
                
                set(app.handleEditField(1), 'Value', file)
            end
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
            end
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