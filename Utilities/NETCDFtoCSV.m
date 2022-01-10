function NETCDFtoCSV(filename_NETCDF, filename_CSV)
%% Convert bathymetry dataset in NETCDF to csv format 
% Input: bathymetry dataset in NETCDF format with variables lon, lat,
% elevation
% Output: bathymetry dataset in csv format (XYZ) with variables lat, lon, depth 

fileNetcdfInfo = ncinfo(filename_NETCDF);
sz = size(fileNetcdfInfo.Variables);
nVar = sz(2);


for i=1:nVar
    varName = fileNetcdfInfo.Variables(i).Name;
    dataOutput.(varName) = ncread(filename_NETCDF, varName);
end

[X, Y] = meshgrid(dataOutput.lat, dataOutput.lon);
dataXYZ = [X(:), Y(:), double(dataOutput.elevation(:))];

tableXYZ = array2table(dataXYZ, 'VariableNames',{'lat','lon','depth'});
writetable(tableXYZ, filename_CSV)

end