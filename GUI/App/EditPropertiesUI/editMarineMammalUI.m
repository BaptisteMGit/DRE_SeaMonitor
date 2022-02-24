classdef editMarineMammalUI < handle 
    %EDITMARINEMAMMALUI Summary of this class goes here
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
        Name = "Marine mammal properties";
        % Icon 
        Icon = 'Icons\icons8-sample-rate-90.png'

        centroidFrequency
    end 

    properties (Dependent)
        % Position of the main figure 
        fPosition 
        
        % Name to handle the issue with 'Custom source' 
        marineMammalName
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 450;
        Height = 400;
        % Number of components 
        glNRow = 12;
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
        specieDropDownHandle

        % Flag to check if properties have been updated 
        flagChanges = 0;
        % Flag to check if the new source is saved 
        isSaved = 0;
    end

    methods
        function app = editMarineMammalUI(simulation, specieDropDownHandle)
            % Pass simulation handle 
            app.Simulation = simulation;
            % Handle to drop down
            app.specieDropDownHandle = specieDropDownHandle;
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

            app.GridLayout.RowHeight{11} = 5;

            % Labels 
            addLabel(app, 'Marine mammal', 1, [1, 2], 'title')
            specieToolTip = ['This is the list of pre-defined species.',...
                'If you are interested in another one please consider defining your own specie model and saving it.',...
                'Do not hesitate to contact me in order to add new specie to later releases (baptiste.menetrierpro@gmail.com).'];
            addLabel(app, 'Specie', 2, 2, 'text', 'left', specieToolTip)
            addLabel(app, 'Name', 3, 2, 'text')

            addLabel(app, 'Centroid frequency', 4, 2, 'text')
            addLabel(app, 'Source level', 5, 2, 'text')
            addLabel(app, 'Std source level', 6, 2, 'text')
            addLabel(app, 'Directivity index', 7, 2, 'text')

            addLabel(app, 'Maximum detection range', 8, 2, 'text')
            addLabel(app, 'Living depth', 9, 2, 'text')
            addLabel(app, 'Range around living depth', 10, 2, 'text')

            % Edit field
            % Marine mammal
            addEditField(app, app.Simulation.marineMammal.name, 3, 4, 'Name', 'text', @app.editFieldChanged) 
    
            addEditField(app, app.Simulation.marineMammal.centroidFrequency, 4, 4, [], 'numeric', @app.editFieldChanged) % Centroid frequency
            set(app.handleEditField(2), 'ValueDisplayFormat', '%d Hz')

            addEditField(app, app.Simulation.marineMammal.sourceLevel, 5, 4, [], 'numeric', @app.editFieldChanged) % Source level 
            set(app.handleEditField(3), 'ValueDisplayFormat', '%d dB re 1uPa at 1m')

            addEditField(app, app.Simulation.marineMammal.sigmaSourceLevel, 6, 4, [], 'numeric', @app.editFieldChanged) % Directivity index
            set(app.handleEditField(4), 'ValueDisplayFormat', '%d dB')

            addEditField(app, app.Simulation.marineMammal.directivityIndex, 7, 4, [], 'numeric', @app.editFieldChanged) % Directivity index
            set(app.handleEditField(5), 'ValueDisplayFormat', '%d dB')

            addEditField(app, app.Simulation.marineMammal.rMax, 8, 4, [], 'numeric', @app.editFieldChanged) % rMax
            set(app.handleEditField(6), 'ValueDisplayFormat', '%d m')
            
            addEditField(app, app.Simulation.marineMammal.livingDepth, 9, 4, [], 'numeric', @app.editFieldChanged) % livingDepth
            set(app.handleEditField(7), 'ValueDisplayFormat', '%d m')

            addEditField(app, app.Simulation.marineMammal.deltaLivingDepth, 10, 4, [], 'numeric', @app.editFieldChanged) % deltaLivingDepth
            set(app.handleEditField(8), 'ValueDisplayFormat', '%d m') 
            
            % Drop down 
            addDropDown(app, app.Simulation.availableSources, app.marineMammalName, 2, 4, @app.specieChanged) 

            % Save settings 
            addButton(app, 'Save', 12, [2, 4], @app.saveSettings)

            % Set editable properties 
            app.updateSpecieNameEditField()
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
                        app.saveSettings()
                    case options{2}
                        delete(app.Figure)
                    otherwise
                        return
                end
            else
                delete(app.Figure)
            end
            app.updateSpecieDropDown()
            set(app.specieDropDownHandle, 'Value', app.marineMammalName)
        end

        function editFieldChanged(app, hObject, eventData)
            app.flagChanges = 1;
        end

        function updateSpecieNameEditField(app)
            if strcmp(get(app.handleDropDown(1), 'Value'), 'New custom source')
                bool = 1;
                if strcmp(app.Simulation.marineMammal.name, 'DefaultMammal')
                    set(app.handleEditField(1), 'Value', '')
                else
                    set(app.handleEditField(1), 'Value', app.Simulation.marineMammal.name)
                end
                set(app.handleEditField(1), 'Placeholder', 'Enter a name')
            elseif ~strcmp(get(app.handleDropDown(1), 'Value'), app.Simulation.implementedSources)
                bool = 1;
                set(app.handleEditField(1), 'Value',  get(app.handleDropDown(1), 'Value'))
            else 
                bool = 0;
                set(app.handleEditField(1), 'Value', get(app.handleDropDown(1), 'Value'))
            end
            set(app.handleEditField(1), 'Editable', bool)
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
            end
            app.updatePropertiesValue()
            app.updateSpecieNameEditField()
        end
        
        function updateSpecieDropDown(app, hObject, eventData)
            set(app.specieDropDownHandle, 'Items', app.Simulation.availableSources)
        end


        function saveSettings(app, hObject, eventData)
            app.saveProperties()

            [bool, msg] = app.Simulation.marineMammal.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Marine mammal warning', 'warning')
            if bool 
                if (strcmp(get(app.handleDropDown(1), 'Value'), 'New custom source')) % User created a custom source 
                    if isempty(get(app.handleEditField(1), 'Value')) % New source has no name 
                        uialert(app.Figure, 'Custom source has no name, please enter a name.', 'No name selected', 'Icon', 'info')
                    else
                        msg = 'You have created a new type of acoustic source. Do you want to save it in order to re-use it later ?';
                        title = 'Save new source ?';
                        app.saveModalWindow(msg, title);
                    end
    
                elseif (~any(strcmp(get(app.handleDropDown(1), 'Value'), app.Simulation.implementedSources)) && app.flagChanges) % User modified an already existing custom source 
                    app.isSaved = 1;
                    msg = 'You have modified the properties of this custom acoustic source. Do you want to save it in order to re-use it later ?';
                    title = 'Save modifications ?';
                    app.saveModalWindow(msg, title);
            
                elseif (any(strcmp(get(app.handleDropDown(1), 'Value'), app.Simulation.implementedSources)) && app.flagChanges) % User modified a pre-defined source 
                    delete(app.Figure)
    
                else % Nothing has been modified
                    app.isSaved = 1;
                    delete(app.Figure)
                end
    
                app.updateSpecieDropDown()
                set(app.specieDropDownHandle, 'Value', app.marineMammalName)
            else 
                return 
            end 
            end 

        function saveModalWindow(app, msg, title)
            options = {'Yes', 'No', 'Cancel'};
            selection = uiconfirm(app.Figure, msg, title, ...
                            'Options', options, ...
                            'DefaultOption',2,'CancelOption',3);
            switch selection
                case options{1}
                    cd(app.Simulation.rootSources)
                    props = properties(app.Simulation.marineMammal);
                    for i=1:numel(props)
                        property = props{i};
                        structMarineMammal.(property) = app.Simulation.marineMammal.(property);
                    end
                    uisave('structMarineMammal', get(app.handleEditField(1), 'Value'))
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
            app.Simulation.marineMammal.name = get(app.handleEditField(1), 'Value');
            app.Simulation.marineMammal.centroidFrequency = get(app.handleEditField(2), 'Value');
            app.Simulation.marineMammal.sourceLevel = get(app.handleEditField(3), 'Value');
            app.Simulation.marineMammal.sigmaSourceLevel = get(app.handleEditField(4), 'Value');
            app.Simulation.marineMammal.directivityIndex = get(app.handleEditField(5), 'Value');
            app.Simulation.marineMammal.rMax = get(app.handleEditField(6), 'Value');
            app.Simulation.marineMammal.livingDepth = get(app.handleEditField(7), 'Value');
            app.Simulation.marineMammal.deltaLivingDepth = get(app.handleEditField(8), 'Value');
            app.Simulation.marineMammal.setSignal(); % Update signal with new values
        end

        function updatePropertiesValue(app)
            set(app.handleEditField(1), 'Value', app.Simulation.marineMammal.name);
            set(app.handleEditField(2), 'Value', app.Simulation.marineMammal.centroidFrequency);
            set(app.handleEditField(3), 'Value', app.Simulation.marineMammal.sourceLevel);
            set(app.handleEditField(4), 'Value', app.Simulation.marineMammal.sigmaSourceLevel);
            set(app.handleEditField(5), 'Value', app.Simulation.marineMammal.directivityIndex);
            set(app.handleEditField(6), 'Value', app.Simulation.marineMammal.rMax);
            set(app.handleEditField(7), 'Value', app.Simulation.marineMammal.livingDepth);
            set(app.handleEditField(8), 'Value', app.Simulation.marineMammal.deltaLivingDepth);
        end 

    end
    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function name = get.marineMammalName(app)
            if ~any(strcmp(app.Simulation.availableSources, app.Simulation.marineMammal.name)) && ~app.isSaved
                name = 'New custom source';
            else
                name = app.Simulation.marineMammal.name;
            end
        end
    end 

end

