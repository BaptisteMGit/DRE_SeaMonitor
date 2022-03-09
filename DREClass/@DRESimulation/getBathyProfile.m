function bathyProfile = getBathyProfile(obj, theta)
    promptMsg = sprintf('Bathymetry profile extraction for azimuth = %3.1f°', theta);
    fprintf(promptMsg)
    
    rootBathy = obj.bathyEnvironment.rootBathy;
    bathyFile = obj.bathyEnvironment.bathyFile;
    drBathy = obj.bathyEnvironment.drBathy;
    rMax = obj.marineMammal.rMax;
    data = obj.dataBathy;

    varargin = {'rootBathy', rootBathy, 'bathyFile', bathyFile, 'CRS', 'ENU', 'dr', drBathy, 'data', data, 'theta', theta, 'rMax', rMax};
    bathyProfile = getBathy2Dprofile(varargin{:});
    bathyProfile = table2array(bathyProfile);

    linePts = repelem('.', 53 - numel(promptMsg));
    fprintf(' %s DONE\n', linePts);
end