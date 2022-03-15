function flag = runSimulation(obj)
    tStart = tic; % Start time 
    cd(obj.rootApp) % In order to avoid further issues when the program previously failed 
    
    % Create result folders
    obj.launchDate = datestr(now,'yyyymmdd_HHMM');
    if ~exist(obj.rootSaveInput, 'dir'); mkdir(obj.rootSaveInput);end
    if ~exist(obj.rootSaveResult, 'dir'); mkdir(obj.rootSaveResult);end
    if ~exist(obj.rootOutputFiles, 'dir'); mkdir(obj.rootOutputFiles);end
    if ~exist(obj.rootOutputFigures, 'dir'); mkdir(obj.rootOutputFigures);end

    d = uiprogressdlg(obj.appUIFigure,'Title','Please Wait',...
                    'Message','Loading bathymetry...', ...
                    'Cancelable', 'on', ...
                    'ShowPercentage', 'on');

    obj.getBathyData();
    
    d.Message = 'Checking python configuration...';
    obj.setPythonEnv()

    d.Message = 'Downloading T, S, pH data from CMEMS...';
    obj.setOceanEnvironment()     
    
    if obj.oceanEnvironment.connectionFailed
        options = {'Yes, continue with default values', 'No, cancel simulation'};
        msg = sprintf(['Connection to CMES failed. ' ...
                    'Please ensure you are correctly connected to internet. ' ...
                    'Do you want to continue with default values:\n' ...
                    'T = %.1fC°, S = %.1fppt, pH = %.1f'], obj.oceanEnvironment.defaultTemperatureC, ...
                    obj.oceanEnvironment.defaultSalinity, obj.oceanEnvironment.defaultpH);
        title = 'Connection failed';
        selection = uiconfirm(obj.appUIFigure, ...
                    msg, title, ...
                    'Options', options, ...
                    'DefaultOption', 1, ...
                    'CancelOption', 2);
        switch selection
            case options{1}
                obj.oceanEnvironment.setOfflineDefaultConfig()
            otherwise
                obj.writeLogCancelAfterConnectionFailed()
                flag = 0;
                return
        end
    end
    fprintf('-----------------------------------------------------------\n');

    d.Message = 'Setting up the environment...';
    obj.setSource();

    % Initialize list of detection ranges 
    obj.listDetectionRange = zeros(size(obj.listAz));

    flag = 0; % flag to ensure the all process as terminate without error
    flagBreak = 0; % flag to write msg in log file when user cancel the simulation
    
    % Initialize T_totElapsed mooving avegare 
    T_totElapsed = 0;

    for i_theta = 1:length(obj.listAz)
        theta = obj.listAz(i_theta);
        
        % Starting time for current iteration 
        t0 = tic;

        % Check for Cancel button press
        if d.CancelRequested
            flagBreak = ~flagBreak;
%             fprintf('Execution canceled by user.')
            break
        end

        % Update progress bar
        d.Value = i_theta/length(obj.listAz);
        if i_theta == 1
            d.Message = sprintf(['Computing detection range for azimuth = %2.1f° ...\n', ...
                    'Estimating time remaining ...'], theta);
        else 
            
            if T_remaining >= 3600
                fprintf('About %dh and %dmin remaining\n', Tr.hour, Tr.min)
                d.Message = sprintf(['Computing detection range for azimuth = %2.1f° ...', ...
                                '\nAbout %dh and %dmin remaining'], theta, Tr.hour, Tr.min);
            elseif T_remaining >= 60
                fprintf('About %dmin remaining\n', Tr.min)
                d.Message = sprintf(['Computing detection range for azimuth = %2.1f° ...', ...
                                '\nAbout %dmin remaining'], theta, Tr.min);
            else
                fprintf('Less than 1 min remaining\n')
                d.Message = sprintf(['Computing detection range for azimuth = %2.1f° ...', ...
                                '\nLess than 1 min remaining'], theta);
            end
            
        end
        nameProfile = sprintf('%s-%2.1f', obj.mooring.mooringName, theta);

        % Bathy
        bathyProfile = getBathyProfile(obj, theta);
        obj.writeBtyFile(nameProfile, bathyProfile)

        % Env
        obj.setBottom();
        obj.setSsp(bathyProfile, i_theta);
        obj.setBeambox(bathyProfile);
        obj.setReceiverPos(bathyProfile);                
        obj.writeEnvironment(nameProfile)

        % Write log header 
        if i_theta == 1; obj.writeLogHeader; end

        % Run
        obj.runBellhop(nameProfile)

        % Plots - removed from 03/03/2022 to save memory
%                 saveBool = true;
%                 bathyBool = true;
%                 obj.plotTL(nameProfile, saveBool, bathyBool)
%                 obj.plotSPL(nameProfile, saveBool, bathyBool)
%                 obj.plotSE(nameProfile, saveBool, bathyBool)
        
        % Derive detection range for current profile and add it to
        % the list of detection ranges 
        % The list of detection function is initialized inside the
        % loop because the range size is needed. Preallocation
        % increase performances. 
        if i_theta == 1
            obj.listDetectionFunction = zeros([numel(obj.listAz), numel(obj.receiverPos.r.range)]);
            obj.readOutputGrid(nameProfile) % read rt and zt vectors 
        end 
        obj.addDetectionFunction(nameProfile)

        fprintf('-----------------------------------------------------------\n');

        % Switch flag when the all process is over with no problem 
        if i_theta == length(obj.listAz); flag = ~flag; end 
        
        % Evaluating computing time of current iteration
        t_it = toc(t0);
        T_totElapsed = T_totElapsed + t_it;
        T_averageIteration = T_totElapsed / i_theta; % Average computing time 
        % Estimating remaining time 
        T_remaining = T_averageIteration * (numel(obj.listAz) - i_theta);
        Tr = secondToMinuteHour(T_remaining);
    end   
    
    if flag % The all process terminated without any error 
        % Plot detection range (polar plot and map) 
        obj.plotDRM('app')
        % Plot detection probability 
        obj.plotDPM('app')
        % Write CPU time to the log file 
        obj.CPUtime = toc(tStart);
        obj.writeLogEnd()
        % Delete prt and env files when all process is done to save memory
        obj.deleteBellhopFiles()
        % Delete bathymetry files 
        obj.deleteBathyFiles
        % Simulation is considered loaded 
        obj.simuIsLoaded = 1; 
        
    elseif flagBreak % The process has been interrupted by the user clicking cancel 
        obj.writeLogCancel()

    else % The process stoped because of an internal error 
        % Write error message to log file  
        obj.writeLogError()
    end
    
    % Write log content in console 
    cd(obj.rootSaveResult)
    lines = readlines("log.txt");
    fprintf('\n\n############\nLOG REPORT\n############\n\n')
    fprintf('%s\n', lines)
%     disp(lines)
    cd(obj.rootApp)

    % Close dialog box
    close(d) 

end