function plotBathyENU(filename)
root = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\ENU'; 
D = readmatrix(sprintf('%s\\%s',root, filename), 'Delimiter',' ');
E = D(:,1);
N = D(:,2);
U = D(:,3);

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