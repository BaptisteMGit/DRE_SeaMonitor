cd 'C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_MATLAB\MainDRE'
%% Tests for MainDRE
rootBathy = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry';
bathyFile = '2008 HI1240 Runabay Head to Tuns.csv'; % Bathymetric file in WGS84
inputSRC = 'WGS84'; % SRC of the input bathyFile 
mooringPos = [-6.427, 55.3, -65.33]; % [lon0, lat0, hgt0]
mooringName = 'MooringTest';
listAz = 0.1:10:360; % List of azimuth to process (in degree) 
drBathy = 100; % Horizontal resolution for bathymetric profile 

mainVarargin = {'rootBathy', rootBathy, 'bathyFile', bathyFile, 'inputSRC', inputSRC, ...
    'mooringPos', mooringPos, 'mooringName', mooringName, 'listAz', listAz, 'drBathy', drBathy};

MainDRE(mainVarargin{:})

