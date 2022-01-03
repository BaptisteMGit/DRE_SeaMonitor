function T = convertBathyFile_WGS84_UTM(filename, nUTM)
root = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\WGS84'; 
D = readmatrix(sprintf('%s\\%s',root, filename), 'Delimiter',' ');
Lat = D(:,1);
Lon = D(:,2);
Dep = D(:,3);

[x_utm, y_utm] = utm_geod2map(nUTM, Lon, Lat);
T = table(x_utm, y_utm, Dep);

% fileWithoutExtension = filename(1:end-4);
rootSave = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\UTM'; 
if ~exist(rootSave, 'dir'); mkdir(rootSave);end

fileUTM = sprintf('%s\\%s', rootSave, filename);
writetable(T, fileUTM,'Delimiter',' ')  
end
