function plotBathy(varargin)
bathyFile = getVararginValue(varargin, 'bathyFile', ''); % Bathymetric file in WGS84
SRC = getVararginValue(varargin, 'SRC', 'ENU');
switch SRC
    case 'WGS84'
        plotBathyWGS84(bathyFile)
    case 'UTM'
        plotBathyUTM(bathyFile)
    case 'ENU'
        plotBathyENU(bathyFile)
end     
end