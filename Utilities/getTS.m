function [T, S, D] = getTS(mooring, rootSaveInput, bBox, tBox, dBox)
%% Query T, S data from CMEMS
motuPath = 'http://nrt.cmems-du.eu/motu-web/Motu';
dbName = 'GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS';
productName = 'global-analysis-forecast-phy-001-024';

% bBox = setbBoxAroundMooring(mooring.mooringPos); % Boundary box
% tBox = gettBox(mooring.deploymentDate.startDate, mooring.deploymentDate.stopDate); % Time box
% dBox = getdBox(0, maxDepth); % Depth box 

variables = {'thetao', 'so'}; % T, S
outputDir = rootSaveInput; % Dir to save the profile used 
outputFile = sprintf('TempSalinity_%s_%s.nc', tBox.startDate(1:10), tBox.stopDate(1:10));

oceanoArgin = {'dbName', dbName, 'productName', productName, ...
                'bBox', bBox, 'tBox', tBox, 'dBox', dBox, ...
                'variables', variables, 'outputDir', outputDir, ...
                'outputFile', outputFile, 'motuPath', motuPath};

getDataFromCMEMS(oceanoArgin{:})

%% Read data
fileNETCDF = fullfile(outputDir, outputFile);
data = getDataFromNETCDF(fileNETCDF);

% For the moment T and S are mean value in the area of interest 
T = mean(data.thetao, [1, 2, 4], 'omitnan');
S = mean(data.so, [1, 2, 4], 'omitnan');
D = data.depth;

%% Spatial evolution 
% % Visualize mean temperature in the bBox 
figure('Visible','off')
meanThetao = mean(data.thetao, [3, 4], 'omitnan');
meanThetao = meanThetao';
imagesc(data.longitude, data.latitude, meanThetao, 'AlphaData', ~isnan(meanThetao))
set(gca, 'Color', [132 67 32]/256) 
xlabel('lon (°)')
ylabel('lat (°)')
set( gca, 'YDir', 'normal' )
a = colorbar;
a.Label.String = 'Temperature °C';
title({'Mean temperature over the water column', ...
    sprintf('Temporal mean from %s to %s', tBox.startDate(1:10), tBox.stopDate(1:10))})
hold on
scatter(mooring.mooringPos.lon, mooring.mooringPos.lat, 'r', 'filled')
saveas(gcf, fullfile(rootSaveInput, 'TemperatureSpatial.png'));

% % Visualize mean salinity in the bBox 
figure('Visible','off')
meanSo = mean(data.so, [3, 4], 'omitnan');
meanSo = meanSo';
imagesc(data.longitude, data.latitude, meanSo, 'AlphaData', ~isnan(meanSo))
set(gca, 'Color', [132 67 32]/256) 
xlabel('lon (°)')
ylabel('lat (°)')
set( gca, 'YDir', 'normal' )
a = colorbar;
a.Label.String = 'Salinity ppt';
title({'Mean salinity over the water column', ...
    sprintf('Temporal mean from %s to %s', tBox.startDate(1:10), tBox.stopDate(1:10))})
hold on
scatter(mooring.mooringPos.lon, mooring.mooringPos.lat, 'r', 'filled')
saveas(gcf, fullfile(rootSaveInput, 'SalinitySpatial.png'));

%% Temporal evolution 
time = datetime(tBox.startDate(1:10)):1:datetime(tBox.stopDate(1:10));

% Visualize temporal evolution of the mean temperature 
figure('Visible','off')
meanT = mean(data.thetao, [1, 2, 3], 'omitnan');
meanT = reshape(meanT, [1, numel(meanT)]);
plot(time, meanT)
xlabel('Time')
ylabel('Temperature °C')
xtickangle(30)
title({sprintf('Mean temperature evolution from %s to %s', tBox.startDate(1:10), tBox.stopDate(1:10)), ...
    sprintf('lon = [%.2f, %.2f]  lat = [%.2f, %.2f]', min(data.longitude), max(data.longitude), min(data.latitude), max(data.latitude))})
saveas(gcf, fullfile(rootSaveInput, 'TemperatureTemporal.png'));

% Visualize temporal evolution of the mean salinity 
figure('Visible','off')
meanS = mean(data.so, [1, 2, 3], 'omitnan');
meanS = reshape(meanS, [1, numel(meanS)]);
plot(time, meanS)
xlabel('Time')
ylabel('Salinity ppt')
xtickangle(30)
title({sprintf('Mean salinity evolution from %s to %s', tBox.startDate(1:10), tBox.stopDate(1:10)), ...
    sprintf('lon = [%.2f, %.2f]  lat = [%.2f, %.2f]', min(data.longitude), max(data.longitude), min(data.latitude), max(data.latitude))})
saveas(gcf, fullfile(rootSaveInput, 'SalinityTemporal.png'));

end
