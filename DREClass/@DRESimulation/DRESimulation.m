 classdef DRESimulation < handle
    properties
        % Bathymetry
        bathyEnvironment      
        % Mooring 
        mooring 
        % Marine mammal to simulate 
        marineMammal
        % Detector 
        detector
        % Ocean
        oceanEnvironment  % Handle ocean parameters (Temperature, Salinity, pH) 
        % Ambient noise
        noiseEnvironment  % Handle ambient noise level parameters (value, computation methods, frequency, BW, soundFile)          
        % Seabed
        seabedEnvironment
        % Simulation
        bellhopEnvironment
        % Azimuths 
        listAz
        % Output
        listDetectionRange
        listDetectionFunction
        % Root used to launch app 
        rootApp
        % Running date 
        launchDate

        % Implemented detectors 
        implementedDetectors
        % Implemented sources 
        implementedSources
        % Implemented sediments
        implementedSediments

        % CPU time 
        CPUtime
        % Bathymetry data (not hidden to be saved when clicking save)
        dataBathy
        % Receiver position 
        receiverPos
        % Output grid 
        zt
        rt 

        % Threshold that can be used to derived detection range from
        % detection function (detection probability along profile) 
        availableDRThreshold = {'25%', '50%', '75%', '99%'};
        detectionRangeThreshold = '50%';
        % OffAxisDistribution
        availableOffAxisDistribution = {'Uniformly distributed on a sphere', 'Near on-axis'}
        offAxisDistribution = 'Uniformly distributed on a sphere';
        % OffAxisAttenuation
        availableOffAxisAttenuation = {'Broadband', 'Narrowband'}
        offAxisAttenuation = 'Narrowband';
        % std for head mouvement used when considering narrowband model 
        sigmaH = 15; % [°]

    end
    
    properties (Hidden)
        % Bellhop parameters 
        bottom
        ssp

        % Bathy grid variables to avoid multiple call to griddata function
        % when plotting results
        bathyDataIsGridded = 0; % Boolean to check if data is allready gridded
        Xgrid
        Ygrid
        Zgrid

        % TL grid data to avoid multiple call to griddata function 
        TLDataIsGridded = 0; % Boolean to check if data is allready gridded
        TLgrid
        % Color bar limits 
        tlmin
        tlmax 
        
        % DP grid data to avoid multiple call to griddata function 
        DPDataIsGridded = 0; % Boolean to check if data is allready gridded
        DPgrid

        % Figure for the app 
        appUIFigure 
        %Ssp 
        SoundCelerity

        % Boolean to check if simu is loaded 
        simuIsLoaded = 0;
        
    end

    properties (Dependent, Hidden=true)
        rootSaveResult 
        rootOutputFiles
        rootOutputFigures       
        rootSaveInput

        logFile % log File to save logs
        resultFile % 
        cwa % Attenuation coef 

        maxBathyDepth

        % Boxes 
        bBox % Boundary box in WGS84 coordinates 
        bBoxENU % Boundary box in ENU coordinates 
        tBox % Time box
        dBox % Depth box 
        
        % Available detectors that can be selected by the user 
        availableDetectors
        % Available sources that can be selected by the user 
        availableSources
        % Available sediments that can be selected by the user 
        availableSediments

        % Root to bellhop.exe
        rootToBellhop 
        
        % Folder for user-defined config 
        rootUserConfiguration;
        % Folder to store Simulation objects 
        rootSaveSimulation
        % Folder to store custom detectors
        rootDetectors
        % Folder to store custom sources 
        rootSources
        % Folder to store custom sediment
        rootSediments
        % Folder to save the result 
        rootResult 

        % Bearing step 
        bearingStep
    end

    %% Constructor 
    methods
        function obj = DRESimulation(bathyEnv, moor, mammal, det, bellhopEnv)

            obj.setDefault() 

            % Bathy env 
            if nargin >= 1; obj.bathyEnvironment = bathyEnv; end               
            % Mooring
            if nargin >= 2; obj.mooring = moor; end
            % Mammal
            if nargin >= 3; obj.marineMammal = mammal; end
            % Detector
            if nargin >= 4; obj.detector = det; end
            % Bellhop env
            if nargin >= 5; obj.bellhopEnvironment  = bellhopEnv; end
                       
        end
    end 
    
    methods 
        function setDefault(obj)
            obj.bathyEnvironment = BathyEnvironment;
            obj.mooring = Mooring;
            obj.marineMammal = Porpoise;
            obj.detector = CPOD; 
            obj.noiseEnvironment = NoiseEnvironment;
            obj.seabedEnvironment = SeabedEnvironment;
            obj.bellhopEnvironment = BellhopEnvironment;
            obj.listAz = 0.1:10:360.1;
            obj.implementedDetectors = {'CPOD', 'FPOD', 'SoundTrap'};
            obj.implementedSources = {'Common dolphin', 'Bottlenose dolphin', 'Porpoise'};
            obj.implementedSediments = {'Boulders and bedrock', 'Coarse sediment', 'Mixed sediment', 'Muddy sand and sand', 'Mud and sandy mud'};
        end
    end 
    %% Set methods 
    methods 
        function set.marineMammal(obj, mMammal)
            if isa(mMammal, 'MarineMammal')
                    obj.marineMammal = mMammal;
                else
                    error('MarineMammal should be an object from class MarineMammal !')
            end
        end

        function set.mooring(obj, moor)
            if isa(moor, 'Mooring')
                obj.mooring = moor;
            else
                error('Mooring should be an object from class Mooring !')
            end
        end

        function set.bathyEnvironment(obj, bathyEnv)
            if isa(bathyEnv, 'BathyEnvironment')
                obj.bathyEnvironment = bathyEnv;
            else
                error('Bathymetry environment should be an object from class BathyEnvironment !')
            end
        end

        function set.bellhopEnvironment(obj, bellhopEnv)
            if isa(bellhopEnv, 'BellhopEnvironment')
                obj.bellhopEnvironment = bellhopEnv;
            else
                error('Bellhop environment should be an object from class BellhopEnvironment !')
            end
        end

        % TODO: introduce bellhopEnv check 
    end

    %% Get methods 
    methods 
        function root = get.rootSaveResult(obj)
            root = fullfile(obj.rootResult, obj.mooring.mooringName, obj.launchDate);
        end

        function root = get.rootSaveInput(obj)
            root = fullfile(obj.rootSaveResult, 'inputFiles');
        end
        
        function root = get.rootOutputFiles(obj)
            root = fullfile(obj.rootSaveResult, 'bellhopFiles');
        end

        function root = get.rootOutputFigures(obj)
            root = fullfile(obj.rootSaveResult, 'figures');
        end

        function logFile = get.logFile(obj)
            logFile = fullfile(obj.rootSaveResult, 'log.txt');
        end

        function resultFile = get.resultFile(obj)
            resultFile = fullfile(obj.rootSaveResult, 'result.txt');
        end

        function cwa = get.cwa(obj)
            % NOTE: cwa is computed using the median depth in the area around the mooring 
            % - sign for positive depth toward bottom
            medianDepth = -median(obj.dataBathy(:, 3)); 
            cwa = FrancoisGarrison(...
                obj.marineMammal.signal.centroidFrequency / 1000,...
                mean(obj.oceanEnvironment.temperatureC, 'omitnan'),...
                mean(obj.oceanEnvironment.salinity, 'omitnan'),...
                medianDepth,...
                mean(obj.oceanEnvironment.pH, 'omitnan')) ;
            switch obj.bellhopEnvironment.SspOption(3)
                case 'M'
                    cwa = cwa / 1000; % Convert to dB/m
                case 'W'
                    cwa = cwa / 1000; % dB/m
                    lambda = 1500 / obj.marineMammal.signal.centroidFrequency;
                    cwa = lambda * cwa; % Convert to dB/lambda
            end
        end

        function maxDepth = get.maxBathyDepth(obj)
            depth = -obj.dataBathy(:, 3); % Positive depth toward the bottom 
            bathyDepth = depth(depth > 0); % Remove topographic points to only keep bathymetry 
            maxDepth = max(bathyDepth);
        end

        function bBox = get.bBox(obj)
            bBox = setbBoxAroundMooring(obj.mooring.mooringPos);
        end

        function bBoxENU = get.bBoxENU(obj)
            r = 2*obj.marineMammal.rMax;
            bBoxENU.E.min = -r;
            bBoxENU.E.max = +r;
            bBoxENU.N.min = -r;
            bBoxENU.N.max = +r;
        end

        function tBox = get.tBox(obj)
            tBox = gettBox(obj.mooring.deploymentDate.startDate, obj.mooring.deploymentDate.stopDate);
        end
    
        function dBox = get.dBox(obj)
            dBox = getdBox(0, obj.maxBathyDepth);
        end
        
        function availableDetectors = get.availableDetectors(obj)            
            availableDetectors = obj.implementedDetectors;
            cd(obj.rootDetectors)
            customDetectors = dir('*.mat');
            for i=1:numel(customDetectors)
                availableDetectors{end+i} = customDetectors(i).name(1:end-4);
            end
            availableDetectors{end+1} = 'New custom detector';
            availableDetectors = availableDetectors(~cellfun('isempty',availableDetectors));
            cd(obj.rootApp)
        end

        function availableSources = get.availableSources(obj)            
            availableSources = obj.implementedSources;
            cd(obj.rootSources)
            customSources = dir('*.mat');
            for i=1:numel(customSources)
                availableSources{end+i} = customSources(i).name(1:end-4);
            end
            availableSources{end+1} = 'New custom source';
            availableSources = availableSources(~cellfun('isempty',availableSources));
            cd(obj.rootApp)
        end

        function availableSediments = get.availableSediments(obj)            
            availableSediments = obj.implementedSediments;
            cd(obj.rootSediments)
            customSediments = dir('*.mat');
            for i=1:numel(customSediments)
                availableSediments{end+i} = customSediments(i).name(1:end-4);
            end
            availableSediments{end+1} = 'New custom sediment';
            availableSediments = availableSediments(~cellfun('isempty',availableSediments));
            cd(obj.rootApp)
        end

        function rootToBellhop = get.rootToBellhop(obj)
            rootToBellhop = fullfile(obj.rootApp, 'Bellhop', 'bellhop.exe');
        end

        function rootUserConfiguration = get.rootUserConfiguration(obj)
            rootUserConfiguration = fullfile(obj.rootApp, "UserConfiguration");
        end 
        function rootResult = get.rootResult(obj)
            rootResult = fullfile(obj.rootApp, 'Output');
        end 
        function rootSaveSimulation = get.rootSaveSimulation(obj)
            rootSaveSimulation = fullfile(obj.rootUserConfiguration, 'Simulation');
        end 
        function rootDetectors = get.rootDetectors(obj)
            rootDetectors = fullfile(obj.rootUserConfiguration, 'Detector');
        end
        function rootSources = get.rootSources(obj)
            rootSources = fullfile(obj.rootUserConfiguration, 'Source');
        end
        function rootSediments = get.rootSediments(obj)
            rootSediments = fullfile(obj.rootUserConfiguration, 'Sediment');
        end

        function bearingStep = get.bearingStep(obj)
            bearingStep = abs(obj.listAz(2) - obj.listAz(1));
        end
    end

    %% Simulation methods  
    methods 
        function flag = runSimulation(obj)
            % Start time 
            tStart = tic;
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
                    fprintf('Execution canceled by user.')
                    break
                end

                % Update progress bar
                d.Value = i_theta/length(obj.listAz);
                if i_theta == 1
                    d.Message = sprintf(['Computing detection range for azimuth = %2.1f° ...\n', ...
                            'Estimating time remaining ...'], theta);
                else 
                    d.Message = sprintf(['Computing detection range for azimuth = %2.1f° ...', ...
                        '\nAbout %dh and %dmin remaining'], theta, Tr.hour, Tr.min);
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
                obj.writeEnvirnoment(nameProfile)

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
%                 obj.addDetectionRange(nameProfile); % Replaced by
%                 addDetection function to use 50 % detection range 
                % Detection probability function 
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
                fprintf('About %dh and %dmin remaining\n', Tr.hour, Tr.min)
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
                % Delete prt and env files when all process is done to save memory
                obj.deleteBellhopFiles()
                % Simulation is considered loaded 
                obj.simuIsLoaded = 1; 
                
            elseif flagBreak % The process has been interrupted by the user clicking cancel 
                obj.writeLogCancel()

            else % The process stoped because of an internal error 
                % Write error message to log file  
                obj.writeLogError()
            end
        end

        function recomputeDRE(obj)
            % Start time 
            tStart = tic;
            
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
                obj.plotDR()
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

        function getBathyData(obj)
            promptMsg = 'Loading bathymetry dataset';
            fprintf(promptMsg);
            % Query subset data from GEBCO global grid 
            if strcmp(obj.bathyEnvironment.source, 'GEBCO2021')
                bathyFile = extratBathybBoxFromGEBCOGlobal(obj.bBox, obj.rootSaveInput);
                obj.bathyEnvironment.rootBathy = obj.rootSaveInput;
                obj.bathyEnvironment.bathyFile = bathyFile;
                obj.bathyEnvironment.bathyFileType = 'NETCDF';
                obj.bathyEnvironment.inputCRS = 'WGS84';
                obj.bathyEnvironment.drBathy = 100;
            end

            rootBathy = obj.bathyEnvironment.rootBathy;
            bathyFile = obj.bathyEnvironment.bathyFile;
            
            fileCSV = 'Bathymetry.csv';
            if strcmp(obj.bathyEnvironment.bathyFileType, 'CSV') % File is a csv
                % Copy to input folder 
                copyfile(fullfile(rootBathy, bathyFile), fullfile(obj.rootSaveInput, fileCSV))
                
            elseif strcmp(obj.bathyEnvironment.bathyFileType, 'NETCDF') % File is a netcdf
                % Convert file to csv and save it in the input folder 
                fNETCDF = fullfile(rootBathy, bathyFile);
                fCSV = fullfile(obj.rootSaveInput, fileCSV);
                bathyNETCDFtoCSV(fNETCDF, fCSV)
            end 

            obj.dataBathy = loadBathy(obj.rootSaveInput, fileCSV, obj.bBoxENU, obj.mooring.mooringPos);
            linePts = repelem('.', 53 - numel(promptMsg));
            fprintf(' %s DONE\n', linePts);
        end
        
        %% Log
        function writeLogHeader(obj)
            fileID = fopen(obj.logFile,'w');
            % Configuration 
            fprintf(fileID,'MMDPM report for simulation started on %s/%s/%s %s:%s\n\n', ...
                obj.launchDate(1:4), obj.launchDate(5:6), obj.launchDate(7:8), obj.launchDate(10:11), obj.launchDate(11:12));

            fprintf(fileID, 'Equipment\n\n');
            fprintf(fileID,'\tName: %s\n', obj.mooring.mooringName);
            fprintf(fileID,'\tDeployment: %s to %s\n', obj.mooring.deploymentDate.startDate, obj.mooring.deploymentDate.stopDate);
            fprintf(fileID,'\tPosition: lon %4.4f°, lat %4.4f°, hgt %4.4fm\n', obj.mooring.mooringPos.lon, obj.mooring.mooringPos.lat, obj.mooring.mooringPos.hgt);
            fprintf(fileID,'\tHydrophone: %s\n', obj.detector.name);
            fprintf(fileID, '\tDetection threshold: %3.2f dB\n', obj.detector.detectionThreshold);
            fprintf(fileID, '__________________________________________________________________________\n\n');

            fprintf(fileID, 'Animal\n\n');
            fprintf(fileID, '\t%s emitting %s\n', obj.marineMammal.name, obj.marineMammal.signal.name);
            fprintf(fileID,'\tCentroid frequency: %d Hz\n', obj.marineMammal.signal.centroidFrequency);
            fprintf(fileID,'\tSource level: %d dB\n', obj.marineMammal.signal.sourceLevel);
            fprintf(fileID,'\tStd source level: %d dB\n', obj.marineMammal.signal.sigmaSourceLevel);
            fprintf(fileID,'\tDirectivity index: %d dB\n', obj.marineMammal.signal.directivityIndex);
            fprintf(fileID, '__________________________________________________________________________\n\n');

            fprintf(fileID, 'Simulation parameters\n\n');
            fprintf(fileID, '\tNumber of beams: %d\n', obj.bellhopEnvironment.beam.Nbeams);
            fprintf(fileID, '\tTL: %s\n', obj.bellhopEnvironment.runTypeLabel);
            fprintf(fileID, '\tBeam type: %s\n', obj.bellhopEnvironment.beamTypeLabel);
            fprintf(fileID, '\tSsp option: %s\n', obj.bellhopEnvironment.SspOption);
            fprintf(fileID, '\tAzimuth resolution: %.1f°\n', abs(obj.listAz(2)-obj.listAz(1)));
            fprintf(fileID, '__________________________________________________________________________\n\n');

            fprintf(fileID, 'Environment\n\n');
            fprintf(fileID, '\tOcean properties ');
            if obj.oceanEnvironment.connectionFailed
                fprintf(fileID, 'set to default after connection failed:\n\n');
            else
                fprintf(fileID, 'successfully downloaded from CMES (https://resources.marine.copernicus.eu/products):\n\n');
            end
            fprintf(fileID, '\tz(m)   T(C°)   S(ppt)   pH   c(m.s-1)\n');
            for i=1:numel(obj.oceanEnvironment.depth)
                fprintf(fileID, '\t%4.1f   %5.1f   %6.1f   %2.1f   %7.1f\n', ...
                    obj.oceanEnvironment.depth(i), obj.oceanEnvironment.temperatureC(i), ...
                    obj.oceanEnvironment.salinity(i), obj.oceanEnvironment.pH(i), obj.SoundCelerity(i));
            end

            fprintf(fileID, '\n\tAmbient noise level: %3.2f dB\n', obj.noiseEnvironment.noiseLevel);
            switch obj.bellhopEnvironment.SspOption(3)
                case 'M'
                    unit = 'dB/m';
                case 'W'
                    unit = 'dB/lambda';
            end
            fprintf(fileID, '\tCompression wave attenuation in the water column: %3.4f 1e-3 %s\n', obj.cwa*1000, unit);
            fprintf(fileID, '\tSediment: %s with the following properties\n', obj.seabedEnvironment.sedimentType);
            fprintf(fileID, '\t\tCompression wave celerity: %4.1f m.s-1\n', obj.seabedEnvironment.bottom.c); 
            fprintf(fileID, '\t\tCompression wave attenuation: %3.4f 1e-3 %s\n', obj.seabedEnvironment.bottom.cwa*1000, unit); 
            fprintf(fileID, '\t\tDensity: %2.2f g.cm-3\n', obj.seabedEnvironment.bottom.rho); 
            fprintf(fileID, '__________________________________________________________________________\n\n');

            fprintf(fileID, 'Estimating detection range\n\n');
            switch obj.offAxisAttenuation
                case 'Broadband'
                    fprintf(fileID, 'Directional loss approximation:\nDLbb = C1 * (C2*sin(theta)).^2 ./ (1 + abs(C2*sin(theta)) + (C2*sin(theta)).^2)\n');
                    fprintf(fileID, 'with C1 = 47, C2 = 0.218*ka, ka = 10^(DI/20)\n\n');
                case 'Narrowband'
                    fprintf(fileID, 'Directional loss approximation:\nDLnb = (2*J1(ka*sin(theta)) ./ (ka*sin(theta)) ).^2\n');
                    fprintf(fileID, 'with J1 the first-order Bessel function of the first kind and ka = 10^(DI/20)\n');
                    fprintf(fileID, 'Please note that this piston model is modified to reduced to mainly first lobe.\n');
                    fprintf(fileID, 'For more information on the exact model read the attach documentation.\n\n');
            end
            fprintf(fileID, 'Off-axis distribution: %s\n', obj.offAxisDistribution);
            switch obj.offAxisDistribution
                case 'Uniformly distributed on a sphere (random off-axis)'
                    fprintf(fileID, 'Woa = 1/2 * sin(theta)\n\n');
                case 'Near on-axis'
                    fprintf(fileID, 'Woa_h = (theta / sigmaH^2) .* exp(-1/2 * ( (theta / sigmaH).^2) )\n');
                    fprintf(fileID, 'with sigmaH = %d° (standard deviation of head angle with on-axis direction)\n\n', obj.sigmaH);
            end
            fprintf(fileID, 'Probability threshold used to derive detection range: %s\n\n', obj.detectionRangeThreshold);
            fprintf(fileID, '\tBearing (°)\tDetection range (m)\n\n');
            fclose(fileID);   
        end
        
        function writeLogError(obj)
            fileID = fopen(obj.logFile, 'a');
            fprintf(fileID, '\nExecution has failed.');
            fclose(fileID);
            fprintf('Execution has failed.\n')
        end

        function writeLogCancel(obj)
            fileID = fopen(obj.logFile, 'a');
            fprintf(fileID, '\nExecution has been canceled by user.');
            fclose(fileID);
            fprintf('Execution has been canceled by user.\n')
        end

        function writeLogCancelAfterConnectionFailed(obj)
            fileID = fopen(obj.logFile, 'a');
            fprintf(fileID, 'Execution canceled after connection to CMEMS failed.');
            fclose(fileID);
            fprintf('\nExecution canceled by user after connection to CMEMS failed.\n')
        end

        function writeDRtoLogFile(obj, theta, DT)
            fileID = fopen(obj.logFile, 'a');
            fprintf(fileID, '\t%3.2f\t%6.2f\n', theta, DT);
            fclose(fileID);
            fprintf('Bearing(°), Detection range (m): %3.2f, %6.2f\n', theta, DT);
        end

        function writeLogEnd(obj)
            fileID = fopen(obj.logFile, 'a');
            fprintf(fileID, '\tCPU Time = %6.2f s', obj.CPUtime);
            fclose(fileID);
            fprintf('CPU Time = %6.2f s', obj.CPUtime)
        end


        %% Set environment 
        function setOceanEnvironment(obj)
            obj.oceanEnvironment = OceanEnvironement(obj.mooring, obj.rootSaveInput, obj.bBox, obj.tBox, obj.dBox); % setup ocean parameters by querying data from CMEMS 
        end


        function setSource(obj)
            % Position of the hydrophone in the water column 
            if obj.mooring.hydrophoneDepth < 0  % If negative the position of the hydrophone if reference to the seafloor
                F = scatteredInterpolant(obj.dataBathy(:, 1), obj.dataBathy(:, 2), obj.dataBathy(:, 3));
                depthOnMooringPos = -F(0, 0); % Get depth on mooring position ("-" to get depth positive toward the bottom)
                obj.receiverPos.s.z = depthOnMooringPos + obj.mooring.hydrophoneDepth; % TODO: check 
            else
                obj.receiverPos.s.z = obj.mooring.hydrophoneDepth; % TODO: check 
            end
        end

        function obj = setBeambox(obj, bathyProfile)
            obj.bellhopEnvironment.beam.Box.z = max(obj.ssp.z) + 10; % zmax (m), larger than SSP max depth to avoid problems  
            obj.bellhopEnvironment.beam.Box.r = max(bathyProfile(:, 1)) + 0.1; % rmax (km), larger than bathy max range to avoid problems
        end

        function setBottom(obj)
            % Bottom properties 
            obj.bottom = obj.seabedEnvironment.bottom;
        end

        function setSsp(obj, bathyProfile, i_theta)
            % TODO: replace by importation function call to get SSP
%             Ssp.z = 0:2:obj.maxBathyDepth;
            Ssp.z = obj.oceanEnvironment.depth;

            % Compute SoundCelerity at mooringPos (only one time to
            % limit computing effort)
            if i_theta == 1 
                obj.SoundCelerity = MackenzieSoundSpeed(obj.oceanEnvironment.depth, obj.oceanEnvironment.salinity, obj.oceanEnvironment.temperatureC);
            end

            Ssp.c = obj.SoundCelerity;
            Ssp.cwa = repelem(obj.cwa, numel(Ssp.z)); 
            if max(Ssp.z) < max(bathyProfile(:, 2)) % Check that bathy doesn't drop below lowest point in the sound speed profile
                Ssp.z(end+1) = floor(max(bathyProfile(:, 2))) + 1;   
                Ssp.c(end+1) = Ssp.c(end);          % Extend ssp 
                Ssp.cwa(end+1) = Ssp.cwa(end);
            end
            obj.ssp = Ssp;

            if i_theta == 1; obj.plotSsp; end
        end
        
        function setReceiverPos(obj, bathyProfile)
                % Receivers
                obj.receiverPos.r.range = 0:obj.bellhopEnvironment.drSimu:max(bathyProfile(:, 1)); % Receiver ranges (km)
                obj.receiverPos.r.z = 0:obj.bellhopEnvironment.dzSimu:max(bathyProfile(:, 2)); % Receiver depths (m)  
        end

        function bathyProfile = getBathyProfile(obj, theta)
            promptMsg = sprintf('Bathymetry profile extraction for azimuth = %3.1f°', theta);
            fprintf(promptMsg)
            rootBathy = obj.bathyEnvironment.rootBathy;
            bathyFile = obj.bathyEnvironment.bathyFile;
            drBathy = obj.bathyEnvironment.drBathy;
            rMax = obj.marineMammal.rMax;
            data = obj.dataBathy;

            varGetProfile = {'rootBathy', rootBathy, 'bathyFile', bathyFile, 'CRS', 'ENU', 'dr', drBathy, 'data', data, 'theta', theta, 'rMax', rMax};
            bathyProfile = getBathy2Dprofile(varGetProfile{:});
            bathyProfile = table2array(bathyProfile);
            linePts = repelem('.', 53 - numel(promptMsg));
            fprintf(' %s DONE\n', linePts);
        end
        
        %% Write environment files 
        function writeBtyFile(obj, nameProfile, bathyProfile)
%             nameProfile = sprintf('%s%2.1f', obj.mooring.mooringName, theta);
            BTYfilename = sprintf('%s.bty', nameProfile);
            promptMsg = sprintf('Writing %s', BTYfilename);
            fprintf(promptMsg)
            writebdry(fullfile(obj.rootOutputFiles, BTYfilename), obj.bellhopEnvironment.interpMethodBTY, bathyProfile)
            linePts = repelem('.', 53 - numel(promptMsg));
            fprintf(' %s DONE\n', linePts);
        end

        function writeEnvirnoment(obj, nameProfile)
            envfile = fullfile(obj.rootOutputFiles, nameProfile);
            promptMsg = sprintf('Writing %s.env', nameProfile);
            fprintf(promptMsg)

            freq = obj.marineMammal.signal.centroidFrequency;
            varEnv = {'envfil', envfile, 'freq', freq, 'SSP', obj.ssp, 'Pos', obj.receiverPos,...
                'Beam', obj.bellhopEnvironment.beam, 'BOTTOM', obj.bottom, 'SspOption', obj.bellhopEnvironment.SspOption, 'TitleEnv', nameProfile};
            writeEnvDRE(varEnv{:})
            linePts = repelem('.', 53 - numel(promptMsg));
            fprintf(' %s DONE\n', linePts);
        end

        function runBellhop(obj, nameProfile)
            promptMsg = 'Running Bellhop';
            fprintf(promptMsg)
            current = pwd;
            cd(obj.rootOutputFiles)
            cmd = sprintf('%s %s', obj.rootToBellhop, nameProfile);
            [status, cmdout] = system(cmd);           
            cd(current)
            linePts = repelem('.', 53 - numel(promptMsg));
            fprintf(' %s DONE\n', linePts);
        end

        function readOutputGrid(obj, nameProfile)
            filename = sprintf('%s.shd', nameProfile);
            cd(obj.rootOutputFiles)
            [ ~, ~, ~, ~, ~, Pos, ~] = read_shd( filename );
            obj.zt = Pos.r.z;
            obj.rt = Pos.r.r;
            cd(obj.rootApp)
        end

        %% Plot functions
%         function plotTL(obj, nameProfile, saveBool, bathyBool)
%             figure('visible','off'); 
%             cd(obj.rootOutputFiles)
%             plotshd( sprintf('%s.shd', nameProfile));
%             a = colorbar;
%             a.Label.String = 'Transmission Loss (dB ref 1\muPa)';
% 
%             if bathyBool
%                 plotbty( nameProfile );
%             end
%             
%             scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')
% 
%             if saveBool
%                 cd(obj.rootOutputFigures)
%                 saveas(gcf, sprintf('%s_TL.png', nameProfile));
%             end
%             close(gcf);
%             cd(obj.rootApp)
%         end

%         function plotSPL(obj, nameProfile, saveBool, bathyBool)
%             varSpl = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};            
%             figure('visible','off');
%             cd(obj.rootOutputFiles)
%             plotSPL(varSpl{:});
%             a = colorbar;
%             a.Label.String = 'Sound Pressure Level (dB ref 1\muPa)';
% 
%             if bathyBool
%                 plotbty( nameProfile );
%             end
% 
%             scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')
% 
%             if saveBool
%                 cd(obj.rootOutputFigures)
%                 saveas(gcf, sprintf('%s_SPL.png', nameProfile));
%             end
%             close(gcf);
%             cd(obj.rootApp)
%         end
    
%         function plotSE(obj, nameProfile, saveBool, bathyBool)
%             cd(obj.rootOutputFiles)
%             varSpl = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};
%             [obj.spl, obj.zt, obj.rt] = computeSPL(varSpl{:});
%             
%             figure('visible','off');
%             SEArgin = {'SPL', obj.spl, 'Depth', obj.zt, 'Range', obj.rt, 'NL', obj.noiseEnvironment.noiseLevel,...
%                 'DT', obj.detector.detectionThreshold, 'zTarget', obj.marineMammal.livingDepth, 'deltaZ', obj.marineMammal.deltaLivingDepth};
%             plotSE(SEArgin{:});
%             title(sprintf('Signal excess - %s', nameProfile), 'SE = SNR - DT')    
% 
%             if bathyBool
%                 plotbty( nameProfile );
%             end
% 
%             scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')
% 
%             if saveBool
%                 cd(obj.rootOutputFigures)
%                 saveas(gcf, sprintf('%s_SE.png', nameProfile));
%             end
%             close(gcf);
%             cd(obj.rootApp)
%         end

        function plotDR(obj)
            % Limit
            Rmax = max(obj.listDetectionRange);
%             offset = 100;
%             R = Rmax + offset;
            %%% Polar plot %%% 
            figure
            polarplot(obj.listAz * pi / 180, obj.listDetectionRange)
            ax = gca;
            ax.RLim = [0, Rmax+50];
            % Save 
            saveas(gcf, fullfile(obj.rootOutputFigures, sprintf('%s_polarDREstimate.png', obj.mooring.mooringName)));
            
            %%% Map plot %%% 
            figure
            E = obj.dataBathy(:,1);
            N = obj.dataBathy(:,2);
            U = obj.dataBathy(:,3);
            pts = 1E+3;

            xGrid = linspace(-(Rmax+500), Rmax+500, pts);
            yGrid = linspace(-(Rmax+500), Rmax+500, pts);   
            [X,Y] = meshgrid(xGrid, yGrid);
            zDep = griddata(E, N, U, X, Y);

            pcolor(X, Y, zDep)
            shading flat
            hold on 
            contour(X, Y, zDep, 'k', 'ShowText','on', 'LabelSpacing', 1000)
            setBathyColormap(zDep)
            hold on 
            scatter(0, 0, 'filled', 'red') 

            title('Simulated detection range')
            xlabel('E [m]')
            ylabel('N [m]')

            [xx, yy] = pol2cart(obj.listAz * pi/180, obj.listDetectionRange);
            plot(xx, yy, 'k', 'LineWidth', 2)
            legend({'', '', 'Mooring', sprintf('%s detection range', obj.detectionRangeThreshold)})
            % Save 
            saveas(gcf, fullfile(obj.rootOutputFigures, sprintf('%s_DREstimate.png', obj.mooring.mooringName)));
        end
        
        function plotBathyENU(obj)
            E = obj.dataBathy(:,1);
            N = obj.dataBathy(:,2);
            U = obj.dataBathy(:,3);
            pts = 1E+3;
            xGrid = linspace(min(E), max(E), pts);
            yGrid = linspace(min(N), max(N), pts);
            [X,Y] = meshgrid(xGrid, yGrid);
            zDep = griddata(E, N, U, X, Y);

            pcolor(X, Y, zDep)
            shading flat
            hold on 
            contour(X, Y, zDep, 'k', 'ShowText','on', 'LabelSpacing', 1000)
            setBathyColormap(zDep)
            hold on 
            scatter(0, 0, 'filled', 'red') 

            title('Simulated detection range')
            xlabel('E [m]')
            ylabel('N [m]')
        end

        function plotSsp(obj)
            figure('visible','off');
            plot(obj.ssp.c, obj.ssp.z)
            xlabel('Celerity (m.s-1)')
            ylabel('Depth (m)')
            title({'Celerity profile at the mooring position', 'Derived with Mackenzie equation'})
            set(gca, 'YDir', 'reverse')
            saveas(gcf, fullfile(obj.rootSaveInput, 'CelerityProfile.png'))
            close(gcf)
        end
        
        function plotDetectionFunction(obj, nameProfile, detectionFunction, detectionRange)            
            figure('visible','off');
            plot(obj.rt, detectionFunction)
            xlabel('Range [m]')
            ylabel('Detection probability')
            hold on 
            yline(str2double(obj.detectionRangeThreshold(1:end-1))/100, '--r', 'LineWidth', 1, 'Label', sprintf('%s detection threshold', obj.detectionRangeThreshold))
            hold on 
            xline(detectionRange, '--g', 'LineWidth', 1, 'Label', sprintf('%s detection range = %dm', obj.detectionRangeThreshold, round(detectionRange, 0)),...
                'LabelOrientation', 'horizontal', 'LabelVerticalAlignment', 'top')
            title({sprintf('Detection function - %s', nameProfile)})

            current = pwd;
            cd(obj.rootOutputFigures)
            saveas(gcf, sprintf('%s_DetectionFunction.png', nameProfile));
            close(gcf);
            cd(current)
        end

        
        %% Plotting tools functions
        %%% 1D plots %%%%
        plotBathy1D(obj, nameProfile)
        plotTL1D(obj, nameProfile)
        plotSPL1D(obj, nameProfile)
        plotSE1D(obj, nameProfile)
        %%% End 1D plots %%%%
        
        %%% 2D plots (map) %%%
        % Grid data
        gridTLData(obj) % Transmission loss (BELLHOP)
        gridBathyData(obj) % Bathymetry (GEBCO)
        gridDPData(obj) % Detection probability (App) 
        
        % Plot bathy
        plotBathyContour(obj)
        plotBathyPColor(obj)
        
        % Plot detection results 
        radiusToPlot = getRadiusToPlot(obj) 
        plotDetectionRangeContour(obj, varargin) 
        plotDPM(obj) % Detection probability map 
        plotDRM(obj) % Detection range map 
        plotDRPP(obj) % Detection range polarplot
        
        % Plot 2D maps 
        plotBathy2D(obj) % Bathy 2D
        plotTL2D(obj) % Plot TL 2D
        plotSPL2D(obj) % Plot SPL 2D
        plotSE2D(obj) % Plot SE 2D

        %% Derive detection capabilities 
        addDetectionRange(obj, nameProfile)
        addDetectionFunction(obj, nameProfile)

        %% Delete useless files to spare memory 
        deleteBellhopFiles(obj)
        deleteBathyFiles(obj)

    end
end









 