classdef plot2DUI < handle
    %PLOT2DUI Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % Simulation handle 
        Simulation
        % Graphics handles
        Figure
%         GridLayout
        ButtonGroup
        ListButtons
        handleLabel
        handleEditField
        handleDropDown
        handleButton
        % Name of the window 
        Name = "2D plotting tools";
        % Icon 
        Icon = 'Icons\plot2D-icon.png'
    end
    
    properties (Dependent)
        % Position of the main figure 
        fPosition 

        % Offsets for components position
        OffsetX 
        OffsetY

        % Dimensions of the button group 
        bgWidth
        bgHeight
        % Position of the button group 
        bgX
        bgY
        bgPosition

        % Step between buttons
        bStep
        % Dimensions of buttons
        bWidth
        bHeight
        % Position of the button
        bPosition

        % Label dimension
        lWidth
        % Label position
        lStep 
        lX
        lY
        lPosition
    end 

    properties (Hidden=true)
        % Size of the main window 
        Width = 350;
        Height = 400;
        % Define font style
        FontSize = 12;
        FontName = 'Arial';
        % Number of buttons to display in main window
        nbButton = 8;
        currButtonID = 0;

        % Sub-windows 
        subWindows = {};
    end
    
    %% Constructor
    methods
        function app = plot2DUI(simulation) 
            % Pass simulation handle 
            app.Simulation = simulation;
            % Figure 
            app.Figure = uifigure('Name', app.Name, ...
                            'Icon', app.Icon, ...
                            'Visible', 'on', ...
                            'NumberTitle', 'off', ...
                            'Position', app.fPosition, ...
                            'Toolbar', 'none', ...
                            'MenuBar', 'none', ...
                            'Resize', 'on', ...
                            'AutoResizeChildren', 'off', ...
                            'WindowStyle', 'modal', ...
                            'CloseRequestFcn', @closeWindowCallback);
            % Resize function must be defined after Figure is define 
            app.Figure.SizeChangedFcn = @app.resizeWindow;

            % Button group 
            app.ButtonGroup = uibuttongroup(app.Figure, ...
                                    'Position', app.bgPosition,...
                                    'Units', 'normalized');

            % Buttons

            app.addButton('Plot Bathymetry 2D',  {@app.plot2D, 'bathy2D'})
            app.addButton('Plot TL 2D', {@app.plot2D, 'tl2D'})
            app.addButton('Plot SPL 2D', {@app.plot2D, 'spl2D'})
            app.addButton('Plot SE 2D',  {@app.plot2D, 'se2D'})
            app.addButton('Plot detection probability map',  {@app.plot2D, 'DPM'})
            app.addButton('Plot detection range map',   {@app.plot2D, 'DRM'})
            app.addButton('Plot detection range polarplot',   {@app.plot2D, 'DRPP'})

            app.addButton('Previous menu', {@app.goBackToPlottingToolsUI})
        end
    end

    methods
        function addButton(app, name, callbackFunction)
            button = uibutton(app.ButtonGroup, ...
                        'Text', name, ...
                        'Position', app.bPosition, ...
                        'ButtonPushedFcn', callbackFunction);
            app.currButtonID = app.currButtonID + 1;
            app.ListButtons = [app.ListButtons, button];
        end
    end

    %% Callback functions 
    methods 
        function goBackToPlottingToolsUI(app, hObject, eventData)
            % Close UI
            delete(app.Figure)
        end

        function resizeWindow(app, hObject, eventData)
            currentPos = get(app.Figure, 'Position');
            app.Width = currentPos(3);
            app.Height = currentPos(4);
            pause(0.01) % To avoid freeze ending in visuals bugs           
            app.updateButtons()
        end

        function updateButtons(app)
            for i_b = 1:length(app.ListButtons)
                button = app.ListButtons(i_b);
                app.currButtonID = i_b-1;
                set(button, 'Position', app.bPosition)
            end
        end
    end

    %% Plot functions
    methods
        function plot2D(app, hObject, eventData, type)
            isLoaded = checkSimulationIsLoaded(app);
            if isLoaded
                figure;
                varargin = {'user', app.Figure}; % To show process bar when gridding data in order to avoid multiple calls to plot functions
                switch type
                    case 'DPM'
                        app.Simulation.plotDPM(varargin{:});  
                    case 'DRM'
                        app.Simulation.plotDRM(varargin{:})
                    case 'DRPP'
                        app.Simulation.plotDRPP(varargin{:})
                    case 'bathy2D'
                        app.Simulation.plotBathy2D(varargin{:})    
                    case 'tl2D'
                        app.Simulation.plotTL2D(varargin{:})
                    case 'spl2D'
                        app.Simulation.plotSPL2D(varargin{:})
                    case 'se2D'
                        app.Simulation.plotSE2D(varargin{:})
                end
            end
        end

    end

    %% Get methods 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end
        
        function OffX = get.OffsetX(app)
            OffX = app.Width / 10;
        end

        function OffY = get.OffsetY(app)
            OffY = app.Height/10;
        end

        function bgW = get.bgWidth(app)
            bgW = app.Width - 2 * app.OffsetX;
        end

        function bgH = get.bgHeight(app)
            bgH = app.Height - 2*app.OffsetY;
        end
        
        function bgX = get.bgX(app)
            bgX = app.Width / 2 - app.bgWidth / 2;
        end

        function bgY = get.bgY(app)
            bgY = app.OffsetY;
        end

        function bgPos = get.bgPosition(app)
            bgPos = [app.bgX, app.bgY, app.bgWidth, app.bgHeight];
        end

        function buttonStep = get.bStep(app)
            buttonStep = app.OffsetY / 5;
        end
        
        function bW = get.bWidth(app)
            bW = app.bgWidth - 2 * app.OffsetX;
        end

        function bH = get.bHeight(app)        
            bH = 1/app.nbButton * (app.bgHeight - (app.nbButton + 1) * app.bStep);
        end

        function bPos = get.bPosition(app)
            bX = app.bgWidth/2 - app.bWidth/2; % X POSITIONS OF BUTTON 
            topButtonY = app.bgHeight - app.bStep - app.bHeight;
            bY = topButtonY - app.currButtonID * (app.bHeight + app.bStep); % Y POSITIONS OF BUTTON 
            bPos = [bX, bY, app.bWidth, app.bHeight];
        end

        function lW = get.lWidth(app)
            lW = app.bgWidth;
        end

        function labelStep = get.lStep(app)
            labelStep = 1/2 * (app.Height - app.bgHeight - app.lHeight);
        end

        function lX = get.lX(app)
            lX = app.OffsetX;
        end

        function lY = get.lY(app)
            lY = app.bgHeight + app.OffsetY + app.lStep / 2;
        end

        function lPos = get.lPosition(app)
            lPos = [app.lX, app.lY, app.lWidth, app.lHeight];
        end
    end

end


