% cd 'C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_MATLAB\MainDRE'
%% Tests for MainDRE
rootBathy = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry';
bathyFile = '2008 HI1240 Runabay Head to Tuns.csv'; % Bathymetric file in WGS84
inputSRC = 'WGS84'; % SRC of the input bathyFile 
mooringPos = [-6.427, 55.3, -65.33]; % [lon0, lat0, hgt0]
mooringName = 'MooringTest';
listAz = 0.1:10:350; % List of azimuth to process (in degree) 
drBathy = 100; % Horizontal resolution for bathymetric profile 
rMax = 1500; % Max distance based on literature 
% mainVarargin = {'rootBathy', rootBathy, 'bathyFile', bathyFile, 'inputSRC', inputSRC, ...
%     'mooringPos', mooringPos, 'mooringName', mooringName, 'listAz', listAz, 'drBathy', drBathy, 'rMax', rMax};
% 
% MainDRE(mainVarargin{:})

%% Run simulation to estimate Detection Range with OOP (class DRESimulation) 
bathyEnv = BathyEnvironment(rootBathy, bathyFile, inputSRC, drBathy);

hydroDepth = 10;
mooring = Mooring(mooringPos, mooringName, hydroDepth);

dolphin = CommonBottlenoseDolphin();

dr = 0.01;
dz = 0.5;
simulation = DRESimulation(bathyEnv, mooring, dolphin, dr, dz);
simulation.noiseLevel = 30;
simulation.detectionThreshold = 10;
simulation.runSimulation
