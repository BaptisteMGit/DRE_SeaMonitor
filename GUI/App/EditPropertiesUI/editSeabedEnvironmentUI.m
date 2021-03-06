classdef editSeabedEnvironmentUI < handle 
    % EDITSEABEDENVIRONMENTUI: App window dedicated to the configuration of the
    % seabed environment 
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
        Name = "Seabed properties";
        % Icon 
        Icon = 'Icons\icons8-sedimentology-128.png'
    end 
    
    properties (Dependent)
        % Position of the main figure 
        fPosition 
        
        sedimentType
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 450;
        Height = 300;
        % Number of components 
        glNRow = 8;
        glNCol = 5;
        
        % Labels visual properties 
        LabelFontName = 'Arial';
        LabelFontSize_title = 16;
        LabelFontSize_text = 14;
        LabelFontWeight_title = 'bold';
        LabelFontWeight_text = 'normal';
        
        % Subwindow open to kill when this window is closed 
        subWindows = {};

        % Handle to the specie drop down
        seabedDropDownHandle

        % Flag to check if properties have been updated 
        flagChanges = 0;
        % Flag to check if the new sediment is saved 
        isSaved = 0;
    end
    
    %% Constructor of the class 
    methods
        function app = editSeabedEnvironmentUI(simulation, seabedDropDownHandle)
            % Pass simulation handle 
            app.Simulation = simulation;
            % Handle to drop down
            app.seabedDropDownHandle = seabedDropDownHandle;
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
            app.GridLayout.ColumnWidth{2} = 'fit';
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 150;
            app.GridLayout.ColumnWidth{5} = 5;

            app.GridLayout.RowHeight{7} = 5;

            % Labels 
            titleLabelFont = getLabelFont(app, 'Title');
            textLabelFont = getLabelFont(app, 'Text');

            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Seabed', 'LayoutPosition', struct('nRow', 1, 'nCol', [1, 2]), 'Font', titleLabelFont})

            seabedToolTip = ['This is the list of pre-defined sediment.',...
                'If you are interested in another one please consider defining your own sediment model and saving it.',...
                'Do not hesitate to contact me in order to add new sediment to later releases (baptiste.menetrierpro@gmail.com).'];
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Sediment', 'LayoutPosition', struct('nRow', 2, 'nCol', 2), ...
                'Font', textLabelFont, 'Tooltip', seabedToolTip})

            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Name', 'LayoutPosition', struct('nRow', 3, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Sound celerity', 'LayoutPosition', struct('nRow', 4, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Density', 'LayoutPosition', struct('nRow', 5, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Compressional wave absorption', 'LayoutPosition', struct('nRow', 6, 'nCol', 2), 'Font', textLabelFont})


            % Edit field
            % Marine mammal
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'text', 'Value', app.Simulation.seabedEnvironment.sedimentType, ...
                'LayoutPosition', struct('nRow', 3, 'nCol', 4), 'ValueChangedFcn', @app.editFieldChanged, 'Placeholder', 'Name'})

            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.seabedEnvironment.bottom.c, ...
                'LayoutPosition', struct('nRow', 4, 'nCol', 4), 'ValueChangedFcn', @app.editFieldChanged, 'ValueDisplayFormat', '%.3f m.s-1'}) % Sound celerity

            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.seabedEnvironment.bottom.rho, ...
                'LayoutPosition', struct('nRow', 5, 'nCol', 4), 'ValueChangedFcn', @app.editFieldChanged, 'ValueDisplayFormat', '%.3f g.cm-3'}) % Sound celerity

            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.seabedEnvironment.bottom.cwa, ...
                'LayoutPosition', struct('nRow', 6, 'nCol', 4), 'ValueChangedFcn', @app.editFieldChanged, 'ValueDisplayFormat', '%.3f dB/lambda'}) % Compressional wave absorption
            
            % Drop down 
            addDropDown(app, {'Parent', app.GridLayout, 'Items', app.Simulation.availableSediments, 'Value', app.sedimentType, ...
                'ValueChangedFcn', @app.sedimentChanged, 'LayoutPosition',  struct('nRow', 2, 'nCol', 4)})

            % Save settings 
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Save', 'ButtonPushedFcn', @app.saveSettings, 'LayoutPosition', struct('nRow', 8, 'nCol', [2, 4])})

            % Set editable properties 
            app.updateSedimentTypeEditField()
        end

        function editFieldChanged(app, hObject, eventData)
            app.flagChanges = 1;
        end

        function updateSedimentTypeEditField(app)
            if strcmp(get(app.handleDropDown(1), 'Value'), 'New custom sediment')
                bool = 1;
                if strcmp(app.Simulation.seabedEnvironment.sedimentType, 'New custom sediment')
                    set(app.handleEditField(1), 'Value', '')
                else
                    set(app.handleEditField(1), 'Value', app.Simulation.seabedEnvironment.sedimentType)
                end
                set(app.handleEditField(1), 'Placeholder', 'Enter a name')
            elseif ~strcmp(get(app.handleDropDown(1), 'Value'), app.Simulation.implementedSediments)
                bool = 1;
                set(app.handleEditField(1), 'Value',  get(app.handleDropDown(1), 'Value'))
            else 
                bool = 0;
                set(app.handleEditField(1), 'Value', get(app.handleDropDown(1), 'Value'))
            end
            set(app.handleEditField(1), 'Editable', bool)
        end
        
        function sedimentChanged(app, hObject, eventData)
            app.Simulation.seabedEnvironment.sedimentType = hObject.Value;
            app.Simulation.seabedEnvironment.setBottom()
            app.updatePropertiesValue()
            app.updateSedimentTypeEditField()
        end
        
        function updateSedimentDropDown(app, hObject, eventData)
            set(app.seabedDropDownHandle, 'Items', app.Simulation.availableSediments)
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
            app.updateSedimentDropDown()
            set(app.seabedDropDownHandle, 'Value', app.sedimentType)
        end

        function saveSettings(app, hObject, eventData)
            app.saveProperties()

            [bool, msg] = app.Simulation.seabedEnvironment.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Seabed environment failed', 'warning')
            
            if bool                
                if (strcmp(get(app.handleDropDown(1), 'Value'), 'New custom sediment'))  % User created a custom sediment 
                    if isempty(get(app.handleEditField(1), 'Value')) % New source has no name 
                        uialert(app.Figure, 'Custom sediment has no name, please enter a name.', 'No name selected', 'Icon', 'info')
                    else
                        msg = 'You have created a new type of sediment. Do you want to save it in order to re-use it later ?';
                        title = 'Save new sediment ?';
                        app.saveModalWindow(msg, title);
                    end
    
                elseif (~any(strcmp(get(app.handleDropDown(1), 'Value'), app.Simulation.implementedSediments)) && app.flagChanges) % User modified an already existing custom sediment
                    app.isSaved = 1;
                    msg = 'You have modified the properties of this custom sediment. Do you want to save it in order to re-use it later ?';
                    title = 'Save new sediment ?';
                    app.saveModalWindow(msg, title);
    
                elseif (any(strcmp(get(app.handleDropDown(1), 'Value'), app.Simulation.implementedSediments)) && app.flagChanges)  % User modified a pre-defined source 
                    delete(app.Figure)
    
                else 
                    app.isSaved = 1;
                    delete(app.Figure)
    
                end
    
                app.updateSedimentDropDown(); % Add new sediment to the available sediment 
                set(app.seabedDropDownHandle, 'Value', app.sedimentType);
            else 
                app.updatePropertiesValue()
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
                    cd(app.Simulation.rootSediments)
                    props = properties(app.Simulation.seabedEnvironment);
                    for i=1:numel(props)
                        property = props{i};
                        structSeabed.(property) = app.Simulation.seabedEnvironment.(property);
                    end
                    uisave('structSeabed', get(app.handleEditField(1), 'Value'))
                    cd(app.Simulation.rootApp)
                    delete(app.Figure)
                    app.isSaved = 1;
                case options{2}
                    delete(app.Figure)
                    app.isSaved = 0;
                otherwise
                    return
            end
        end

        function saveProperties(app)
            app.Simulation.seabedEnvironment.sedimentType = get(app.handleEditField(1), 'Value');
            app.Simulation.seabedEnvironment.bottom.c = get(app.handleEditField(2), 'Value');
            app.Simulation.seabedEnvironment.bottom.rho = get(app.handleEditField(3), 'Value');
            app.Simulation.seabedEnvironment.bottom.cwa = get(app.handleEditField(4), 'Value');
        end

        function updatePropertiesValue(app)
            set(app.handleEditField(1), 'Value', app.Simulation.seabedEnvironment.sedimentType);
            set(app.handleEditField(2), 'Value', app.Simulation.seabedEnvironment.bottom.c);
            set(app.handleEditField(3), 'Value', app.Simulation.seabedEnvironment.bottom.rho);
            set(app.handleEditField(4), 'Value', app.Simulation.seabedEnvironment.bottom.cwa);
        end 

    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end

        function sedimentType = get.sedimentType(app)
            if ~any(strcmp(app.Simulation.availableSediments, app.Simulation.seabedEnvironment.sedimentType)) && ~app.isSaved
                sedimentType = 'New custom sediment';
            else
                sedimentType = app.Simulation.seabedEnvironment.sedimentType;
            end
        end
    end
end

