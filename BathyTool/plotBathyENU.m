function plotBathyENU(rootBathy, bathyFile)
% root = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\ENU'; 
D = readtable(fullfile(rootBathy, bathyFile));
E = table2array(D(:,1));
N = table2array(D(:,2));
U = table2array(D(:,3));

pts = 1E+3;
xGrid = linspace(min(E), max(E), pts);
yGrid = linspace(min(N), max(N), pts);
[X,Y] = meshgrid(xGrid, yGrid);
zDep = griddata(E, N, U, X, Y);

figure
contourf(X, Y, zDep)
c = colorbar;
c.Label.String = 'Elevation (m)';
hold on 
scatter(0, 0, 'filled', 'red') 
title('Bathymetry - frame ENU')
xlabel('E [m]')
ylabel('N [m]')
end