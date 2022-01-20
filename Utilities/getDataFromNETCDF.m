function dataOutput = getDataFromNETCDF(filename_NETCDF)
%% Get data from NETCDF file  
% Input: NETCDF file
% Output: struct with different fields contained in the NETCDF file 

    fileNetcdfInfo = ncinfo(filename_NETCDF);
    sz = size(fileNetcdfInfo.Variables);
    nVar = sz(2);
    
    for i=1:nVar
        varName = fileNetcdfInfo.Variables(i).Name;
        dataOutput.(varName) = ncread(filename_NETCDF, varName);
    end

end