classdef selectRecordingUI < handle
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
        Name = "Select recording";
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
        Height = 225;
        % Number of components 
        glNRow = 6;
        glNCol = 8;
        
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
        function app = selectRecordingUI(simulation)
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
            app.GridLayout.ColumnWidth{2} = 140;
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 75;
            app.GridLayout.ColumnWidth{5} = 200;
            app.GridLayout.ColumnWidth{6} = 75;
            app.GridLayout.ColumnWidth{7} = 5;
            app.GridLayout.ColumnWidth{8} = 90;

%             app.GridLayout.RowHeight{1} = 10;
%             app.GridLayout.RowHeight{2} = 90;
            app.GridLayout.RowHeight{5} = 5;
%             app.GridLayout.RowHeight{4} = 50;

            % Labels 
            addLabel(app, 'Ambient noise', 1, [1, 2], 'title')
            addLabel(app, 'Recording', 2, 2, 'text')
            addLabel(app, 'Centroid frequency', 3, 2, 'text')
            addLabel(app, 'Hz', 3, 5, 'text')
            addLabel(app, 'Bandwidth', 4, 2, 'text')


            % Edit field
            % Recording
            addEditField(app, app.Simulation.noiseEnvironment.recordingFile, 2, [4, 6], 'Filename.wav', 'text') % recording file 
            addEditField(app, app.Simulation.noiseEnvironment.centroidFrequency, 3, 4, 100000, 'numeric') % recording file 

            % Drop down 
            % Bandwidth
            addDropDown(app, {'1/3 Octave band', '1 Octave band', 'min/max'}, app.Simulation.noiseEnvironment.bandwidthStyle, 4, [4, 6], @app.bandwidthStyleChanged) % Auto loaded bathy

            % Buttons
            addButton(app, 'Select file', 2, 8, @app.selectRecording)

            % Save settings 
            addButton(app, 'Compute noise level', 6, 5, @app.computeNoiseLevel)
        end
    end
    
    %% Callback functions 
    methods

        function selectRecording(app, hObject, eventData)
            [file, path, indx] = uigetfile({'*.wav', 'Sound file'}, ...
                                            'Select a file');
 
            app.Simulation.noiseEnvironment.recordingFile = fullfile(path, file);          
            set(app.handleEditField(1), 'Value', file)
        end
        
        function closeWindowCallback(app, hObject, eventData)
            closeWindowCallback(app.subWindows, hObject, eventData)
        end
        
        function bool = checkNoiseEnvironment(app)
            [bool, msg] = app.Simulation.noiseEnvironment.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Bathymetry environment failed', 'warning')
        end

        function computeNoiseLevel(app, hObject, eventData)
            bool = app.checkNoiseEnvironment();
            if bool
                d = uiprogressdlg(app.Figure,'Title','Please Wait',...
                                'Message','Estimating ambient noise level...');
                app.Simulation.noiseEnvironment.computeFromRecording()
                close(d) 
                
                % Close UI
                close(app.Figure)
            end
        end

        function checkBathyEnvironment(app)
            [bool, msg] = app.Simulation.bathyEnvironment.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Bathymetry environment warning', 'warning')
        end

        function bandwidthStyleChanged(app)
            
        end
    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end
    end 
end