function plotDetectionProbability2D(listAz, rt, listDetectionFunction)
%PLOTDETECTIONPROBABILITY2D Summary of this function goes here
%   Detailed explanation goes here
if ~obj.DPDataIsGridded; obj.gridDPData; end

% ntheta = numel(listAz);
% nrt = numel(rt);
% 
% E = ones([ntheta*nrt, 1]);
% N = ones([ntheta*nrt, 1]);
% G = ones([ntheta*nrt, 1]);
% 
% for i = 1:ntheta
%     theta_i = listAz(i);
%     g_i = listDetectionFunction(i, :);
%     [E_i, N_i, G_i] = pol2cart(theta_i, rt, g_i);
%     E(1 + (i-1)*nrt:i*nrt) = E_i;
%     N(1 + (i-1)*nrt:i*nrt) = N_i;
%     G(1 + (i-1)*nrt:i*nrt) = G_i;
% end
% 
% pts = 1E+3;
% xGrid = linspace(min(E, [], 'all'), max(E, [], 'all'), pts);
% yGrid = linspace(min(N, [], 'all'), max(N, [], 'all'), pts);
% [X, Y] = meshgrid(xGrid, yGrid);
% P = griddata(E, N, G, X, Y, 'cubic');
    
% figure    
pcolor(obj.Xgrid, obj.Ygrid, obj.DPgrid);
shading interp
% 
% IdxAlpha_P = (P <= 0.1);
% imAlpha = ones(size(P)); % want to make it translucent?
% imAlpha(IdxAlpha_P) = 0.05;
% set(h, 'AlphaData', imAlpha);
% 
% colormap(flipud(bone))
colormap(flipud(hot))
% alpha (h, 0.1)
% alpha (h, 'scaled')

c = colorbar;
c.Label.String = 'Detection probability';
caxis([0, 1])
hold on 
scatter(0, 0, 'filled', 'red') 
% title('Detection probability')
xlabel('E [m]')
ylabel('N [m]')
legend({'', '', 'Mooring'})
end

