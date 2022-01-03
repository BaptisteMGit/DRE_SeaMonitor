function [lon_deg, lat_deg] = convert_deg(lon, lat)
%% Conversion lon, lat: rad -> degree 
lon_deg = lon * 180 / pi;
lat_deg = lat * 180 / pi;
end