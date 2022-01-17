function [T] = getBathy2Dprofile(varargin)
%% getBathy2Dprofile: extract 2D profile from bathymetry file 
% 
rootBathy = getVararginValue(varargin, 'rootBathy', '');
bathyFile = getVararginValue(varargin, 'bathyFile', '');
D = getVararginValue(varargin, 'data', []);
SRC = getVararginValue(varargin, 'SRC', 'ENU');
theta = getVararginValue(varargin, 'theta', []);
dr = getVararginValue(varargin, 'dr', 100);
rMax = getVararginValue(varargin, 'rMax', []);

theta_rad = theta * pi / 180;
% dr = 50; % Range résolution in meters 

% Change to reduce computing effort without loading bathy data multiple
% times (16/12/2021)
% if istable(D)
%     E = D.E;
%     N = D.N;
%     U = D.U;   
% else
E = D(:,1);
N = D(:,2);
U = D(:,3);
% end

% rmax = 10000; % Maximum range in m 
% %% Plot data set 
% pts = 1E+3;
% xGrid = linspace(min(E), max(E), pts);
% yGrid = linspace(min(N), max(N), pts);
% [X,Y] = meshgrid(xGrid, yGrid);
% zDep = griddata(E, N, U, X, Y);
% 
% figure
% contourf(X, Y, zDep)
% c = colorbar;
% c.Label.String = 'Elevation (m)';
% title('Bathymetry - frame ENU')
% xlabel('E [m]')
% ylabel('N [m]')

%% Reducing dataset used to interpolate z_profile
% Use of only one quarter of the dataset 
% Offset permit to take a larger zone in order to avoid issues with large
% bathymetry cells  
dN = abs(max(diff(N))); % We assume regular grid
dE = abs(max(diff(E))); 
offset = max(dE, dN); 

switch SRC
    case 'ENU'
        if (theta >= 0) && (theta < 90)
           idx = (E > 0 - offset) & (N > 0 - offset);
        elseif (theta >= 90) && (theta < 180)
            idx = (E < 0 + offset) & (N > 0 - offset);
        elseif (theta >= 180) && (theta < 270)
            idx = (E < 0 + offset) & (N < 0 + offset);
        else
            idx = (E > 0 - offset) & (N < 0 + offset);
        end
    case 'UTM'
        
end
E = E(idx);
N = N(idx);
U = U(idx);

rmax = sqrt(max(abs(E)).^2 + max(abs(N)).^2); % Maximum range in m not to go out from the map boundaries 

if rMax && (rmax > rMax)
    rmax = rMax;
end
r = 0:dr:rmax; % Range 

E_profile = r * cos(theta_rad);
N_profile = r * sin(theta_rad);

%% Plot azimuth
% hold on 
% plot(r * cos(theta_rad), r * sin(theta_rad), '--', 'LineWidth', 1, 'Color', 'red')
% 
% % mooring site 
% hold on 
% scatter(0, 0, 50, 'filled', 'red') 

% [EGrid, NGrid] = meshgrid(E_profile, N_profile);
% Z_profile = griddata(E, N, U, EGrid, NGrid);
% tic
% Z_profile = griddata(E, N, U, E_profile, N_profile);
F = scatteredInterpolant(E, N, U);
F.ExtrapolationMethod = 'none';
Z_profile = F(E_profile, N_profile);

%% Save
r = r' / 1000; % Switch to km (required for Bellhop) 
z = Z_profile';
z = -z; % Switch to positive depth toward the bottom 
% Remove NaN 
z = z(~isnan(z));
r = r(~isnan(z));
T = table(r, z);
rootSave = sprintf('%s\\2DProfile\\%s', rootBathy, bathyFile(1:end-4)); 
if ~exist(rootSave, 'dir'); mkdir(rootSave);end
filename2D = sprintf('%s\\2DBathy_azimuth%2.1f.txt', rootSave, theta);
writetable(T, filename2D,'Delimiter',' ', 'WriteVariableNames', 0) 

%%% 
%% CHANGE TO USE the function writebty from Acoustic Toolbox
% %% Modify first row 
% S = fileread(filename2D);
% S = [sprintf('%d\n', height(T)), S];
% fileID = fopen(filename2D,'w');
% fprintf(fileID, S);
% fclose(fileID);

% %% Change file extension to bty
% fileList = dir([rootSave, '\*.txt']); 
% for i = 1:numel(fileList)
%     file = fullfile(rootSave, fileList(i).name);
%     [tempDir, tempFile] = fileparts(file); 
%     status = copyfile(file, fullfile(tempDir, [tempFile, '.bty']));
%     % Delete the .txt file;
%     delete(file)  
%%% 
    
%% Plot 2D profile 
% figure;
% plot(r, z)
% set(gca, 'YDir','reverse')
% ylim([0, max(z)])
% xlabel('Range [m]')
% ylabel('Depth [m]')
% title(sprintf('Bathymetric 2D profile\nAzimuth = %2.1f°', theta))
% % Save 2D plot
% saveas(gcf, sprintf('%s\\2DBathy_azimuth%2.1f.png', rootSave, theta))
% close()

end