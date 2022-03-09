function setSsp(obj, bathyProfile, i_theta)
    % TODO: replace by importation function call to get SSP ?
%    Ssp.z = 0:2:obj.maxBathyDepth;
    Ssp.z = obj.oceanEnvironment.depth;

    % Compute SoundCelerity at mooringPos (only one time to
    % limit computing effort)
    if i_theta == 1 
        obj.SoundCelerity = MackenzieSoundSpeed(obj.oceanEnvironment.depth, obj.oceanEnvironment.salinity, obj.oceanEnvironment.temperatureC);
    end

    Ssp.c = obj.SoundCelerity;
    Ssp.cwa = repelem(obj.cwa, numel(Ssp.z)); 
    if max(Ssp.z) < max(bathyProfile(:, 2)) % Check that bathy doesn't drop below lowest point in the sound speed profile
        Ssp.z(end+1) = floor(max(bathyProfile(:, 2))) + 1;   
        Ssp.c(end+1) = Ssp.c(end);          % Extend ssp 
        Ssp.cwa(end+1) = Ssp.cwa(end);
    end
    obj.ssp = Ssp;

    if i_theta == 1; obj.plotSSP('app'); end
end