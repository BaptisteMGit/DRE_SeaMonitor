classdef selectRecordingUI < handle
% selectRecordingUI: App window to select a recording file from which to
% derive the ambient noise level. The sound file must be provided as a .wav
% file where there is no cues (signal from the studied marine mammal). 
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

        % frequency range
        fmin
        fmax
        % round coeff for frequency 
        roundCoeff
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 700;
        Height = 300;
        % Number of components 
        glNRow = 9;
        glNCol = 8;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 14;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';

        % Sub-windows 
        subWindows = {};
        
        % Handle to the noiseLevel edit field of the
        % configureEnvironementUI window to update the noise level value
        % once newly computed 
        nlEditFieldHandle
    end
    
    %% Constructor of the class 
    methods       
        function app = selectRecordingUI(simulation, nlEditFieldHandle)
            % Pass simulation handle 
            app.Simulation = simulation;
            % Handle to the edit field 
            app.nlEditFieldHandle = nlEditFieldHandle;
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
            
            % Grid Layout
            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 140;
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 125;
            app.GridLayout.ColumnWidth{5} = 100;
            app.GridLayout.ColumnWidth{6} = 125;
            app.GridLayout.ColumnWidth{7} = 5;
            app.GridLayout.ColumnWidth{8} = 90;

            app.GridLayout.RowHeight{8} = 5;

            % Labels 
            addLabel(app, 'Ambient noise', 1, [1, 2], 'title')
            addLabel(app, 'Recording', 2, 2, 'text')
            addLabel(app, 'Centroid frequency', 3, 2, 'text')
%             addLabel(app, 'Hz', 3, 5, 'text')

            addLabel(app, 'Bandwidth', 4, 2, 'text')
            addLabel(app, 'fMin', 5, 2, 'text')
            set(app.handleLabel(5), 'HorizontalAlignment', 'right')
            addLabel(app, 'fMax', 6, 2, 'text')
            set(app.handleLabel(6), 'HorizontalAlignment', 'right')

            addLabel(app, 'Calibration coefficient', 7, 2, 'text')

            % Edit field
            % Recording
            addEditField(app, app.Simulation.noiseEnvironment.recording.recordingFile, 2, [4, 6], 'Filename.wav', 'text', {@app.editFieldChanged, 'filename'}) % recording file 
            addEditField(app, app.Simulation.marineMammal.centroidFrequency, 3, 4, 100000, 'numeric', {@app.editFieldChanged, 'centroidFrequency'}) % Centroid frequency: must be the centroid frequency of the studied signal 
            set(app.handleEditField(2), 'ValueDisplayFormat', '%d Hz')

            addEditField(app, app.fmin, 5, 4, [], 'numeric', {@app.editFieldChanged, 'fmin'}) % fmin
            set(app.handleEditField(3), 'ValueDisplayFormat', '%d Hz')

            addEditField(app, app.fmax, 6, 4, [], 'numeric', {@app.editFieldChanged, 'fmax'}) % fmax
            set(app.handleEditField(4), 'ValueDisplayFormat', '%d Hz') 
            app.updateFrequencyRangeVisualAspect()
            
            addEditField(app, app.Simulation.noiseEnvironment.recording.calibrationCoefficient, 7, 4, [], 'numeric', {@app.editFieldChanged, 'calCoeff'}) % fmax

            % Drop down 
            % Bandwidth
            addDropDown(app, {'1/3 octave', '1 octave', 'ManuallyDefined'}, app.Simulation.noiseEnvironment.recording.bandwidthType, 4, [4, 6], @app.bandwidthTypeChanged) % Auto loaded bathy

            % Buttons
            addButton(app, 'Select file(s)', 2, 8, @app.selectRecording)

            % Save settings 
            addButton(app, 'Compute', 9, 5, @app.computeNoiseLevel)
        end
    end
    
    %% Callback functions 
    methods

        function selectRecording(app, hObject, eventData)
            [file, path, indx] = uigetfile({'*.wav', 'Sound file'}, ...
                                            'Select file(s)', ...
                                            'MultiSelect','on');
             if iscell(file)
                set(app.handleEditField(1), 'Value', file{1})
                app.Simulation.noiseEnvironment.recording.listRecordingFile = fullfile(path, file);  
            else
                set(app.handleEditField(1), 'Value', file)
                app.Simulation.noiseEnvironment.recording.listRecordingFile = fullfile(path, {file});  
            end
        end
        
        function closeWindowCallback(app, hObject, eventData)
            % Update edit field with new value 
            set(app.nlEditFieldHandle, 'Value', double(app.Simulation.noiseEnvironment.noiseLevel))
            closeWindowCallback(hObject, eventData)
        end
        

        function bool = checkRecording(app)
            % Blocking conditions 
            [bool, msg] = app.Simulation.noiseEnvironment.recording.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Recording warning', 'warning')
            
            % Check if centroid frequency is the same as the marine mammal
            % one. 
            if ~(app.Simulation.marineMammal.centroidFrequency == app.Simulation.noiseEnvironment.recording.centroidFrequency)
                message = sprintf(['Usually one should be interested in estimating the ambient noise level in the frequency band of interest.', ...
                    'You have selected a centroid frequency different from the centroid frequency of %s emmited by %s.', ...
                    'You should consider editing the centroid frequency either for the estimation of ambient noise ', ...
                    'level or for the studied signal associated to the specie of interest.'], ...
                    app.Simulation.marineMammal.signal.name, app.Simulation.marineMammal.name);
                uialert(app.Figure, message, 'Centroid frequency info', 'Icon', 'info')
            end
        end


        function computeNoiseLevel(app, hObject, eventData)
            bool = app.checkRecording();
            if bool
                d = uiprogressdlg(app.Figure,'Title','Please Wait',...
                                'Message','Estimating ambient noise level...', ...
                                'ShowPercentage', 'on');
                app.Simulation.noiseEnvironment.computeNoiseLevel(d)
                close(d) 
                
                msg = sprintf('Estimated noise level: NL = %d dB', app.Simulation.noiseEnvironment.noiseLevel);
                title = 'Save ambient noise';
                selection = uiconfirm(app.Figure, msg, title, ...
                               'Options',{'Close window', 'Reprocess recording'}, ...
                               'DefaultOption', 1, 'Icon', 'info');
                
                if strcmp(selection, 'Close window')
                    % Close UI
                    delete(app.Figure)
                    % Update edit field with new value 
                    set(app.nlEditFieldHandle, 'Value', app.Simulation.noiseEnvironment.noiseLevel)
                end
            end
        end


        function bandwidthTypeChanged(app, hObject, eventData)
            app.Simulation.noiseEnvironment.recording.bandwidthType = hObject.Value;
            app.updateFrequencyRange()
            app.updateFrequencyRangeVisualAspect()
        end

        function updateFrequencyRange(app)
            app.Simulation.noiseEnvironment.recording.frequencyRange.min = app.fmin;
            set(app.handleEditField(3), 'Value', app.fmin)
            app.Simulation.noiseEnvironment.recording.frequencyRange.max = app.fmax;
            set(app.handleEditField(4), 'Value', app.fmax)
        end

        function updateFrequencyRangeVisualAspect(app)
            switch app.Simulation.noiseEnvironment.recording.bandwidthType
                case '1 octave'
                    bool = 0;
                case '1/3 octave'
                    bool = 0;
                case 'ManuallyDefined'
                    bool = 1;
            end
            set(app.handleEditField(3), 'Editable', bool)
            set(app.handleEditField(4), 'Editable', bool)
        end

        function editFieldChanged(app, hObject, eventData, iD)
            switch iD
                case 'filename'
                    app.Simulation.noiseEnvironment.recording.recordingFile = regexprep(hObject.Value, ' ', ''); % Remove blanks
                case 'centroidFrequency'
                    app.Simulation.noiseEnvironment.recording.centroidFrequency = hObject.Value;
                    app.updateFrequencyRange()
                case 'fmin'
                    app.Simulation.noiseEnvironment.recording.frequencyRange.min = hObject.Value;
                case 'fmax'
                    app.Simulation.noiseEnvironment.recording.frequencyRange.max = hObject.Value;    
                case 'calCoeff'
                    app.Simulation.noiseEnvironment.recording.calibrationCoefficient = hObject.Value;
            end
        end
    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function fmin = get.fmin(app)
            G = 10^(3/10); % Constant used by octaveFilter
            switch app.Simulation.noiseEnvironment.recording.bandwidthType
                case '1 octave'
                    fmin = app.Simulation.noiseEnvironment.recording.centroidFrequency / G^(1/2);
                case '1/3 octave'
                    fmin = app.Simulation.noiseEnvironment.recording.centroidFrequency / G^(1/6);
                otherwise
                    fmin = app.Simulation.noiseEnvironment.recording.centroidFrequency / G^(1/2);
            end
            fmin = round(fmin, app.roundCoeff);
        end

        function fmax = get.fmax(app)
            G = 10^(3/10); % Constant used by octaveFilter
            switch app.Simulation.noiseEnvironment.recording.bandwidthType
                case '1 octave'
                    fmax = app.Simulation.noiseEnvironment.recording.centroidFrequency * G^(1/2);
                case '1/3 octave'
                    fmax = app.Simulation.noiseEnvironment.recording.centroidFrequency * G^(1/6);   
                otherwise
                    fmax = app.Simulation.noiseEnvironment.recording.centroidFrequency * G^(1/2);
            end
            fmax = round(fmax, app.roundCoeff);
        end

        function roundCoeff = get.roundCoeff(app)
            if app.Simulation.noiseEnvironment.recording.centroidFrequency <= 10
                roundCoeff = 2; 
            elseif app.Simulation.noiseEnvironment.recording.centroidFrequency <= 100
                roundCoeff = 1; 
            elseif app.Simulation.noiseEnvironment.recording.centroidFrequency <= 1000
                roundCoeff = 0; 
            elseif app.Simulation.noiseEnvironment.recording.centroidFrequency <= 10000
                roundCoeff = -1; 
            elseif app.Simulation.noiseEnvironment.recording.centroidFrequency <= 100000
                roundCoeff = -2; 
            else 
                roundCoeff = -3; 
            end
        end
    end 
end