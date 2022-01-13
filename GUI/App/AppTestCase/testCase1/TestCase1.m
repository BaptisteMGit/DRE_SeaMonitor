classdef TestCase1 < DRESimulation
    %TESTCASE1 simulation object to be used for App test 
    %   Test case based on the paper: 
    %   Nuuttila HK, Brundiers K, Dähne M,
    %   et al. Estimating effective detection area of static passive
    %   acoustic data loggers from playback experiments with
    %   cetacean vocalisations. Methods Ecol Evol. 2018;00:1–10. 
    %   https://doi.org/10.1111/2041-210X.1309
    
    %   Workflow:
    
    %   Bathymetry data have been downloaded from the website https://download.gebco.net/#
    %   Grid version GEBCO 2021
    %   Bounds N 52.3 W -4.45 S 52.2 E -4.3
    %   File formats Grid: netCDF; TID grid: netCDF
    
    %   The bathymetric dataset has been converted into csv XYZ file using function
    %   NETCDFtoCSV (in folder utilities)   

    properties
    end
    
    methods
        function obj = TestCase1
            %% Bathymetry 
            rootBathy = 'C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_SeaMonitor\GUI\App\AppTestCase\testCase1';
            bathyFile = 'ENU_gebco_2021_n52.3_s52.2_w-4.45001220703125_e-4.3.csv'; % Bathymetric file in WGS84
            inputSRC = 'ENU'; % SRC of the input bathyFile 
            drBathy = 100; % Horizontal resolution for bathymetric profile 
            
            obj.bathyEnvironment = BathyEnvironment(rootBathy, bathyFile, inputSRC, drBathy);
            
            %% Mooring 
%             mooringPos = [-4.37, 52.22, 0]; % [lon0, lat0, hgt0] %
%             Position used to compute ENU bathy 
            mooringPos = [0, 0, 0]; % [lon0, lat0, hgt0]
            mooringName = 'TestCase1';
            hydroDepth = -1; % Negative hydroDepth = depth reference to the seafloor 
            % -> hydrophone 1 meter over the seafloor 
            
            obj.mooring = Mooring(mooringPos, mooringName, hydroDepth);
            
            %% Marine mammal 
            porpoise = Porpoise();
            porpoise.centroidFrequency = 130; % frequency in kHz
            porpoise.sourceLevel = 176; % Maximum source level used (artificial porpoise-like signals)
            porpoise.livingDepth = 2; % Depth of the emmiting transducer used 
            porpoise.deltaLivingDepth = 2; % Arbitrary (to discuss)

            obj.marineMammal = porpoise;

            %% Simulation parameters 
            obj.drSimu = 0.001;
            obj.dzSimu = 0.1;
            
            %% Detector 
            obj.detector = CPOD();
            
            %% noiseLevel 
            obj.noiseLevel = 30; % Noise level (to discuss);
        end

        
    end
end

