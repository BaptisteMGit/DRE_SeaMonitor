 classdef DRESimulation < handle
    properties
        % Bathymetry
        bathyEnvironment = BathyEnvironment;        
        % Mooring 
        mooring = Mooring;
        % Marine mammal to simulate 
        marineMammal = CommonBottlenoseDolphin;
        % Detector 
        detector = CPOD; 
        % Env parameters
        oceanEnvironment  % Handle ocean parameters (Temperature, Salinity, pH) 
        noiseLevel
        % Simulation
        drSimu = 0.01;                      % Range step (km) between receivers: more receivers increase accuracy but also increase CPU time 
        dzSimu = 0.5;                       % Depth step (m) between receivers: more receivers increase accuracy but also increase CPU time
        % Bellhop parameters 
        listAz = 0.1:10:360.1;
        % Output
        listDetectionRange
        % Folder to save the result 
        rootResult 
        % CPU time 
        CPUtime
    end
    
    properties (Hidden)
        topOption = 'SVM'; % M for attenuation in dB/m
        interpMethodBTY = 'C';  % 'L' Linear piecewise, 'C' Curvilinear  
        dataBathy
        
        % Bellhop parameters 
        beam
        bottom
        ssp
        receiverPos
        % Output
        spl
        zt
        rt

        % run date and time 
        launchDate 
        
        % Figure for the app 
        appUIFigure 
        %Ssp 
        SoundCelerity
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

        % Bellhop
        runTypeName
        beamTypeName
    end

    %% Constructor 
    methods
        function obj = DRESimulation(bathyEnv, moor, mammal, det, dr, dz)
            % Bathy env 
            if nargin >= 1
                obj.bathyEnvironment = bathyEnv;
            end
                
            % Mooring
            if nargin >= 2
                obj.mooring = moor;
            end
                    
            % Mammal
            if nargin >= 3
                obj.marineMammal = mammal;
            end

            % Detector
            if nargin >= 4
                obj.detector = det;
            end
                        
            % drSimu
            if nargin >= 5
                obj.drSimu = dr;
            end

            % dzSimu
            if nargin >= 6
                obj.dzSimu = dz;
            end
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

        function CWA = get.cwa(obj)
            % NOTE: cwa is computed using the median depth in the area around the mooring 
            % - sign for positive depth toward bottom
            medianDepth = -median(obj.dataBathy(:, 3)); 
            CWA = AbsorptionSoundSeaWaterFrancoisGarrison(...
                obj.marineMammal.signal.centroidFrequency / 1000,...
                mean(obj.oceanEnvironment.temperatureC, 'omitnan'),...
                mean(obj.oceanEnvironment.salinity, 'omitnan'),...
                medianDepth,...
                mean(obj.oceanEnvironment.pH, 'omitnan')) ;
            CWA = CWA / 1000; % Convert to dB/m
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

        function runTypeName = get.runTypeName(obj)
            switch obj.beam.RunType(1) 
                case 'C'
                    runTypeName = 'Coherent';
                case 'S'
                    runTypeName = 'Semi coherent';
                case 'I'
                    runTypeName = 'Incoherent';
            end
        end

        function beamTypeName = get.beamTypeName(obj)
            switch obj.beam.RunType(2) 
                case 'G'
                    beamTypeName = 'Geometric rays';
                case 'B'
                    beamTypeName = 'Gaussian beam bundles';
            end
        end
    end

    %% Simulation methods  
    methods 
        function runSimulation(obj)
            % Start time 
            tStart = tic;
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
            obj.oceanEnvironment = OceanEnvironement(obj.mooring, obj.rootSaveInput, obj.bBox, obj.tBox, obj.dBox); % setup ocean parameters by querying data from CMEMS 
            
            d.Message = 'Setting up the environment...';
            obj.setSource();
            obj.setBeam();

            % Initialize list of detection ranges 
            obj.listDetectionRange = zeros(size(obj.listAz));
                        
            flag = 1; % flag to ensure the all process as terminate without error 
            for i_theta = 1:length(obj.listAz)
                theta = obj.listAz(i_theta);

                % Check for Cancel button press
                if d.CancelRequested
                    flag = 0;
                    break
                end

                % Update progress, report current estimate
                d.Value = i_theta/length(obj.listAz);
                d.Message = sprintf('Computing detection range for azimuth = %2.1f ° ...', theta);

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
                if i_theta == 1
                    obj.writeLogHeader
                end

                % Run
                obj.runBellhop(nameProfile)

                % Plots
                saveBool = true;
                bathyBool = true;
                obj.plotTL(nameProfile, saveBool, bathyBool)
                obj.plotSPL(nameProfile, saveBool, bathyBool)

                % Derive detection range for current profile and add it to
                % the list of detection ranges 
                obj.addDetectionRange(nameProfile);
            end   
            
            close(d)
            if flag
                % Plot detection range (polar plot and map) 
                obj.plotDR()
            end
            obj.CPUtime = toc(tStart);
            obj.writeLogEnd
        end

        function recomputeDRE(obj)
            % Start time 
            tStart = tic;
            
            oldRootSaveResult = obj.rootSaveResult;
%             oldRootSaveInput = obj.rootSaveInput;
%             oldRootOutputFiles = obj.rootOutputFiles;
%             oldRootOutputFigures = obj.rootOutputFigures;
%             oldLogFile = obj.logFile;

            % Create new result folder
            obj.launchDate = datestr(now,'yyyymmdd_HHMM');
            if ~exist(obj.rootSaveResult, 'dir'); mkdir(obj.rootSaveResult);end

            % Copy all files to the new folder 
            copyfile(oldRootSaveResult, obj.rootSaveResult)
%             copyfile(oldRootSaveInput, obj.rootSaveResult)
%             copyfile(oldRootOutputFiles, obj.rootSaveResult)
%             copyfile(oldRootOutputFigures, obj.rootSaveResult)
%             copyfile(oldLogFile, obj.rootSaveResult)

            d = uiprogressdlg(obj.appUIFigure,'Title','Please Wait',...
                            'Message','Recomputing detection range with new parameters...', ...
                            'Cancelable', 'on', ...
                            'ShowPercentage', 'on');

            % Initialize list of detection ranges 
            obj.listDetectionRange = zeros(size(obj.listAz));
                        
            flag = 1; % flag to ensure the all process as terminate without error 
            for i_theta = 1:length(obj.listAz)
                theta = obj.listAz(i_theta);

                % Check for Cancel button press
                if d.CancelRequested
                    flag = 0;
                    break
                end

                % Update progress, report current estimate
                d.Value = i_theta/length(obj.listAz);
                d.Message = sprintf('Computing detection range for azimuth = %2.1f ° ...', theta);

                nameProfile = sprintf('%s-%2.1f', obj.mooring.mooringName, theta);

                % Write log header 
                if i_theta == 1
                    obj.writeLogHeader
                end

                % Derive detection range for current profile and add it to
                % the list of detection ranges 
                obj.addDetectionRange(nameProfile);
            end   
            
            close(d)
            if flag
                % Plot detection range (polar plot and map) 
                obj.plotDR()
            end
            obj.CPUtime = toc(tStart);
            obj.writeLogEnd
        end

        function getBathyData(obj)
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

            fprintf('Loading bathymetry dataset');
            obj.dataBathy = loadBathy(obj.rootSaveInput, fileCSV, obj.bBoxENU, obj.mooring.mooringPos);
            fprintf('\n--> DONE <--\n');
        end
        
        %% Log
        function writeLogHeader(obj)
            fileID = fopen(obj.logFile,'w');
            % Configuration 
            fprintf(fileID,'Estimation of the detection range using BELLHOP\n\n');
            fprintf(fileID, 'Equipment\n\n');
            fprintf(fileID,'\tName: %s\n', obj.mooring.mooringName);
            fprintf(fileID,'\tDeployment: %s to %s\n', obj.mooring.deploymentDate.startDate, obj.mooring.deploymentDate.stopDate);
            fprintf(fileID,'\tPosition: lon %4.4f°, lat %4.4f°, hgt %4.4f°\n', obj.mooring.mooringPos.lon, obj.mooring.mooringPos.lat, obj.mooring.mooringPos.hgt);
            fprintf(fileID,'\tHydrophone: %s\n', obj.detector.name);
            fprintf(fileID, '\tDetection threshold = %3.2f dB\n', obj.detector.detectionThreshold);
            fprintf(fileID, '__________________________________________________________________________\n\n');
            fprintf(fileID, 'Animal\n\n');
            fprintf(fileID, '\t%s emitting %s\n', obj.marineMammal.name, obj.marineMammal.signal.name);
            fprintf(fileID,'\tCentroid frequency:  %dHz\n', obj.marineMammal.signal.centroidFrequency);
            fprintf(fileID, '__________________________________________________________________________\n\n');
            fprintf(fileID, 'BELLHOP parameters\n\n');
            fprintf(fileID, '\tNumber of beams = %d\n', obj.beam.Nbeams);
            fprintf(fileID, '\tTL = %s\n', obj.runTypeName);
            fprintf(fileID, '\tBeam type = %s\n', obj.beamTypeName);
            fprintf(fileID, '\tTop option = %s\n', obj.topOption);
            fprintf(fileID, '__________________________________________________________________________\n\n');
            fprintf(fileID, 'Environment\n\n');
            fprintf(fileID, '\tAmbient noise level = %3.2f dB\n', obj.noiseLevel);
            fprintf(fileID, '\tCompression wave attenuation = %3.4f dB/m\n', obj.cwa);
            fprintf(fileID, '__________________________________________________________________________\n\n');
            fprintf(fileID, 'Estimating detection range\n\n');
            fprintf(fileID, '\tBearing (°)\tDetection range (m)\n\n');
            close(fileID)   
        end

        function writeDRtoLogFile(obj, theta, DT)
            fileID = fopen(obj.logFile, 'a');
            fprintf(fileID, '\t%3.2f\t%6.2f\n', theta, DT);
            close(fileID)
        end

        function writeLogEnd(obj)
            fileID = fopen(obj.logFile, 'a');
            fprintf(fileID, '\tCPU Time = %6.2f s', obj.CPUtime);
            close(fileID)
        end


        %% Set environment 
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

        function setBeam(obj)
            % Beam 
            obj.beam.RunType(1) = 'S'; % 'C': Coherent, 'I': Incoherent, 'S': Semi-coherent, 'R': ray, 'E': Eigenray, 'A': Amplitudes and travel times 
            obj.beam.RunType(2) = 'B'; % 'G': Geometric beams (default), 'C': Cartesian beams, 'R': Ray-centered beams, 'B': Gaussian beam bundles.
            obj.beam.Nbeams = 5001; % Number of launching angles
            obj.beam.alpha = [-80, 80]; % Launching angles in degrees
            obj.beam.deltas = 0; % Ray-step (m) used in the integration of the ray and dynamic equations, 0 let bellhop choose 
        end

        function obj = setBeambox(obj, bathyProfile)
            obj.beam.Box.z = max(obj.ssp.z) + 10; % zmax (m), larger than SSP max depth to avoid problems  
            obj.beam.Box.r = max(bathyProfile(:, 1)) + 0.1; % rmax (km), larger than bathy max range to avoid problems
        end

        function setBottom(obj)
            % Bottom properties 
            % TODO: replace by importation function call to get bottom properties
            % from ascii file (Chris) 
            obj.bottom.c = 1600; % Sound celerity in bottom half space 
            obj.bottom.ssc = 0.0; % Shear Sound Celerity in bottom half space 
            obj.bottom.rho = 1.8; % Density in bottom half space 
            obj.bottom.cwa = 0.8; % Compression Wave Absorption in bottom half space (unit depend on topOption(3), 'W' = dB/wavelength)
            obj.bottom.swa = []; % Shear Wave Absorption in bottom half space 
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
                obj.receiverPos.r.range = 0:obj.drSimu:max(bathyProfile(:, 1)); % Receiver ranges (km)
                obj.receiverPos.r.z = 0:obj.dzSimu:max(bathyProfile(:, 2)); % Receiver depths (m)  
        end

        function bathyProfile = getBathyProfile(obj, theta)
            fprintf('Extraction of 2D profile, azimuth = %2.1f°', theta);
            rootBathy = obj.bathyEnvironment.rootBathy;
            bathyFile = obj.bathyEnvironment.bathyFile;
            drBathy = obj.bathyEnvironment.drBathy;
            rMax = obj.marineMammal.rMax;
            data = obj.dataBathy;

            varGetProfile = {'rootBathy', rootBathy, 'bathyFile', bathyFile, 'SRC', 'ENU', 'dr', drBathy, 'data', data, 'theta', theta, 'rMax', rMax};
            bathyProfile = getBathy2Dprofile(varGetProfile{:});
            bathyProfile = table2array(bathyProfile);
            fprintf('\n--> DONE <--\n');
        end
        
        %% Write environment files 
        function writeBtyFile(obj, nameProfile, bathyProfile)
%             nameProfile = sprintf('%s%2.1f', obj.mooring.mooringName, theta);
            BTYfilename = sprintf('%s.bty', nameProfile);
            fprintf('Creation of bty file \n\tfilename = %s', BTYfilename);
            writebdry(fullfile(obj.rootOutputFiles, BTYfilename), obj.interpMethodBTY, bathyProfile)
            fprintf('\n--> DONE <--\n');
        end

        function writeEnvirnoment(obj, nameProfile)
            fprintf('Writing environment file')
            envfile = fullfile(obj.rootOutputFiles, nameProfile);

            freq = obj.marineMammal.signal.centroidFrequency;
            varEnv = {'envfil', envfile, 'freq', freq, 'SSP', obj.ssp, 'Pos', obj.receiverPos,...
                'Beam', obj.beam, 'BOTTOM', obj.bottom, 'topOption', obj.topOption, 'TitleEnv', nameProfile};
            writeEnvDRE(varEnv{:})
            fprintf('\n--> DONE <--\n');
        end

        function runBellhop(obj, nameProfile)
            fprintf('Running Bellhop')
            current = pwd;
            cd(obj.rootOutputFiles)
            bellhop( nameProfile )
            cd(current)
            fprintf('\n--> DONE <--\n');
        end
        
        %% Plot functions
        function plotTL(obj, nameProfile, saveBool, bathyBool)
            figure('visible','off'); 
            current = pwd;
            cd(obj.rootOutputFiles)
            plotshd( sprintf('%s.shd', nameProfile));
            a = colorbar;
            a.Label.String = 'Transmission Loss (dB ref 1\muPa)';

            if bathyBool
                plotbty( nameProfile );
            end
            
            scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')

            if saveBool
                cd(obj.rootOutputFigures)
                saveas(gcf, sprintf('%sTL.png', nameProfile));
            end
            close(gcf);
            cd(current)
        end

        function plotSPL(obj, nameProfile, saveBool, bathyBool)
            varSpl = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};            
            figure('visible','off');
            current = pwd;
            cd(obj.rootOutputFiles)
            plotspl(varSpl{:});
            a = colorbar;
            a.Label.String = 'Sound Pressure Level (dB ref 1\muPa)';

            if bathyBool
                plotbty( nameProfile );
            end

            scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')

            if saveBool
                cd(obj.rootOutputFigures)
                saveas(gcf, sprintf('%sSPL.png', nameProfile));
            end
            close(gcf);
            cd(current)
        end

        function plotDR(obj)
            figure;
            polarplot(obj.listAz * pi / 180, obj.listDetectionRange)
            ax = gca;
            ax.RLim = [0, obj.marineMammal.rMax];
            % Save 
            saveas(gcf, fullfile(obj.rootOutputFigures, sprintf('%s_polarDREstimate.png', obj.mooring.mooringName)));

            obj.plotBathyENU()
            xx = obj.listDetectionRange .* cos(obj.listAz * pi / 180);
            yy = obj.listDetectionRange .* sin(obj.listAz * pi / 180);
            plot(xx, yy, 'k', 'LineWidth', 3)

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
            
            figure
            contourf(X, Y, zDep)
            c = colorbar;
            c.Label.String = 'Elevation (m)';
            hold on 
            scatter(0, 0, 'filled', 'red') 
            title('Bathymetry - frame ENU')
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

        function addDetectionRange(obj, nameProfile)
            current = pwd;
            cd(obj.rootOutputFiles)
            varSpl = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};
            [obj.spl, obj.zt, obj.rt] = computeSpl(varSpl{:});
            computeArgin = {'SPL', obj.spl, 'Depth', obj.zt, 'Range', obj.rt, 'NL', obj.noiseLevel,...
                'DT', obj.detector.detectionThreshold, 'zTarget', obj.marineMammal.livingDepth, 'deltaZ', obj.marineMammal.deltaLivingDepth};
            detectionRange = computeDetectionRange(computeArgin{:});

            i = find(~obj.listDetectionRange, 1, 'first');
            obj.listDetectionRange(i) = detectionRange;
            obj.writeDRtoLogFile(obj.listAz(i), detectionRange)
            cd(current)
        end
    end
end









 