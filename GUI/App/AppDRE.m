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
            app.Simulation.rootResult = fullfile(pwd, 'Output');
            app.mainWindow.Simulation = app.Simulation;
        end
    end

end 