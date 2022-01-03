function T = convertBathyFile_WGS84_ENU(filename, lon0, lat0, hgt0)
root = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\WGS84'; 
D = readmatrix(sprintf('%s\\%s',root, filename), 'Delimiter',' ');
Lat = D(:,1);
Lon = D(:,2);
Dep = D(:,3);

[E, N, U] = geod2enu(lon0, lat0, hgt0, Lon, Lat, Dep);
T = table(E, N, U);

% fileWithoutExtension = filename(1:end-4);
rootSave = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\ENU'; 
if ~exist(rootSave, 'dir'); mkdir(rootSave);end

fileENU = sprintf('%s\\%s', rootSave, filename);
writetable(T, fileENU,'Delimiter',' ')  

end