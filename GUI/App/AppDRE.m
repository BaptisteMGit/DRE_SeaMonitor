classdef AppDRE
    
    properties 
        Simulation
        mainWindow 
    end

    methods
        function app = AppDRE(defaultSimu)
            % Create main window 
            app.mainWindow = mainUI;
            % Create Simulation 
            if nargin > 0
                app.Simulation = defaultSimu;
            else
                app.Simulation = DRESimulation;
            end
            % Folder to store files 
            app.Simulation.rootResult = fullfile(pwd, 'Output');
            app.Simulation.rootInput = fullfile(pwd, 'Input');

            app.mainWindow.Simulation = app.Simulation;
            % Pass figure to the simulation for progress bar interactivity 
            app.Simulation.appUIFigure = app.mainWindow.Figure;
        end
    end

end 