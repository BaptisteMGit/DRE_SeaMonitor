 classdef DRESimulation 
    properties
        % Bathymetry
        bathyEnvironment
        % Mooring 
        mooring 
        % Simulation
        drSimu = 0.01;                      % Range step (km) between receivers: more receivers increase accuracy but also increase CPU time 
        dzSimu = 0.5;                       % Depth step (m) between receivers: more receivers increase accuracy but also increase CPU time
        % Marine mammal to simulate 
        marineMammal 
        % Detector 
        detector 
        % Env parameters
        noiseLevel
        % Bellhop parameters 
        beam
        bottom
        ssp
        receiverPos
        listAz = 0.1:10:360.1;
        % Output
        listDetectionRange
        spl
        zt
        rt
    end
    
    properties (Hidden)
        topOption = 'SVW';
        interpMethodBTY = 'L';  % 'L' Linear piecewise, 'C' Curvilinear  
        dataBathy
    end

    properties (Dependent)
        rootSaveResult 
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
        function obj = set.marineMammal(obj, mMammal)
            if isa(mMammal, 'MarineMammal')
                    obj.marineMammal = mMammal;
                else
                    error('MarineMammal should be an object from class MarineMammal !')
            end
        end

        function obj = set.mooring(obj, moor)
            if isa(moor, 'Mooring')
                obj.mooring = moor;
            else
                error('Mooring should be an object from class Mooring !')
            end
        end

        function obj = set.bathyEnvironment(obj, bathyEnv)
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
            root = fullfile('C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Result', obj.mooring.mooringName);
        end

    end

    %% Simulation methods  
    methods 
        function runSimulation(obj)
            obj = obj.setSource();
            obj.dataBathy = obj.getBathyData();
            obj = obj.setBeam();    
            obj.listDetectionRange = zeros(size(obj.listAz));
            for theta = obj.listAz
                nameProfile = sprintf('%s%2.1f', obj.mooring.mooringName, theta);
                % Bathy
                bathyProfile = getBathyProfile(obj, theta);
                obj.writeBtyFile(nameProfile, bathyProfile)
                % Env
                obj = obj.setBottom();
                obj = obj.setSsp(bathyProfile);
                obj = obj.setBeambox(bathyProfile);
                obj = obj.setReceiverPos(bathyProfile);
                obj.writeEnvirnoment(nameProfile)
                % Run
                obj.runBellhop(nameProfile)
                % Plots
                saveBool = true;
                bathyBool = true;
                obj.plotTL(nameProfile, saveBool, bathyBool)
                obj.plotSPL(nameProfile, saveBool, bathyBool)
                obj = obj.addDetectionRange(nameProfile);
            end   
            % Plot detection range (polar plot and map) 
            obj.plotDR()
        end

        function data = getBathyData(obj)
            rootBathy = obj.bathyEnvironment.rootBathy;
            bathyFile = obj.bathyEnvironment.bathyFile;
            inputSRC = obj.bathyEnvironment.inputSRC;
            mooringPos = obj.mooring.mooringPos;

            if ~exist(fullfile(rootBathy ,'ENU', bathyFile), 'file')
                varConvBathy = {'bathyFile', bathyFile, 'SRC_source', inputSRC, 'SRC_dest', 'ENU', 'mooringPos', mooringPos};
                fprintf('Conversion of bathymetry data \n\tBathy file: %s \n\t%s -> %s ', bathyFile, inputSRC, 'ENU');
                data = convertBathyFile(varConvBathy{:});
                data = table2array(data);
            else
                fprintf('Load existing bathymetry data \n\tBathy file: %s \n\tSRC: %s', bathyFile, 'ENU');
                data = readmatrix(fullfile(rootBathy ,'ENU', bathyFile), 'Delimiter', ' ');
            end
            fprintf('\n--> DONE <--\n');
        end

        %% Set environment 
        function obj = setSource(obj)
            obj.receiverPos.s.z = obj.mooring.hydrophoneDepth; % TODO: check 
        end

        function obj = setBeam(obj)
            % Beam 
            obj.beam.RunType(1) = 'C'; % 'C': Coherent, 'I': Incoherent, 'S': Semi-coherent, 'R': ray, 'E': Eigenray, 'A': Amplitudes and travel times 
            obj.beam.RunType(2) = 'B'; % 'G': Geometric beams (default), 'C': Cartesian beams, 'R': Ray-centered beams, 'B': Gaussian beam bundles.
            obj.beam.Nbeams = 5001; % Number of launching angles
            obj.beam.alpha = [-80, 80]; % Launching angles in degrees
            obj.beam.deltas = 0; % Ray-step (m) used in the integration of the ray and dynamic equations, 0 let bellhop choose 
        end

        function obj = setBeambox(obj, bathyProfile)
            obj.beam.Box.z = max(obj.ssp.z) + 10; % zmax (m), larger than SSP max depth to avoid problems  
            obj.beam.Box.r = max(bathyProfile(:, 1)) + 0.1; % rmax (km), larger than bathy max range to avoid problems
        end

        function obj = setBottom(obj)
            % Bottom properties 
            % TODO: replace by importation function call to get bottom properties
            % from ascii file (Chris) 
            obj.bottom.c = 1600; % Sound celerity in bottom half space 
            obj.bottom.ssc = 0.0; % Shear Sound Celerity in bottom half space 
            obj.bottom.rho = 1.8; % Density in bottom half space 
            obj.bottom.cwa = 0.8; % Compression Wave Absorption in bottom half space 
            obj.bottom.swa = []; % Shear Wave Absorption in bottom half space 
        end

        function obj = setSsp(obj, bathyProfile)
            % TODO: replace by importation function call to get SSP
            Ssp.z = [0, 100, 200];
            Ssp.c = [1500, 1542, 1512];
            if max(Ssp.z) < max(bathyProfile(:, 2)) % Check that bathy doesn't drop below lowest point in the sound speed profile
                Ssp.z(end+1) = floor(max(bathyProfile(:, 2))) + 1;   
                Ssp.c(end+1) = Ssp.c(end);          % Extend ssp 
            end
            obj.ssp = Ssp;
        end
        
        function obj = setReceiverPos(obj, bathyProfile)
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
            writebdry(fullfile(obj.rootSaveResult, BTYfilename), obj.interpMethodBTY, bathyProfile)
            fprintf('\n--> DONE <--\n');
        end

        function writeEnvirnoment(obj, nameProfile)
            fprintf('Writing environment file')
            envfile = fullfile(obj.rootSaveResult, nameProfile);

            freq = obj.marineMammal.signal.centroidFrequency;
            varEnv = {'envfil', envfile, 'freq', freq, 'SSP', obj.ssp, 'Pos', obj.receiverPos,...
                'Beam', obj.beam, 'BOTTOM', obj.bottom, 'topOption', obj.topOption, 'TitleEnv', nameProfile};
            writeEnvDRE(varEnv{:})
            fprintf('\n--> DONE <--\n');
        end

        function runBellhop(obj, nameProfile)
            fprintf('Running Bellhop')
            current = pwd;
            cd(obj.rootSaveResult)
            bellhop( nameProfile )
            cd(current)
            fprintf('\n--> DONE <--\n');
        end
        
        %% Plot functions
        function plotTL(obj, nameProfile, saveBool, bathyBool)
            figure; 
            current = pwd;
            cd(obj.rootSaveResult)
            plotshd( sprintf('%s.shd', nameProfile) );
            if bathyBool
                plotbty( nameProfile );
            end
            if saveBool
                saveas(gcf, sprintf('%sTL.png', nameProfile));
            end
            close(gcf);
            cd(current)
        end

        function plotSPL(obj, nameProfile, saveBool, bathyBool)
            varSpl = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};            
            figure;
            current = pwd;
            cd(obj.rootSaveResult)
            plotspl(varSpl{:});
            if bathyBool
                plotbty( nameProfile );
            end
            if saveBool
                saveas(gcf, sprintf('%sSPL.png', nameProfile));
            end
            close(gcf);
            cd(current)
        end

        function plotDR(obj)
            figure;
            current = pwd;
            cd(obj.rootSaveResult)
            polarplot(obj.listAz * pi / 180, obj.listDetectionRange)
            
            figure;
            obj.plotBathyENU()
            xx = obj.listDetectionRange .* cos(obj.listAz * pi / 180);
            yy = obj.listDetectionRange .* sin(obj.listAz * pi / 180);
            plot(xx, yy, 'k', 'LineWidth', 3)
            cd(current)
        end
        
        function plotBathyENU(obj)
            varPlotBathy = {'bathyFile', obj.bathyEnvironment.bathyFile, 'SRC', 'ENU'};
            plotBathy(varPlotBathy{:})
        end

        function obj = addDetectionRange(obj, nameProfile)
            current = pwd;
            cd(obj.rootSaveResult)
            varSpl = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};
            [obj.spl, obj.zt, obj.rt] = computeSpl(varSpl{:});
            computeArgin = {'SPL', obj.spl, 'Depth', obj.zt, 'Range', obj.rt, 'NL', obj.noiseLevel,...
                'DT', obj.detectionThreshold, 'zTarget', obj.marineMammal.livingDepth, 'deltaZ', obj.marineMammal.deltaLivingDepth};
            detectionRange = computeDetectionRange(computeArgin{:});

            i = find(~obj.listDetectionRange, 1, 'first');
            obj.listDetectionRange(i) = detectionRange;
            cd(current)
        end
    end
end









 