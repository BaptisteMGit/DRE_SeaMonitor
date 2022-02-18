classdef TestCase1_RecordedPorpoise < DRESimulation
    %TESTCASE1 simulation object to be used for App test 
    %   Test case based on the paper: 
    %   Nuuttila HK, Brundiers K, Dähne M,
    %   et al. Estimating effective detection area of static passive
    %   acoustic data loggers from playback experiments with
    %   cetacean vocalisations. Methods Ecol Evol. 2018;00:1–10. 
    %   https://doi.org/10.1111/2041-210X.1309
    % 
    % In this test case we consider the part of the study dealing with
    % recorded Porpoise clicks. 

    properties
    end
    
    methods
        function obj = TestCase1_RecordedPorpoise
            %% Bathymetry 
%             Old way to instanciate the object BathyEnvironement (before
%             26/01/2022) 
%             rootBathy = 'C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_SeaMonitor\GUI\App\AppTestCase\testCase1';
%             bathyFile = 'gebco_2021_n52.3_s52.2_w-4.45001220703125_e-4.3.nc'; % Bathymetry file in WGS84
%             inputCRS = 'WGS84'; % CRS of the input bathyFile 
%             bathyFileType = 'NETCDF';
%             drBathy = 100; % Horizontal resolution for bathymetric profile 
%             Now for Userfile source (ie the user wants to use is own
%             bathy file) create the object as below
%             obj.bathyEnvironment = BathyEnvironment('Userfile', rootBathy, bathyFile, inputCRS, bathyFileType, drBathy);

            % New version 26/01/2022 -> auto loaded bathymetry 
            source = 'GEBCO2021'; % Automatic query of bathy data from GEBCO global grid            
            obj.bathyEnvironment = BathyEnvironment(source);

            %% Mooring 
            mooringPos.lat = 52.22;
            mooringPos.lon = -4.37;
            % Since 25/01/2022 geoid height (= ellipsoid height) is computed using geoidheigth function   
%             mooringPos.hgt = 54.7150; %Geoid height given by https://geographiclib.sourceforge.io/cgi-bin/GeoidEval?input=52.22+-4.37&option=Submit for this location 
            
            % yyyy-mm-dd hh:mm:ss
            deploymentDate.startDate = '2022-01-01 12:00:00';
            deploymentDate.stopDate = '2022-01-21 12:00:00';
            
            mooringName = 'TestCase1';
            hydroDepth = -1.5; % Negative hydroDepth = depth reference to the seafloor 
            % -> hydrophone 1.5 meter over the seafloor 
            
            obj.mooring = Mooring(mooringPos, mooringName, hydroDepth, deploymentDate);
            
            %% Marine mammal 
            porpoise = Porpoise();
            porpoise.centroidFrequency = 130 * 1e3; % frequency in Hz
            porpoise.sourceLevel = 176; % Maximum source level used (artificial porpoise-like signals)
            porpoise.livingDepth = 2; % Depth of the emmiting transducer used 
            porpoise.deltaLivingDepth = 2; % Arbitrary (to discuss)
            porpoise.rMax = 1500;
            % Directivity is derived from angle of main lobe given in the
            % paper: mainlobeAperture ~ 12.3° and for the narrowband direction loss considered we have 
            % mainlobeAperture = 58.9 * pi/ka (mainlobeAperture in degrees); considering DI = 20log(ka) we have 
            % DI = 20log(58.9 * pi/mainlobeAperture) ~ 23.5 dB 
            porpoise.directivityIndex  = 23.5;  % 
            
            obj.marineMammal = porpoise;
            obj.marineMammal.setSignal(); 

            %% Simulation parameters 
            obj.bellhopEnvironment = BellhopEnvironment;
            obj.bellhopEnvironment.drSimu = 0.001;
            obj.bellhopEnvironment.dzSimu = 0.1;
            
            %% Detector 
            obj.detector = CPOD();
            
            %% noiseLevel 
%             noiseLevel = 75; % Noise level (first estimate using getNLFromWavFile and raw file from glider) 
            noiseLevel = (30 + 46)/2; 
            obj.noiseEnvironment = NoiseEnvironment('Input value', noiseLevel);

            obj.listAz = 0.1:30:360.1;
%             obj.listAz = [75.1];
            obj.detector.detectionThreshold = 114.5/2; % According to Methodology and results of calibration of tonal click detectors
                                                     % for small odontocetes (C-PODs)

            % From ref paper: The average threshold level over the four positions was then used as the
            % calibration sensitivity, which varied from 111 dB to 119 dB re 1 μPa
            % peak-to-peak (pp) across the C-PODs used in the study.
            

            obj.seabedEnvironment = SeabedEnvironment('Coarse sediment');

        end

        
    end
end

