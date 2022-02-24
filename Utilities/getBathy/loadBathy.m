function dataBathy = loadBathy(rootSaveResult, bathyFile, bBoxENU, mooringPos)
% Load bathy bBox dataset from csv file located in the input folder
% (lon, lat coordinates are in WGS84)
M = readmatrix(fullfile(rootSaveResult, bathyFile), 'Delimiter', ',');

% GEBCO coordinates assumed to be expressed in WGS84 crs (according to the
% associated paper describing the grid)
Lat = M(:,1);
Lon = M(:,2);
Hgt_MSL = M(:,3); % Referenced to Mean Sea Level 

% Convert into heights referenced to the WGS84 ellipsoid 
% [lon_wrapped, Lon] = wraplongitude(Lon,'deg','360'); % Wrap before calling the geoidheight function to avoir warning in the app 
warning off all
Hgt_WGS84 = Hgt_MSL + geoidheight(Lat, Lon);
warning on all

% Convert to ENU 
% tic 
[E, N, U] = geod2enu(mooringPos.lon, mooringPos.lat, mooringPos.hgt, Lon, Lat, Hgt_WGS84);
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
