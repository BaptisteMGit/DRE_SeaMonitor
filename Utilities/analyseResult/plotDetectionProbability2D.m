function plotDetectionProbability2D(listAz, rt, listDetectionFunction)
%PLOTDETECTIONPROBABILITY2D Summary of this function goes here
%   Detailed explanation goes here

n = numel(listAz);
E = [];
N = [];
G = [];
for i = 1:n
    theta_i = listAz(i);
    g_i = listDetectionFunction(i, :);
    [E_i, N_i, G_i] = pol2cart(theta_i, rt, g_i);
    E = [E E_i];
    N = [N N_i];
    G = [G G_i];
end

pts = 1E+3;
xGrid = linspace(min(E), max(E), pts);
yGrid = linspace(min(N), max(N), pts);
[X,Y] = meshgrid(xGrid, yGrid);
P = griddata(E, N, G, X, Y);

figure
h = pcolor(X, Y, P);
shading flat

% IdxAlpha_P = (P <= 0.1);
% imAlpha = 0.1*ones(size(P)); % want to make it translucent?
% imAlpha(IdxAlpha_P) = 0;
% set(h, 'AlphaData', imAlpha);

colormap(flipud(hot))
alpha (h, 'color')
alpha (h, 'scaled')

c = colorbar;
c.Label.String = 'Detection probability';
caxis([0, 1])
hold on 
scatter(0, 0, 'filled', 'red') 
title('Detection probability')
xlabel('E [m]')
ylabel('N [m]')
end

