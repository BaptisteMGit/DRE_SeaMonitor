function bathyNETCDFtoCSV(filename_NETCDF, filename_CSV)
%% Convert bathymetry dataset in NETCDF to csv format 
% Input: bathymetry dataset in NETCDF format with variables lon, lat,
% elevation
% Output: bathymetry dataset in csv format (XYZ) with variables lat, lon, depth 

dataOutput = getDataFromNETCDF(filename_NETCDF);

[X, Y] = meshgrid(dataOutput.lat, dataOutput.lon);
dataXYZ = [X(:), Y(:), double(dataOutput.elevation(:))];

tableXYZ = array2table(dataXYZ, 'VariableNames',{'lat','lon','depth'});
writetable(tableXYZ, filename_CSV)

end