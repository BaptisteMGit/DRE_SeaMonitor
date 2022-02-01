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

        centroidFrequency
    end 

    properties (Dependent)
        % Position of the main figure 
        fPosition 
        
        % Name to handle the issue with other 
        marineMammalName
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 400;
        Height = 300;
        % Number of components 
        glNRow = 10;
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
                            'CloseRequestFcn', @app.closeWindowCallback);
            
            % Grid Layout
            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 170;
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 150;
            app.GridLayout.ColumnWidth{5} = 5;

            app.GridLayout.RowHeight{9} = 5;

            % Labels 
            addLabel(app, 'Marine mammal', 1, [1, 2], 'title')
            specieToolTip = ['This is the list of pre-defined species.',...
                'If you are interested in another one please consider defining your own specie model and saving it.',...
                'Do not hesitate to contact me in order to add new specie to later releases (baptiste.menetrierpro@gmail.com).'];
            addLabel(app, 'Specie', 2, 2, 'text', 'left', specieToolTip)
            addLabel(app, 'Name', 3, 2, 'text')

            addLabel(app, 'Centroid frequency', 4, 2, 'text')
            addLabel(app, 'Source level', 5, 2, 'text')
        
            addLabel(app, 'Maximum detection range', 6, 2, 'text')
            addLabel(app, 'Living depth', 7, 2, 'text')
            addLabel(app, 'Range around living depth', 8, 2, 'text')

            % Edit field
            % Recording
            addEditField(app, app.Simulation.marineMammal.name, 3, 4, 'Name', 'text', {@app.editFieldChanged, 'name'}) 
    
            addEditField(app, app.Simulation.marineMammal.centroidFrequency, 4, 4, [], 'numeric', {@app.editFieldChanged, 'centroidFrequency'}) % Centroid frequency
            set(app.handleEditField(2), 'ValueDisplayFormat', '%d Hz')

            addEditField(app, app.Simulation.marineMammal.sourceLevel, 5, 4, [], 'numeric', {@app.editFieldChanged, 'sourceLevel'}) % Source level 
            set(app.handleEditField(3), 'ValueDisplayFormat', '%d dB re 1uPa at 1m')

            addEditField(app, app.Simulation.marineMammal.rMax, 6, 4, [], 'numeric', {@app.editFieldChanged, 'rMax'}) % rMax
            set(app.handleEditField(4), 'ValueDisplayFormat', '%d m')
            
            addEditField(app, app.Simulation.marineMammal.livingDepth, 7, 4, [], 'numeric', {@app.editFieldChanged, 'livingDepth'}) % livingDepth
            set(app.handleEditField(5), 'ValueDisplayFormat', '%d m')

            addEditField(app, app.Simulation.marineMammal.deltaLivingDepth, 8, 4, [], 'numeric', {@app.editFieldChanged, 'deltaLivingDepth'}) % deltaLivingDepth
            set(app.handleEditField(6), 'ValueDisplayFormat', '%d m') 
            
            % Drop down 
            addDropDown(app, {'Common dolphin', 'Bottlenose dolphin', 'Porpoise', 'Other'}, app.marineMammalName, 2, 4, @app.specieChanged) 

            % Save settings 
            addButton(app, 'Save', 10, [2, 4], @app.saveSettings)

            % Set editable properties 
            app.updateSpecieNameEditField()
        end

        function closeWindowCallback(app, hObject, eventData)
            msg = 'Do you want to save the changes ?';
            options = {'Save and quit', 'Quit without saving'   , 'Cancel'};
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
            set(app.specieDropDownHandle, 'Value', app.marineMammalName)
        end

        function editFieldChanged(app, hObject, eventData, iD)
            switch iD
                case 'name'
                    app.Simulation.noiseEnvironment.wenzModel.windSpeed = hObject.Value; 
                case 'centroidFrequency'
                    app.centroidFrequency = hObject.Value;
                    app.updateFrequencyRange()
                case 'fmin'
                    app.Simulation.noiseEnvironment.wenzModel.frequencyRange.min = hObject.Value;
                    app.updateWindTrafficVisualAspect()
                case 'fmax'
                    app.Simulation.noiseEnvironment.wenzModel.frequencyRange.max = hObject.Value;   
                    app.updateWindTrafficVisualAspect()
            end
        end

        function updateSpecieNameEditField(app)
            if strcmp(get(app.handleDropDown(1), 'Value'), 'Other')
                bool = 1;
                set(app.handleEditField(1), 'Value', '')
                set(app.handleEditField(1), 'Placeholder', 'Enter a name')
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
                case 'Other'
                    app.Simulation.marineMammal = MarineMammal;
            end
            app.updatePropertiesValue()
            app.updateSpecieNameEditField()
        end
        
        function saveSettings(app, hObject, eventData)
            app.saveProperties()
            
            switch get(app.handleDropDown(1), 'Value')
                case 'Other'
                    app.Simulation.marineMammal.setDefaultSignal()
                    msg = 'You have created a new type of acoustic source. Do you want to save it in order to re-use it later ?';
                    options = {'Yes', 'No', 'Cancel'};
                    selection = uiconfirm(app.Figure, msg, 'Save new source ?', ...
                                    'Options', options, ...
                                    'DefaultOption',2,'CancelOption',3);
                    switch selection
                        case options{1}
                            marineMammal = app.Simulation.marineMammal;
                            uisave('marineMammal', get(app.handleEditField(1), 'Value'))
                        case options{2}
                            delete(app.Figure)
                        otherwise
                            return
                    end

                otherwise
                    app.Simulation.marineMammal.updateSignal()
                    delete(app.Figure)
            end 
            set(app.specieDropDownHandle, 'Value', app.marineMammalName)
        end 

        function saveProperties(app)
            app.Simulation.marineMammal.name = get(app.handleEditField(1), 'Value');
            app.Simulation.marineMammal.centroidFrequency = get(app.handleEditField(2), 'Value');
            app.Simulation.marineMammal.sourceLevel = get(app.handleEditField(3), 'Value');
            app.Simulation.marineMammal.rMax = get(app.handleEditField(4), 'Value');
            app.Simulation.marineMammal.livingDepth = get(app.handleEditField(5), 'Value');
            app.Simulation.marineMammal.deltaLivingDepth = get(app.handleEditField(6), 'Value');
        end

        function updatePropertiesValue(app)
            set(app.handleEditField(1), 'Value', app.Simulation.marineMammal.name);
            set(app.handleEditField(2), 'Value', app.Simulation.marineMammal.centroidFrequency);
            set(app.handleEditField(3), 'Value', app.Simulation.marineMammal.sourceLevel);
            set(app.handleEditField(4), 'Value', app.Simulation.marineMammal.rMax);
            set(app.handleEditField(5), 'Value', app.Simulation.marineMammal.livingDepth);
            set(app.handleEditField(6), 'Value', app.Simulation.marineMammal.deltaLivingDepth);
        end 

    end
    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function name = get.marineMammalName(app)
            if ~any(strcmp({'Common dolphin', 'Bottlenose dolphin', 'Porpoise'}, app.Simulation.marineMammal.name))
                name = 'Other';
            else
                name = app.Simulation.marineMammal.name;
            end
        end
    end 

end

