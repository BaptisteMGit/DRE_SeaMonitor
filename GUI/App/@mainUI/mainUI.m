classdef mainUI < handle
% mainUI: Detection Range App main window
%
% This app allows the user to configure and run detection range simulation 
%
% Baptiste Menetrier
    
    properties
        % Simulation handle 
        Simulation
        % Graphics handles
        Figure                  
        ButtonGroup
        Label
        handleButtons

        % Name of the window 
        Name = "Detection Range Estimation";
        % App release version 
        Version = 0.1; 
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
        nbButton = 4;
        currButtonID = 0;
        
        % Label Heigth
        lHeight = 40;
        
        % Sub-windows 
        childWindow
        configEnvironmentWindow
        plottingToolsWindow
    end
    
    %% Constructor of the class 
    methods
        function app = mainUI
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
            % Resize function must be defined after Figure is define 
            app.Figure.SizeChangedFcn = @app.resizeWindow;

            
            % Button group 
            app.ButtonGroup = uibuttongroup(app.Figure, ...
                                    'Position', app.bgPosition,...
                                    'Units', 'normalized');

            % Buttons
            app.addButton('Configure Environment',  @app.configEnvironmentButtonPushed)
            app.addButton('Run DRE', @app.runDREButtonPushed)
            app.addButton('Plotting Tools', @app.plottingToolsButtonPushed)
            app.addButton('Exit App', {@app.exitAppButtonPushed})
            
            % Main label 
            app.Label = uilabel(app.Figure, ....
                        'Position', app.lPosition, ...
                        'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'center', ...
                        'Text', sprintf('Detection Range Estimation \nUser-Interface \nVersion %2.1f', app.Version));
        end
    end

    %% Set up methods 
    methods
        function addButton(app, name, callbackFunction)
            button = uibutton(app.ButtonGroup, ...
                        'Text', name, ...
                        'Position', app.bPosition, ...
                        'ButtonPushedFcn', callbackFunction);
            app.currButtonID = app.currButtonID + 1;
            app.handleButtons = [app.handleButtons, button];
        end
    end
    
    %% Callback functions 
    methods 
        function exitAppButtonPushed(app, hObject, eventData)
            hObject = app.Figure;
            closeWindowCallback(hObject, eventData)
        end

        function configEnvironmentButtonPushed(app, hObject, eventData)
            app.configEnvironmentWindow = configEnvironmentUI(app.Simulation);
%             app.configEnvironmentWindow.Simulation = app.Simulation;
            app.childWindow = [app.childWindow, app.configEnvironmentWindow];
        end

        function plottingToolsButtonPushed(app, hObject, eventData)
            app.plottingToolsWindow = plottingToolsUI;
            app.plottingToolsWindow.Simulation = app.Simulation;
            app.childWindow = [app.childWindow, app.plottingToolsWindow];
        end
        
        function runDREButtonPushed(app, hObject, eventData)
            app.Simulation.runSimulation
        end
        
        function resizeWindow(app, hObject, eventData)
            currentPos = get(app.Figure, 'Position');
            app.Width = currentPos(3);
            app.Height = currentPos(4);
            pause(0.01) % To avoid freeze ending in visuals bugs           
            app.updateLabel
%             app.updateButtonGroup
            app.updateButtons
        end

%         function updateButtonGroup(app)
%             app.ButtonGroup.Position = app.bgPosition;
%         end

        function updateButtons(app)
            for i_b = 1:length(app.handleButtons)
                button = app.handleButtons(i_b);
                app.currButtonID = i_b-1;
%                 button.Position = app.bPosition;
                set(button, 'Position', app.bPosition)
            end
        end

        function updateLabel(app)
            app.Label.Position = app.lPosition;
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
            bgH = app.Height * 2/3;
        end
        
        function bgX = get.bgX(app)
            bgX = app.Width / 2 - app.bgWidth / 2;
        end

        function bgY = get.bgY(app)
            bgY = app.Height * 1/3 + app.OffsetY - app.bgHeight / 2;
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
            bX = app.bgWidth/2 - app.bWidth/2; % X Position of button
            topButtonY = app.bgHeight - app.bStep - app.bHeight;
            bY = topButtonY - app.currButtonID * (app.bHeight + app.bStep); % Y Position of button 
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