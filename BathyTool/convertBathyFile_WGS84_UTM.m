function [T, outputFile] = convertBathyFile_WGS84_UTM(rootBathy, bathyFile, nUTM)
% root = 'C:\Users\33686\Desktop\SeaMonitor\Detection ran,ge estimation\Bathymetry\WGS84'; 
try
    T = readtable(fullfile(rootBathy, bathyFile));
catch 
    error('Input file must be a table.')
end

Lat = T(:,1);
Lon = T(:,2);
Dep = T(:,3);

[x_utm, y_utm] = utm_geod2map(nUTM, Lon, Lat);
T = table(x_utm, y_utm, Dep);

% fileWithoutExtension = filename(1:end-4);
% rootSave = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\UTM'; 
% if ~exist(rootSave, 'dir'); mkdir(rootSave);end
outputFile = sprintf('ENU_%s', bathyFile);
fileUTM = fullfile(rootBathy, outputFile);
writetable(T, fileUTM, 'Delimiter',' ') 

end

