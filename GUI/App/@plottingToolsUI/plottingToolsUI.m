classdef plottingToolsUI < handle
    %PLOTTINGTOOLSUI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Simulation handle 
        Simulation
        % Graphics handles
        Figure                  
        ButtonGroup
        
        % Name of the window 
        Name = "Plotting Tools";
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
        Width = 300;
        Height = 400;
        % Define font style
        FontSize = 12;
        FontName = 'Arial';
        % Number of buttons to display in main window
        nbButton = 7;
        currButtonID = 0;
    end
    
    %% Constructor
    methods
        function app = plottingToolsUI            
            % Figure 
            app.Figure = uifigure('Name', app.Name, ...
                            'Visible', 'on', ...
                            'NumberTitle', 'off', ...
                            'Position', app.fPosition, ...
                            'Toolbar', 'none', ...
                            'MenuBar', 'none', ...
                            'Resize', 'on', ...
                            'AutoResizeChildren', 'off', ...
                            'WindowStyle', 'normal', ...
                            'CloseRequestFcn', @closeWindowCallback);
            
            % Button group 
            app.ButtonGroup = uibuttongroup(app.Figure, ...
                                    'Position', app.bgPosition,...
                                    'Units', 'normalized');

            % Buttons
            app.addButton('Plot Bathymetry 1D',  @app.plotBathy1D)
            app.addButton('Plot Bathymetry 2D',  @app.plotBathy2D)

            app.addButton('Plot TL 1D', @app.plotTL1D)
            app.addButton('Plot TL 2D', @app.plotTL2D)

            app.addButton('Plot SPL 1D', @app.plotSPL1D)
            app.addButton('Plot SPL 2D', @app.plotSPL2D)

            app.addButton('Main menu', {@app.goBackToMainUI})
        end
    end

    %% Set up methods 
    methods
        function addButton(app, name, callbackFunction)
            uibutton(app.ButtonGroup, ...
                'Text', name, ...
                'Position', app.bPosition, ...
                'ButtonPushedFcn', callbackFunction);
            app.currButtonID = app.currButtonID + 1;
        end
    end

    %% Callback functions 
    methods 
        function exitAppButtonPushed(app, hObject, eventData)
            hObject = app.Figure;
            closeWindowCallback(hObject, eventData)
        end
    end

    %% Get methods for dependent properties 
    % NOTE: even if the implementation looks a bit complicated dependent
    % properties increase app performance by saving memmory space and
    % dependent properties can be used to maintain app proportions 
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
%             bgY = app.Height * 1/3 + app.OffsetY - app.bgHeight / 2;
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

