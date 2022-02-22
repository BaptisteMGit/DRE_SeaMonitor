function [lon, lat, hgt] = ecef2geod(x, y, z)
%% Function ecef2geod
% computes geodetic coordinates longitude [rad], latitude [rad],
% height [m] from ECEF coordinates x [m], y [m], z [m]

[a, e2, ~, ~, f, ~, ~] = getGRS80Parameters();
r = sqrt(x.^2 + y.^2 + z.^2);
mu = atan(z ./ (sqrt(x.^2 + y.^2)) .* ((1 - f) + a .* e2 ./ r));

lon = atan(y ./ x);
lat = atan((z .* (1 - f) + e2 .* a .* (sin(mu)).^3) ./ ((1 - f) .* (sqrt(x.^2 + y.^2) - e2 .* a .* cos(mu).^3)));
hgt = sqrt(x.^2 + y.^2) .* cos(lat) + z .* sin(lat) - a .* sqrt(1 - e2 .* sin(lat).^2);

[lon, lat] = convert_deg(lon, lat);
end 