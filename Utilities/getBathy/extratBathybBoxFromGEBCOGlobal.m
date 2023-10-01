function GEBCObBox = extratBathybBoxFromGEBCOGlobal(bBox, rootSaveInput)
    current = pwd; 

    % GEBCO Global grid data set 
    GEBCOGlobal = fullfile(current, "BathymetryData", "GEBCO", "GEBCO_2021_sub_ice_topo.nc");
    GEBCObBox = sprintf('GEBCO_2021_lon_%3.2f_%3.2f_lat_%3.2f_%3.2f.nc', bBox.lon.min, bBox.lon.max, bBox.lat.min, bBox.lat.max);
    
    % Use ncks module to query bBox 
    path_ncks = fullfile(current, "BathymetryData", "nco", "ncks.exe");
    lonlim = sprintf(' -d lon,%3.2f,%3.2f', bBox.lon.min, bBox.lon.max);
    latlim = sprintf(' -d lat,%3.2f,%3.2f', bBox.lat.min, bBox.lat.max);
    cmd = sprintf('%s%s%s %s %s', path_ncks, lonlim, latlim, GEBCOGlobal, fullfile(rootSaveInput, GEBCObBox));

    [status, cmdout] = system(cmd);

    if status ~= 0
        error(cmdout)
    end
end