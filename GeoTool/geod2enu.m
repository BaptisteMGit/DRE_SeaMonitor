function [E, N, U] = geod2enu(lon0, lat0, hgt0, lon, lat, hgt)
%% Function geod2enu:
% computes local coordinates e [m], n [m], u [m] with respect to
% a reference point given by its geodetic coordinates from geodetic coordinates
% longitude [deg], latitude [deg], height [m] 
%     % lon0: Longitude du centre du rep�re local en degr�s d�cimaux
%     % lat0: Latitude du centre du rep�re local en degr�s d�cimaux
%     % hgt0: Hauteur ellipsoidal du centre du rep�re local en m
%     % lon: Longitude du point consid�r� en degr�s d�cimaux
%     % lat: Latitude du point consid�r� en degr�s d�cimaux
%     % hgt: Hauteur ellipsoidal du point consid�r� en m 
%     % return: E, N, U

[x0, y0, z0] = geod2ecef(lon0, lat0, hgt0);
[x, y, z] = geod2ecef(lon, lat, hgt);
[lon0, lat0] = convert_rad(lon0, lat0);

R = [[-sin(lon0), cos(lon0), 0]
    [-sin(lat0) * cos(lon0), -sin(lat0) * sin(lon0), cos(lat0)]
    [cos(lat0) * cos(lon0), cos(lat0) * sin(lon0), sin(lat0)]];

X = ([x - x0, y - y0, z - z0]).';
A = R*X;

E = A(1, :).';
N = A(2, :).';
U = A(3, :).';
end    