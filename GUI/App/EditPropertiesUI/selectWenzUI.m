classdef selectWenzUI < handle
% selectWenzUI: App window to select Wenz model parameters to
% derive the ambient noise level.
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
        Name = "Wenz parameters";
        % Icon 
        Icon = 'Icons\icons8-sea-waves-96.png'

        bandwidthType = '1 octave';
        centroidFrequency
    end 
    
    properties (Dependent)
        % Position of the main figure 
        fPosition 

        % frequency range
        fmin
        fmax
        % round coeff for frequency 
        roundCoeff
        % Label for traffic intensity value
        trafficIntensityLabel
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 450;
        Height = 300;
        % Number of components 
        glNRow = 9;
        glNCol = 5;
        
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
        function app = selectWenzUI(simulation, nlEditFieldHandle)
            % Pass simulation handle 
            app.Simulation = simulation;
            app.centroidFrequency = app.Simulation.marineMammal.centroidFrequency;
            % Initialise value 
            app.Simulation.noiseEnvironment.wenzModel.frequencyRange = struct('min', app.fmin, 'max', app.fmax);
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
                            'CloseRequestFcn', @app.closeWindowCallback, ...
                            'Icon', app.Icon);
            
            % Grid Layout
            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            app.GridLayout.ColumnWidth{1} = 10;
            app.GridLayout.ColumnWidth{2} = 120;
            app.GridLayout.ColumnWidth{3} = 5;
            app.GridLayout.ColumnWidth{4} = 250;
            app.GridLayout.ColumnWidth{5} = 5;

            app.GridLayout.RowHeight{8} = 5;

            % Labels 
            titleLabelFont = getLabelFont(app, 'Title');
            textLabelFont = getLabelFont(app, 'Text');

            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Ambient noise', 'LayoutPosition', struct('nRow', 1, 'nCol', [1, 2]), 'Font', titleLabelFont})

            trafficIntensityTooltip = ['Traffic intensity is evaluated on a scale from 0 to 3.', ...
                'This parameter only contribute to noise background in the very low frequency band (10Hz - 1kHz).'];
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Traffic intensity', 'LayoutPosition', struct('nRow', 2, 'nCol', 2), ...
                'Font', textLabelFont, 'Tooltip', trafficIntensityTooltip})

            windSpeedTooltip = ['Wind speed in m.s-1.', ...
                'This parameter contribute to noise background in the low to high frequency band (1kHz - 100kHz).'];
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Wind speed', 'LayoutPosition', struct('nRow', 3, 'nCol', 2), ...
                'Font', textLabelFont, 'Tooltip', windSpeedTooltip})

            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Centroid frequency', 'LayoutPosition', struct('nRow', 4, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'Bandwidth', 'LayoutPosition', struct('nRow', 5, 'nCol', 2), 'Font', textLabelFont})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'fMin', 'LayoutPosition', struct('nRow', 6, 'nCol', 2), 'Font', textLabelFont, 'HorizontalAlignment', 'right'})
            addLabel(app, {'Parent', app.GridLayout, 'Text', 'fMax', 'LayoutPosition', struct('nRow', 7, 'nCol', 2), 'Font', textLabelFont, 'HorizontalAlignment', 'right'})

            % Edit field
            % Recording
            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.Simulation.noiseEnvironment.wenzModel.windSpeed, ...
                'LayoutPosition', struct('nRow', 3, 'nCol', 4), 'ValueChangedFcn', {@app.editFieldChanged, 'windSpeed'}, ...
                'ValueDisplayFormat', '%d m.s-1'})

            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.centroidFrequency, ...
                'LayoutPosition', struct('nRow', 4, 'nCol', 4), 'ValueChangedFcn', {@app.editFieldChanged, 'centroidFrequency'}, ...
                'ValueDisplayFormat', '%d Hz'})

            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.fmin, ...
                'LayoutPosition', struct('nRow', 6, 'nCol', 4), 'ValueChangedFcn', {@app.editFieldChanged, 'fmin'}, ...
                'ValueDisplayFormat', '%d Hz'})

            addEditField(app, {'Parent', app.GridLayout, 'Style', 'numeric', 'Value', app.fmax, ...
                'LayoutPosition', struct('nRow', 7, 'nCol', 4), 'ValueChangedFcn', {@app.editFieldChanged, 'fmax'}, ...
                'ValueDisplayFormat', '%d Hz'}) 
            
            % Drop down 
            addDropDown(app, {'Parent', app.GridLayout, 'Items', {'Quiet', 'Low', 'Medium', 'Heavy'}, 'Value', app.trafficIntensityLabel, ...
                'ValueChangedFcn', @app.trafficIntensityChanged, 'LayoutPosition',  struct('nRow', 2, 'nCol', 4)})
            addDropDown(app, {'Parent', app.GridLayout, 'Items', {'1/3 octave', '1 octave', 'ManuallyDefined'}, 'Value', app.bandwidthType, ...
                'ValueChangedFcn', @app.bandwidthTypeChanged, 'LayoutPosition',  struct('nRow', 5, 'nCol', 4)})

            % Save settings 
            addButton(app, {'Parent', app.GridLayout, 'Name', 'Compute noise level', 'ButtonPushedFcn', @app.computeNoiseLevel, ...
                'LayoutPosition', struct('nRow', 9, 'nCol', [2, 4])})

            % Set editable properties 
            app.updateWindTrafficVisualAspect()
            app.updateFrequencyRangeVisualAspect()
        end
    end
    
    %% Callback functions 
    methods
        function closeWindowCallback(app, hObject, eventData)
            % Update edit field with new value 
            set(app.nlEditFieldHandle, 'Value', app.Simulation.noiseEnvironment.noiseLevel)
            closeWindowCallback(hObject, eventData)
        end
        
        function bool = checkWenz(app)
            % Blocking conditions 
            [bool, msg] = app.Simulation.noiseEnvironment.wenzModel.checkParametersValidity;
            assertDialogBox(app, bool, msg, 'Wenz warning', 'warning')
            
            % Check if centroid frequency is the same as the marine mammal
            % one. 
            if ~(app.Simulation.marineMammal.centroidFrequency == app.centroidFrequency)
                message = {sprintf(['Usually one should be interested in estimating the ambient noise level in the frequency band of interest.', ...
                    'You have selected a centroid frequency different from the centroid frequency of %s emmited by %s.', ...
                    'You should consider editing the centroid frequency either for the estimation of ambient noise ', ...
                    'level or for the studied signal associated to the specie of interest.'], ...
                    app.Simulation.marineMammal.signal.name, app.Simulation.marineMammal.name)};
                assertDialogBox(app, 0, message, 'Centroid frequency info', 'info')
            end
        end

        function computeNoiseLevel(app, hObject, eventData)
            bool = app.checkWenz();
            if bool
                d = uiprogressdlg(app.Figure,'Title','Please Wait',...
                                'Message','Estimating ambient noise level...', ...
                                'ShowPercentage', 'on');
                app.Simulation.noiseEnvironment.computeNoiseLevel(d)
                close(d) 
                
                msg = sprintf('Estimated noise level: NL = %d dB', app.Simulation.noiseEnvironment.noiseLevel);
                title = 'Save ambient noise';
                selection = uiconfirm(app.Figure, msg, title, ...
                               'Options',{'Close window', 'Recompute noise level'}, ...
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
            app.bandwidthType = hObject.Value;
            app.updateFrequencyRange()
            app.updateFrequencyRangeVisualAspect()
        end

        function updateFrequencyRange(app)
            app.Simulation.noiseEnvironment.wenzModel.frequencyRange.min = app.fmin;
            set(app.handleEditField(3), 'Value', app.fmin)
            app.Simulation.noiseEnvironment.wenzModel.frequencyRange.max = app.fmax;
            set(app.handleEditField(4), 'Value', app.fmax)
            app.updateWindTrafficVisualAspect()
        end

        function updateFrequencyRangeVisualAspect(app)
            switch app.bandwidthType
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
        
        function updateWindTrafficVisualAspect(app)
            if app.Simulation.noiseEnvironment.wenzModel.frequencyRange.min > 1000
                boolTraffic = 0;
            else 
                boolTraffic = 1;
            end
            set(app.handleDropDown(1), 'Enable', boolTraffic)
            
            if app.Simulation.noiseEnvironment.wenzModel.frequencyRange.min >= 100000
                boolWind = 0;
            else 
                boolWind = 1;
            end
            set(app.handleEditField(1), 'Editable', boolWind)
        end
       
        function editFieldChanged(app, hObject, eventData, iD)
            switch iD
                case 'windSpeed'
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

        function trafficIntensityChanged(app, hOject, eventData)
            switch hOject.Value
                case 'Quiet'
                    app.Simulation.noiseEnvironment.wenzModel.trafficIntensity = 0;
                case 'Low'
                    app.Simulation.noiseEnvironment.wenzModel.trafficIntensity = 1;
                case 'Medium'
                    app.Simulation.noiseEnvironment.wenzModel.trafficIntensity = 2;
                case 'Heavy'
                    app.Simulation.noiseEnvironment.wenzModel.trafficIntensity = 3;
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
            switch app.bandwidthType
                case '1 octave'
                    fmin = app.centroidFrequency / G^(1/2);
                case '1/3 octave'
                    fmin = app.centroidFrequency / G^(1/6);
                otherwise
                    fmin = app.centroidFrequency / G^(1/2);
            end
            fmin = round(fmin, app.roundCoeff);
        end

        function fmax = get.fmax(app)
            G = 10^(3/10); % Constant used by octaveFilter
            switch app.bandwidthType
                case '1 octave'
                    fmax = app.centroidFrequency * G^(1/2);
                case '1/3 octave'
                    fmax = app.centroidFrequency * G^(1/6);   
                otherwise
                    fmax = app.centroidFrequency * G^(1/2);
            end
            fmax = round(fmax, app.roundCoeff);
        end

        function roundCoeff = get.roundCoeff(app)
            if app.centroidFrequency <= 10
                roundCoeff = 2; 
            elseif app.centroidFrequency <= 100
                roundCoeff = 1; 
            elseif app.centroidFrequency <= 1000
                roundCoeff = 0; 
            elseif app.centroidFrequency <= 10000
                roundCoeff = -1; 
            elseif app.centroidFrequency <= 100000
                roundCoeff = -2; 
            else 
                roundCoeff = -3; 
            end
        end

        function label = get.trafficIntensityLabel(app)
            switch app.Simulation.noiseEnvironment.wenzModel.trafficIntensity
                case 0
                    label = 'Quiet';
                case 1 
                    label = 'Low';
                case 2 
                    label = 'Medium';
                case 3
                    label = 'Heavy';
            end
        end
    end 
end