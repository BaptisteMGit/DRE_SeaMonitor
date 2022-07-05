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
        % SSP
        ssp

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
        hydroDepthRefToSurf % Hydrophone depth ref to the surface (positive toward bottom) 

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
        % Folder storing python Pipfile, Pipfile.lock 
        rootPythonModules
        % Folder to save the result 
        rootResult 

        % Bearing step 
        bearingStep
        
        % Mean effective detection range 
        meanDR
        % Maximum detection range - 5% probability threshold 
        maxDR 
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
        %% Main simulation methods      
        flag = runSimulation(obj) % Run simulation
        recomputeDRE(obj) % Recompute results for loaded simulation 

        %% Write info to log file 
        writeLogHeader(obj)
        writeLogError(obj)
        writeLogCancel(obj)
        writeLogCancelAfterConnectionFailed(obj)
        writeDRtoLogFile(obj, theta, DR)
        writeMeanDRtoLogFile(obj)
        writeMaxDRtoLogFile(obj)
        writeLogEnd(obj)

        %% Set environment 
        setOceanEnvironment(obj)
        setSource(obj)
        setBottom(obj)
        setBeambox(obj, bathyProfile)
        setReceiverPos(obj, bathyProfile)
        setSsp(obj, bathyProfile, i_theta)

        %% Divers
        setDefault(obj)
        setGriddedFlags(obj)
        getBathyData(obj)
        hydroDepth = getHydrophoneDepth(obj)
        bathyProfile = getBathyProfile(obj, theta)
        runBellhop(obj, nameProfile)
        readOutputGrid(obj, nameProfile)
        
        %% Write environment files 
        writeBtyFile(obj, nameProfile, bathyProfile)
        writeEnvironment(obj, nameProfile)

        %% Plotting tools functions
        %%% 1D plots %%%%
        plotBathy1D(obj, nameProfile)
        plotTL1D(obj, nameProfile)
        plotSPL1D(obj, nameProfile)
        plotSE1D(obj, nameProfile)
        plotDetectionFunction(obj, nameProfile)
        plotSSP(obj, varargin)
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
        plotDPM(obj, varargin) % Detection probability map 
        plotDRM(obj, varargin) % Detection range map 
        plotDRPP(obj, varargin) % Detection range polarplot
        
        % Plot 2D maps 
        plotBathy2D(obj, varargin) % Bathy 2D
        plotTL2D(obj, varargin) % Plot TL 2D
        plotSPL2D(obj, varargin) % Plot SPL 2D
        plotSE2D(obj, varargin) % Plot SE 2D
        %%% End 2D plots (map) %%%

        %% Derive detection capabilities 
%         addDetectionRange(obj, nameProfile)
        addDetectionFunction(obj, nameProfile)

        %% Delete useless files to spare memory 
        deleteBellhopFiles(obj)
        deleteBathyFiles(obj)
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

        function hydroDepthRefToSurf = get.hydroDepthRefToSurf(obj)
            hydroDepthRefToSurf = obj.getHydrophoneDepth();
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

        function rootPythonModules = get.rootPythonModules(obj)
            rootPythonModules = fullfile(obj.rootApp, 'PythonModules');
        end

        function bearingStep = get.bearingStep(obj)
            bearingStep = abs(obj.listAz(2) - obj.listAz(1));
        end

        function meanDR = get.meanDR(obj)
            meanDR = mean(obj.listDetectionRange);
        end

        function maxDR = get.maxDR(obj)
            listMDR = ones(1, numel(obj.listAz));
            for idx=1:numel(obj.listAz)
                g = obj.listDetectionFunction(idx, :);
                DR = computeDetectionRange(g, obj.rt, '1%'); 
                listMDR(idx) = DR;
            end
            maxDR = mean(listMDR);
        end
    end

    
 end

% OLD VERSION BEFORE SEPARATING METHODS IN FILES (before 08/03/2022)
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

%         function plotDR(obj)
%             % Limit
%             Rmax = max(obj.listDetectionRange);
% %             offset = 100;
% %             R = Rmax + offset;
%             %%% Polar plot %%% 
%             figure
%             polarplot(obj.listAz * pi / 180, obj.listDetectionRange)
%             ax = gca;
%             ax.RLim = [0, Rmax+50];
%             % Save 
%             saveas(gcf, fullfile(obj.rootOutputFigures, sprintf('%s_polarDREstimate.png', obj.mooring.mooringName)));
%             
%             %%% Map plot %%% 
%             figure
%             E = obj.dataBathy(:,1);
%             N = obj.dataBathy(:,2);
%             U = obj.dataBathy(:,3);
%             pts = 1E+3;
% 
%             xGrid = linspace(-(Rmax+500), Rmax+500, pts);
%             yGrid = linspace(-(Rmax+500), Rmax+500, pts);   
%             [X,Y] = meshgrid(xGrid, yGrid);
%             zDep = griddata(E, N, U, X, Y);
% 
%             pcolor(X, Y, zDep)
%             shading flat
%             hold on 
%             contour(X, Y, zDep, 'k', 'ShowText','on', 'LabelSpacing', 1000)
%             setBathyColormap(zDep)
%             hold on 
%             scatter(0, 0, 'filled', 'red') 
% 
%             title('Simulated detection range')
%             xlabel('E [m]')
%             ylabel('N [m]')
% 
%             [xx, yy] = pol2cart(obj.listAz * pi/180, obj.listDetectionRange);
%             plot(xx, yy, 'k', 'LineWidth', 2)
%             legend({'', '', 'Mooring', sprintf('%s detection range', obj.detectionRangeThreshold)})
%             % Save 
%             saveas(gcf, fullfile(obj.rootOutputFigures, sprintf('%s_DREstimate.png', obj.mooring.mooringName)));
%         end
%         
%         function plotBathyENU(obj)
%             E = obj.dataBathy(:,1);
%             N = obj.dataBathy(:,2);
%             U = obj.dataBathy(:,3);
%             pts = 1E+3;
%             xGrid = linspace(min(E), max(E), pts);
%             yGrid = linspace(min(N), max(N), pts);
%             [X,Y] = meshgrid(xGrid, yGrid);
%             zDep = griddata(E, N, U, X, Y);
% 
%             pcolor(X, Y, zDep)
%             shading flat
%             hold on 
%             contour(X, Y, zDep, 'k', 'ShowText','on', 'LabelSpacing', 1000)
%             setBathyColormap(zDep)
%             hold on 
%             scatter(0, 0, 'filled', 'red') 
% 
%             title('Simulated detection range')
%             xlabel('E [m]')
%             ylabel('N [m]')
%         end











 