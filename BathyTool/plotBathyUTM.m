function plotBathyUTM(filename)
root = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\UTM'; 
D = readmatrix(sprintf('%s\\%s',root, filename), 'Delimiter',' ');
xUTM = D(:,1);
yUTM = D(:,2);
Dep = D(:,3);

pts = 1E+3;
xGrid = linspace(min(xUTM), max(xUTM), pts);
yGrid = linspace(min(yUTM), max(yUTM), pts);
[X,Y] = meshgrid(xGrid, yGrid);
zDep = griddata(xUTM, yUTM, Dep, X, Y);

figure
contourf(X, Y, zDep)
c = colorbar;
c.Label.String = 'Elevation (m)';
title('Bathymetry - frame UTM29')
xlabel('X [m]')
ylabel('Y [m]')

end