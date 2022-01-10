%% Test case 1: porpoise 
% Test case based on the paper: 
% Nuuttila HK, Brundiers K, Dähne M,
% et al. Estimating effective detection area of static passive
% acoustic data loggers from playback experiments with
% cetacean vocalisations. Methods Ecol Evol. 2018;00:1–10. 
% https://doi.org/10.1111/2041-210X.1309

% Workflow:

% Bathymetry data have been downloaded from the website https://download.gebco.net/#
% Grid version GEBCO 2021
% Bounds N 52.3 W -4.45 S 52.2 E -4.3
% File formats Grid: netCDF; TID grid: netCDF

% The dataset has been converted into csv XYZ file using function
% NETCDFtoCSV (in folder utilities)


%% Bathymetry 
rootBathy = 'C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_SeaMonitor\TestCase\testCase1\Bathymetry';
bathyFile = 'gebco_2021_n52.3_s52.2_w-4.45001220703125_e-4.3.csv'; % Bathymetric file in WGS84
inputSRC = 'WGS84'; % SRC of the input bathyFile 
drBathy = 10; % Horizontal resolution for bathymetric profile 

bathyEnv = BathyEnvironment(rootBathy, bathyFile, inputSRC, drBathy);

%% Mooring 
mooringPos = [-4.37, 52.22, 0]; % [lon0, lat0, hgt0]
mooringName = 'TestCase1';
hydroDepth = 2;

mooring = Mooring(mooringPos, mooringName, hydroDepth);

%% Marine mammal 
porpoise = Porpoise();
porpoise.centroidFrequency = 130; % frequency in kHz
porpoise.sourceLevel = 

%% Simulation parameters 
dr = 0.01;
dz = 0.5;

%% Detector 
cpod = CPOD();
cpod.

%% Run simulation 
simulation = DRESimulation(bathyEnv, mooring, porpoise, cpod, dr, dz);
simulation.runSimulation
