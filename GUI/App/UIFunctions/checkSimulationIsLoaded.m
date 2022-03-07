function isLoaded = checkSimulationIsLoaded(app)
    
    if app.Simulation.simuIsLoaded
        isLoaded = 1;
    else 
        uialert(app.Figure, 'No simulation loaded. Please load a simulation to use plotting tools.', ...
            'No simulation loaded.', 'Icon', 'Warning', 'CloseFcn', @alertCallback);
        isLoaded = 0;
    end

    function alertCallback(src, event)
        uiresume(app.Figure)
    end
end

