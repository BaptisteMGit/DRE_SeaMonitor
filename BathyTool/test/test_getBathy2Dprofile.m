%% test_getBathy2Dprofile
rootBathy = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\ENU';
bathyFile = '2008 HI1240 Runabay Head to Tuns.csv';
SRC = 'ENU';

dataBTY = readmatrix(fullfile(rootBathy, bathyFile), 'Delimiter',' ');
theta = 0.1:10:360;
dr = 100;

for angle = theta 
    VarBathy = {'rootBathy', rootBathy, 'bathyFile', bathyFile, 'SRC', SRC, 'data', dataBTY, 'theta', angle, 'dr', dr};
    getBathy2Dprofile(VarBathy{:})
end
