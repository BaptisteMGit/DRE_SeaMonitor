function [lon_rad, lat_rad] = convert_rad(lon, lat)
%% Conversion lon, lat: degree -> rad 
lon_rad = lon * pi / 180;
lat_rad = lat * pi / 180;
end