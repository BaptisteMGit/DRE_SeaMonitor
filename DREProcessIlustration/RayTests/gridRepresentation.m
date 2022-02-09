X = 0:10;
Y = 0:10;
[XX, YY] = meshgrid(X, Y);

figure;
scatter(XX, YY)
set( gca, 'YDir', 'Reverse');
set(gca, 'XAxisLocation', 'top');
xlabel('Range (m)')
ylabel('Depth (m)')
grid("on")