classdef DREApp < handle
% mainUI Detection Range App 
%
% This app allows the user to configure and run detection range simulation 
%
% Baptiste Menetrier
    
    properties
        Figure                  % Graphics handles
        ButtonGroup
        
        % Name 
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
        
    end
    
    methods
        % Constructor of the class 
        function app = DREApp
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
            bg = uibuttongroup(fig, ...
                    'Position', app.bgPosition,...
                    'Units', 'normalized');

            % Buttons
            app.addButton('Configure Environment',  @configEnvironmentButtonPushed)
            app.addButton('Run DRE', @runDREButtonPushed)
            app.addButton('Plotting Tools', @plottingToolsButtonPushed)
            app.addButton('Exit App', {@exitAppButtonPushed, fig})

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
            bgH = app.Height * 2/3;
        end
        
        function bgX = get.bgX(app)
            bgX = app.Width / 2;
        end

        function bgY = get.bgY(app)
            bgY = app.Height * 1/3 + app.OffsetX;
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
            bH = 1/app.nbButton * (app.bgHeight - (app.nbButton + 1) * app.OffsetButton);
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