function setBeambox(obj, bathyProfile)
    obj.bellhopEnvironment.beam.Box.z = max(obj.ssp.z) + 10; % zmax (m), larger than SSP max depth to avoid problems  
    obj.bellhopEnvironment.beam.Box.r = max(bathyProfile(:, 1)) + 0.1; % rmax (km), larger than bathy max range to avoid problems
end