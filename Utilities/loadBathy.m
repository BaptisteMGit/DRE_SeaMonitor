function dataBathy = loadBathy(rootSaveResult, bathyFile, bBoxENU, mooringPos)
% Load bathy bBox dataset from csv file located in the input folder
% (coordinates are in WGS84)
M = readmatrix(fullfile(rootSaveResult, bathyFile), 'Delimiter', ',');

% WGS84 coordinates 
Lat = M(:,1);
Lon = M(:,2);
Hgt = M(:,3);

% Convert to ENU 
% tic 
[E, N, U] = geod2enu(mooringPos.lon, mooringPos.lat, mooringPos.hgt, Lon, Lat, Hgt);
% toc

% Subset data to only keep a box around the mooring pos 
idxE = (E >= bBoxENU.E.min & E <= bBoxENU.E.max);
idxN = (N >= bBoxENU.N.min & N <= bBoxENU.N.max);
idx = idxE & idxN;
E = E(idx);
N = N(idx);
U = U(idx);

dataBathy = [E, N, U];

end
