classdef AppDRE
    
    properties 
        Simulation
        mainWindow
        rootApp
    end

    methods
        function app = AppDRE(defaultSimu)
            %% Simulation
            % Create Simulation 
            if nargin > 0
                app.Simulation = defaultSimu;
            else
                app.Simulation = DRESimulation;
            end
            % Root from where the app is executed
            rootApp = pwd;
            app.Simulation.rootApp = rootApp;
            
            % Create folders 
            if ~exist(app.Simulation.rootResult, 'dir'); mkdir(app.Simulation.rootResult);end
            if ~exist(app.Simulation.rootSaveSimulation, 'dir'); mkdir(app.Simulation.rootSaveSimulation);end
            if ~exist(app.Simulation.rootDetectors, 'dir'); mkdir(app.Simulation.rootDetectors);end
            if ~exist(app.Simulation.rootSources, 'dir'); mkdir(app.Simulation.rootSources);end
            if ~exist(app.Simulation.rootSediments, 'dir'); mkdir(app.Simulation.rootSediments);end

            
            %% UI
            % Create main window 
            app.mainWindow = mainUI(app.Simulation);
            % Pass figure to the simulation for progress bar interactivity 
            app.Simulation.appUIFigure = app.mainWindow.Figure;

            fprintf('MMDPM is ready to be used.\n')

        end
    end

end 