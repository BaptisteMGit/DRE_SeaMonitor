function plotBathyWGS84(filename)
root = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\WGS84'; 
D = readmatrix(sprintf('%s\\%s',root, filename), 'Delimiter',' ');
Lat = D(:,1);
Lon = D(:,2);
Dep = D(:,3);

pts = 1E+3;
xLon = linspace(min(Lon), max(Lon), pts);
yLat = linspace(min(Lat), max(Lat), pts);
[X,Y] = meshgrid(xLon, yLat);
zDep = griddata(Lon, Lat, Dep, X, Y);

figure
contourf(X, Y, zDep)
c = colorbar;
c.Label.String = 'Elevation (m)';
title('Bathymetry - system WGS84 ')
xlabel('Longitude [°]')
ylabel('Latitude [°]')
end