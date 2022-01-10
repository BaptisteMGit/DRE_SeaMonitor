function [T, outputFile] = convertBathyFile_WGS84_ENU(rootBathy, bathyFile, lon0, lat0, hgt0)
% root = 'C:\Users\33686\Desktop\SeaMonitor\Detection range
% estimation\Bathymetry\WGS84'; ù
try 
    T = readtable(fullfile(rootBathy, bathyFile));
catch
    error('Input file must be a table.')
end

Lat = table2array(T(:,1));
Lon = table2array(T(:,2));
Dep = table2array(T(:,3));

[E, N, U] = geod2enu(lon0, lat0, hgt0, Lon, Lat, Dep);
T = table(E, N, U);

% fileWithoutExtension = filename(1:end-4);
% rootSave = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\ENU'; 
% if ~exist(rootSave, 'dir'); mkdir(rootSave);end
outputFile = sprintf('ENU_%s', bathyFile);
fileENU = fullfile(rootBathy, outputFile);
writetable(T, fileENU, 'Delimiter',' ')  

end