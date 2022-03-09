function gridDPData(obj)
%GRIDDPDATA Summary of this function goes here
%   Grid Detection probability data 
if ~obj.bathyDataIsGridded; obj.gridBathyData; end
cd(obj.rootOutputFiles) 

ntheta = numel(obj.listAz);
nrt = numel(obj.rt);

E = ones([ntheta*nrt, 1]);
N = ones([ntheta*nrt, 1]);
G = ones([ntheta*nrt, 1]);

for i = 1:ntheta
    theta_i = obj.listAz(i);
    g_i = obj.listDetectionFunction(i, :);
    [E_i, N_i, G_i] = pol2cart(theta_i*pi/180, obj.rt, g_i);
    E(1 + (i-1)*nrt:i*nrt) = E_i;
    N(1 + (i-1)*nrt:i*nrt) = N_i;
    G(1 + (i-1)*nrt:i*nrt) = G_i;
end

% pts = 1E+3;
% xGrid = linspace(min(E, [], 'all'), max(E, [], 'all'), pts);
% yGrid = linspace(min(N, [], 'all'), max(N, [], 'all'), pts);
% [X, Y] = meshgrid(xGrid, yGrid);

obj.DPgrid = griddata(E, N, G, obj.Xgrid, obj.Ygrid, 'nearest');
obj.DPDataIsGridded = 1;
cd(obj.rootApp)

end

