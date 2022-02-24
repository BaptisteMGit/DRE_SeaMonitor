classdef editDetectorUI < handle 
    %EDITDETECTORUI Summary of this class goes here
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
        Name = "Detector properties";
        % Icon 
        Icon = 'Icons\icons8-infrared-sensor-40.png'
    end 

    properties (Dependent)
        % Position of the main figure 
        fPosition 
        
        % Name to handle the issue with 'Custom source' 
        detectorName
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 450;
        Height = 200;
        % Number of components 
        glNRow = 6;
        glNCol = 5;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 14;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';

        % Sub-windows 
        subWindows = {};
        
        % Handle to the specie drop down
        detectorDropDownHandle

        % Flag to check if properties have been updated 
        flagChanges = 0;
        % Flag to check if the new source is saved 
        isSaved = 0;
    end

    methods
        function app = editDetectorUI(simulation, detectorDropDownHandle)
            % Pass simulation handle 
            app.Simulation = simulation;
            % Handle to drop down
            app.detectorDropDownHandle = detectorDropDownHandle;
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
                            'CloseRequestFcn', @app.closeWindowCallback, ...
                            'Icon', app.Icon);
            
            % Grid Layout
            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 170;
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 200;
            app.GridLayout.ColumnWidth{5} = 5;

            app.GridLayout.RowHeight{5} = 5;

            % Labels 
            addLabel(app, 'Detector', 1, [1, 2], 'title')
            specieToolTip = ['This is the list of pre-defined detector.',...
                'If you are interested in another one please consider defining your own detector model and saving it.',...
                'Do not hesitate to contact me in order to add new detector to later releases (baptiste.menetrierpro@gmail.com).'];
            addLabel(app, 'Detector', 2, 2, 'text', 'left', specieToolTip)

            addLabel(app, 'Name', 3, 2, 'text')
            addLabel(app, 'Detection threshold', 4, 2, 'text')

            % Edit field
            % Detector
            addEditField(app, app.Simulation.detector.name, 3, 4, 'Name', 'text', @app.editFieldChanged) 
    
            addEditField(app, app.Simulation.detector.detectionThreshold, 4, 4, [], 'numeric', @app.editFieldChanged) % Detection threshold
            set(app.handleEditField(2), 'ValueDisplayFormat', '%.1f dB 0 to peak')
            
            % Drop down 
            addDropDown(app, app.Simulation.availableDetectors, app.detectorName, 2, 4, @app.detectorChanged) 

            % Save settings 
            addButton(app, 'Save', 6, [2, 4], @app.saveSettings)

            % Set editable properties 
            app.updateDetectorNameEditField()
        end

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
            app.updateDetectorDropDown()
            set(app.detectorDropDownHandle, 'Value', app.detectorName)
        end

        function editFieldChanged(app, hObject, eventData)
            app.flagChanges = 1;
        end

        function updateDetectorNameEditField(app)
            if strcmp(get(app.handleDropDown(1), 'Value'), 'New custom detector')
                bool = 1;
                if strcmp(app.Simulation.detector.name, 'DefaultDetector')
                    set(app.handleEditField(1), 'Value', '')
                else
                    set(app.handleEditField(1), 'Value', app.Simulation.detector.name)
                end
                set(app.handleEditField(1), 'Placeholder', 'Enter a name')
            elseif ~strcmp(get(app.handleDropDown(1), 'Value'), app.Simulation.implementedDetectors)
                bool = 1;
                set(app.handleEditField(1), 'Value',  get(app.handleDropDown(1), 'Value'))
            else 
                bool = 0;
                set(app.handleEditField(1), 'Value', get(app.handleDropDown(1), 'Value'))
            end
            set(app.handleEditField(1), 'Editable', bool)
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
            end
            app.updatePropertiesValue()
            app.updateDetectorNameEditField()
        end
        
        function updateDetectorDropDown(app, hObject, eventData)
            set(app.detectorDropDownHandle, 'Items', app.Simulation.availableDetectors)
        end


        function saveSettings(app, hObject, eventData)
            app.saveProperties()
            
            if (strcmp(get(app.handleDropDown(1), 'Value'), 'New custom detector')) % User created a custom source 
                if isempty(get(app.handleEditField(1), 'Value')) % New source has no name 
                    uialert(app.Figure, 'Custom detector has no name, please enter a name.', 'No name selected', 'Icon', 'info')
                else
                    msg = 'You have created a new type of detector. Do you want to save it in order to re-use it later ?';
                    title = 'Save new detector ?';
                    app.saveModalWindow(msg, title);
                end

            elseif (~any(strcmp(get(app.handleDropDown(1), 'Value'), app.Simulation.implementedDetectors)) && app.flagChanges) % User modified an already existing custom source 
                app.isSaved = 1;
                msg = 'You have modified the properties of this custom detector. Do you want to save it in order to re-use it later ?';
                title = 'Save modifications ?';
                app.saveModalWindow(msg, title);
        
            elseif (any(strcmp(get(app.handleDropDown(1), 'Value'), app.Simulation.implementedDetectors)) && app.flagChanges) % User modified a pre-defined source 
                delete(app.Figure)

            else % Nothing has been modified
                app.isSaved = 1;
                delete(app.Figure)
            end

            app.updateDetectorDropDown()
            set(app.detectorDropDownHandle, 'Value', app.detectorName)
            end 

        function saveModalWindow(app, msg, title)
            options = {'Yes', 'No', 'Cancel'};
            selection = uiconfirm(app.Figure, msg, title, ...
                            'Options', options, ...
                            'DefaultOption',2,'CancelOption',3);
            switch selection
                case options{1}
                    cd(app.Simulation.rootDetectors)
                    props = properties(app.Simulation.detector);
                    for i=1:numel(props)
                        property = props{i};
                        structDetector.(property) = app.Simulation.detector.(property);
                    end
                    uisave('structDetector', get(app.handleEditField(1), 'Value'))
                    cd(app.Simulation.rootApp)
                    delete(app.Figure)
                    app.isSaved = 1;
                case options{2}
                    delete(app.Figure)
                otherwise
                    return
            end
        end

        function saveProperties(app)
            app.Simulation.detector.name = get(app.handleEditField(1), 'Value');
            app.Simulation.detector.detectionThreshold = get(app.handleEditField(2), 'Value');
        end

        function updatePropertiesValue(app)
            set(app.handleEditField(1), 'Value', app.Simulation.detector.name);
            set(app.handleEditField(2), 'Value', app.Simulation.detector.detectionThreshold);
        end 

    end
    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function name = get.detectorName(app)
            if ~any(strcmp(app.Simulation.availableDetectors, app.Simulation.detector.name)) && ~app.isSaved
                name = 'New custom detector';
            else
                name = app.Simulation.detector.name;
            end
        end
    end 

end

