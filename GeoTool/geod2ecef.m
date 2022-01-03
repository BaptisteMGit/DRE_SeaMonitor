function [x, y, z] = geod2ecef(lon, lat, hgt)
%% Function geod2ecef 
% computes ECEF coordinates x [m], y [m], z [m] from geodetic
% coordinates longitude [rad], latitude [rad], height [m]

[a, e2, ~, ~, ~, ~, ~] = getGRS80Parameters();
[lon, lat] = convert_rad(lon, lat);

v = sqrt(1 - e2 .* (sin(lat)).^2);
N = a ./ v;

x = (N + hgt) .* cos(lon) .* cos(lat);
y = (N + hgt) .* sin(lon) .* cos(lat);
z = (N .* (1 - e2) + hgt) .* sin(lat);
end