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
            mooringPos.lat = 52.225;
            mooringPos.lon = -4.370;
            % Since 25/01/2022 geoid height (= ellipsoid height) is computed using geoidheigth function   
%             mooringPos.hgt = 54.7150; %Geoid height given by https://geographiclib.sourceforge.io/cgi-bin/GeoidEval?input=52.22+-4.37&option=Submit for this location 
            
            % yyyy-mm-dd hh:mm:ss
            % Date have been extracted from the data file 'Nuuttila et al
            % Recorded porpoise click data for Zenodo.csv'
            % Data are archived in the Swansea University Open Research Data site at Zenodo, https://doi.org/10.5281/zenodo.1421093. 
%             deploymentDate.startDate = '2012-04-26 07:00:00'; % 26/04/2012 07:23 
%             deploymentDate.stopDate = '2012-05-04 17:00:00'; % 04/05/2012 16:57
            
            % Temporary before Copernicus reply 
            deploymentDate.startDate = '2020-04-26'; % 26/04/2012 07:23 
            deploymentDate.stopDate = '2020-05-04'; % 04/05/2012 16:57

            mooringName = 'TestCase1-RecordedPorpoise';
            hydroDepth = -1.5; % Negative hydroDepth = depth reference to the seafloor 
            % -> hydrophone 1.5 meter over the seafloor 
            
            obj.mooring = Mooring(mooringPos, mooringName, hydroDepth, deploymentDate);
            
            %% Marine mammal 
            porpoise = Porpoise();
            porpoise.centroidFrequency = 130 * 1e3; % frequency in Hz

            % source levels between 130 and 182 dB re 1 μPa
            % We assume that the distribution is normal 
            % mean(SL) = (182 + 130) / 2 = 156;
            % We assume 3*sigma = (max(SL) - min(SL)) / 2  = 26;
            % ie std(SL) = 8.7 ~ 9;  

%             porpoise.sourceLevel = 156;    % mean(SL)
%             porpoise.sigmaSourceLevel = 9; % std(SL) 

            porpoise.sourceLevel = 182;    % SL for max range in Nuutilla 
            porpoise.sigmaSourceLevel = 2; % We assumed same std as TC4033 as no info is available for TC2130

            porpoise.livingDepth = 2; % Depth of the emmiting transducer used 
            porpoise.deltaLivingDepth = 0.5; % Arbitrary (to discuss)
            porpoise.rMax = 1500;
            % Directivity is derived from angle of main lobe given in the
            % paper: mainlobeAperture ~ 12.3° and for the narrowband direction loss considered we have 
            % mainlobeAperture = 58.9 * pi/ka (mainlobeAperture in degrees); considering DI = 20log(ka) we have 
            % DI = 20log(58.9 * pi/mainlobeAperture) ~ 23.5 dB 
            porpoise.directivityIndex  = 23.5;  % 
            
            obj.marineMammal = porpoise;
            obj.marineMammal.setSignal(); 

            %% Off-axis 
            % Directional transducer 
            obj.offAxisDistribution = 'Near on-axis';
            obj.offAxisAttenuation = 'Narrowband';
            obj.sigmaH = 30; % Large angle, the transducer is said to be turn from one side to another

            %% Simulation parameters 
            obj.bellhopEnvironment = BellhopEnvironment;
            obj.bellhopEnvironment.drSimu = 0.001;
            obj.bellhopEnvironment.dzSimu = 0.1;
            
            %% Detector 
            obj.detector = CPOD();
            
            %% noiseLevel 
            % Noise level using Wenz model with windSpeed = 3.1; % Sea 
            % state = 2, w = 6knots = 3.1 m.s-1 in the frequency band of
            % interest: 1-Octave band centered on 130kHz  
            noiseLevel = 75; 
            obj.noiseEnvironment = NoiseEnvironment('Input value', noiseLevel);

            obj.listAz = 0.1:5:360.1;
            % According to Methodology and results of calibration of tonal 
            % click detectors for small odontocetes (C-PODs) the detection
            % threshold of C-PODS (derived from linear model) is (based on
            % the tests realised over 86 C-PODS) DT = 114.5 dB re 1uPa
            % peak-peak. As we are considering 0-peak pressures to derive
            % TL with BELLHOP model we need to consider 0-peak detection
            % threshold. To do so we assume that clicks are symetric
            % signals which implies that 0-peak pressure (Pp) is equal to 1/2
            % * peak-peak presurre (Ppp) i.e Ppp = 2Pp. Therefore,
            % considering the log10 one can deduce the following relations
            % between 0-peak detection threshold and peak-peak detection
            % threshold: DTpp = DTp + 3 (dB) 

            % Detection sensitivity of CPODs used in Nuuttila is said to be
            % between 111 and 119 dB -> mean value 114 dB
            obj.detector.detectionThreshold = 114 - 3;

            % From ref paper: The average threshold level over the four positions was then used as the
            % calibration sensitivity, which varied from 111 dB to 119 dB re 1 μPa
            % peak-to-peak (pp) across the C-PODs used in the study.
            

            obj.seabedEnvironment = SeabedEnvironment('Muddy sand and sand');

        end

        
    end
end

