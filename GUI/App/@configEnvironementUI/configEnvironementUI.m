classdef configEnvironementUI < handle
% configEnvironementUI: App window dedicated to the configuration of the
% simulation environment 
%
% Baptiste Menetrier    

    properties
        % Graphics handles
        Figure
        GridLayout 
        % Name of the window 
        Name = "Configure environment";
    end 
    
    properties (Dependent)

        % Position of the main figure 
        fPosition 
    end

    properties (Hidden=true)
        % Size of the main window 
        Width = 600;
        Height = 500;
        % 
        glNRow = 15;
        glNCol = 3;
    end
    
    %% Constructor of the class 
    methods       
        function app = configEnvironementUI
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
            
            % Grid Layout
            app.GridLayout = uigridlayout(app.Figure, [app.glNRow, app.glNRow]);
            
        end
    end

    %% Get methods for dependent properties 
    methods 
        function fPosition = get.fPosition(app)
            fPosition = getFigurePosition(app);
        end
    end 
end