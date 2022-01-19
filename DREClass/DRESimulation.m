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
        noiseLevel
        % Simulation
        drSimu = 0.01;                      % Range step (km) between receivers: more receivers increase accuracy but also increase CPU time 
        dzSimu = 0.5;                       % Depth step (m) between receivers: more receivers increase accuracy but also increase CPU time
        % Bellhop parameters 
        listAz = 0.1:10:360.1;
        % Output
        listDetectionRange
        % Folder to save the result 
        rootResult = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Result'; % Default folder when executed from BM computer 
    end
    
    properties (Hidden)
        topOption = 'SVW';
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
    end

    properties (Dependent, Hidden=true)
        rootSaveResult 
        rootOutputFiles
        rootOutputFigures
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

    %% Set and Get methods 
    methods 
        function root = get.rootSaveResult(obj)
%             root = obj.rootSaveResult;
            root = fullfile(obj.rootResult, obj.mooring.mooringName, obj.launchDate);
        end
        
        function root = get.rootOutputFiles(obj)
            root = fullfile(obj.rootSaveResult, 'bellhopFiles');
        end

        function root = get.rootOutputFigures(obj)
            root = fullfile(obj.rootSaveResult, 'figures');
        end
%         function set.rootSaveResult(obj, root)
%             obj.rootSaveResult = 
%         end
    end

    %% Simulation methods  
    methods 
        function runSimulation(obj)
            d = uiprogressdlg(obj.appUIFigure,'Title','Please Wait',...
                            'Message','Setting up the environment...', ...
                            'Cancelable', 'on', ...
                            'ShowPercentage', 'on');
            % Create result folders
            obj.launchDate = datestr(now,'yyyymmdd_HHMM');
            if ~exist(obj.rootSaveResult, 'dir'); mkdir(obj.rootSaveResult);end
            if ~exist(obj.rootOutputFiles, 'dir'); mkdir(obj.rootOutputFiles);end
            if ~exist(obj.rootOutputFigures, 'dir'); mkdir(obj.rootOutputFigures);end

            obj.getBathyData();
            obj.setSource();
            obj.setBeam();

            % Initialize list of detection ranges 
            obj.listDetectionRange = zeros(size(obj.listAz));
            %         
%             obj.plotBathyENU()
            
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
                obj.setSsp(bathyProfile);
                obj.setBeambox(bathyProfile);
                obj.setReceiverPos(bathyProfile);                
                obj.writeEnvirnoment(nameProfile)

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

        end

        function getBathyData(obj)
            rootBathy = obj.bathyEnvironment.rootBathy;
            bathyFile = obj.bathyEnvironment.bathyFile;
            inputSRC = obj.bathyEnvironment.inputSRC;
            mooringPos = obj.mooring.mooringPos;
            
            % If file is not ENU: convert to ENU
            if ~strcmp(inputSRC, 'ENU')
                fprintf('Conversion of bathymetry data \n\tBathy file: %s \n\t%s -> %s ', bathyFile, inputSRC, 'ENU');
                varConvertBathy = {'rootBathy', rootBathy, 'bathyFile', bathyFile, 'SRC_source', inputSRC, ...
                    'SRC_dest', 'ENU', 'mooringPos', mooringPos};
                [data, outputFile] = convertBathyFile(varConvertBathy{:});                        
                obj.dataBathy = table2array(data);
                obj.bathyEnvironment.bathyFile = outputFile;

%             if ~exist(fullfile(rootBathy ,'ENU', bathyFile), 'file')
%                 varConvBathy = {'bathyFile', bathyFile, 'SRC_source', inputSRC, 'SRC_dest', 'ENU', 'mooringPos', mooringPos};
%                 data = convertBathyFile(varConvBathy{:});
%                 data = table2array(data);
            else
                fprintf('Load existing bathymetry data \n\tBathy file: %s \n\tSRC: %s', bathyFile, 'ENU');
                obj.dataBathy = readmatrix(fullfile(rootBathy, bathyFile), 'Delimiter', ' ');
            end
            fprintf('\n--> DONE <--\n');
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

        function setSsp(obj, bathyProfile)
            % TODO: replace by importation function call to get SSP
            Ssp.z = [0, 200];
            Ssp.c = [1500, 1500];
            Ssp.
            if max(Ssp.z) < max(bathyProfile(:, 2)) % Check that bathy doesn't drop below lowest point in the sound speed profile
                Ssp.z(end+1) = floor(max(bathyProfile(:, 2))) + 1;   
                Ssp.c(end+1) = Ssp.c(end);          % Extend ssp 
            end
            obj.ssp = Ssp;
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
            current = pwd;
%             cd(obj.rootSaveResult)
            polarplot(obj.listAz * pi / 180, obj.listDetectionRange)
            % Save 
            cd(obj.rootOutputFigures)
            saveas(gcf, sprintf('%s_polarDREstimate.png', obj.mooring.mooringName));

%             figure;
            obj.plotBathyENU()
            xx = obj.listDetectionRange .* cos(obj.listAz * pi / 180);
            yy = obj.listDetectionRange .* sin(obj.listAz * pi / 180);
            plot(xx, yy, 'k', 'LineWidth', 3)
            % Save 
            cd(obj.rootOutputFigures)
            saveas(gcf, sprintf('%s_DREstimate.png', obj.mooring.mooringName));

            cd(current)
        end
        
        function plotBathyENU(obj)
            varPlotBathy = {'rootBathy', obj.bathyEnvironment.rootBathy, 'bathyFile', obj.bathyEnvironment.bathyFile, 'SRC', 'ENU'};
            plotBathy(varPlotBathy{:})
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
            cd(current)
        end
    end
end









 