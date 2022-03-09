function recomputeDRE(obj)
    tStart = tic; % Start time 
    
    oldRootSaveResult = obj.rootSaveResult;
    oldLaunchDate = obj.launchDate;

    % Create new result folder
    obj.launchDate = datestr(now,'yyyymmdd_HHMM');
    if strcmp(oldLaunchDate, obj.launchDate)
        obj.launchDate(end) = num2str(str2double(obj.launchDate(end)) + 1); 
    end

    if ~exist(obj.rootSaveResult, 'dir'); mkdir(obj.rootSaveResult);end

    % Copy all files to the new folder 
    copyfile(oldRootSaveResult, obj.rootSaveResult)

    d = uiprogressdlg(obj.appUIFigure,'Title','Please Wait',...
                    'Message','Recomputing detection range with new parameters...', ...
                    'Cancelable', 'on', ...
                    'ShowPercentage', 'on');

    % Initialize list of detection ranges 
    obj.listDetectionRange = zeros(size(obj.listAz));

    flag = 0; % flag to ensure the all process as terminate without error
    flagBreak = 0; % flag to write msg in log file when user cancel the simulation

    for i_theta = 1:length(obj.listAz)
        theta = obj.listAz(i_theta);

        % Check for Cancel button press
        if d.CancelRequested
            flagBreak = ~flagBreak;
            break
        end

        % Update progress, report current estimate
        d.Value = i_theta/length(obj.listAz);
        d.Message = sprintf('Computing detection range for azimuth = %2.1f° ...', theta);

        nameProfile = sprintf('%s-%2.1f', obj.mooring.mooringName, theta);

        % Write log header 
        if i_theta == 1
            obj.writeLogHeader()
        end

        % Derive detection range for current profile and add it to
        % the list of detection ranges 
%                 obj.addDetectionRange(nameProfile); % Replaced by
%                 addDetection function to use 50 % detection range 
        % Detection probability function 
        obj.addDetectionFunction(nameProfile)

        % Switch flag when the all process is over with no problem 
        if i_theta == length(obj.listAz); flag = ~flag; end 
    end   
    
    close(d)
    if flag % The all process terminated without any error 
        % Plot detection range (polar plot and map) 
        obj.plotDRM()
        % Plot detection probability 
        obj.plotDPM()
        % Write CPU time to the log file 
        obj.CPUtime = toc(tStart);
        obj.writeLogEnd()

    elseif flagBreak % The process has been interrupted by the user clicking cancel 
        obj.writeLogCancel()

    else % The process stoped because of an internal error 
        % Write error message to log file  
        obj.writeLogError()
    end
end