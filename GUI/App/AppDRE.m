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
            % Folders to store files 
            app.Simulation.rootResult = fullfile(rootApp, 'Output');
            app.Simulation.rootSaveSimulation = fullfile(rootApp, 'Simulation');
            app.Simulation.rootSources = fullfile(rootApp, 'Source');
            
            % Create folders 
            if ~exist(app.Simulation.rootResult, 'dir'); mkdir(app.Simulation.rootResult);end
            if ~exist(app.Simulation.rootSaveSimulation, 'dir'); mkdir(app.Simulation.rootSaveSimulation);end
            if ~exist(app.Simulation.rootSources, 'dir'); mkdir(app.Simulation.rootSources);end
            
            %% UI
            % Create main window 
            app.mainWindow = mainUI(app.Simulation);
            % Pass figure to the simulation for progress bar interactivity 
            app.Simulation.appUIFigure = app.mainWindow.Figure;
        end
    end

end 