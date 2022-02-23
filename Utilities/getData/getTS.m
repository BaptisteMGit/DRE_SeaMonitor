function [T, S, D] = getTS(mooring, rootSaveInput, bBox, tBox, dBox)
%% Query T, S data from CMEMS
% motuPath = 'http://nrt.cmems-du.eu/motu-web/Motu';
% dbName = 'GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS';
% productName = 'global-analysis-forecast-phy-001-024';

% Fix to allow simulation prior to 01/01/2019 which is the low limit date
% for global-analysis-forecast-phy-001-024 model
lowerLimitDate_024 = datetime('2019-01-01', 'InputFormat', 'yyyy-MM-dd');
upperLimitDate_030 = datetime('2019-12-31', 'InputFormat', 'yyyy-MM-dd');

if tBox.stopDate <= lowerLimitDate_024
    motuPath = 'http://my.cmems-du.eu/motu-web/Motu'; % MY server 
    dbName = 'GLOBAL_MULTIYEAR_PHY_001_030-TDS';
    productName = 'cmems_mod_glo_phy_my_0.083_P1M-m';
    % For monthly-mean data dates need to be updated to fit with the
    % requirement mean goes from 16th to next 16th
    tBox.startDate.Day = 16;
    tBox.stopDate.Day = 16;

elseif tBox.startDate >= lowerLimitDate_024
    motuPath = 'http://nrt.cmems-du.eu/motu-web/Motu';
    dbName = 'GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS';
    productName = 'global-analysis-forecast-phy-001-024';
    tBox.startDate.Hour = 12;
    tBox.stopDate.Hour = 12;
else % TODO: To be modified for dates covering both periods --> need to be fix 
    motuPath = 'http://nrt.cmems-du.eu/motu-web/Motu'; % NRT server 
    dbName = 'GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS';
    productName = 'global-analysis-forecast-phy-001-024';
    tBox.startDate.Hour = 12;
    tBox.stopDate.Hour = 12;
end

% bBox = setbBoxAroundMooring(mooring.mooringPos); % Boundary box
% tBox = gettBox(mooring.deploymentDate.startDate, mooring.deploymentDate.stopDate); % Time box
% dBox = getdBox(0, maxDepth); % Depth box 

variables = {'thetao', 'so'}; % T, S
outputDir = rootSaveInput; % Dir to save the profile used 
outputFile = sprintf('TempSalinity_%s_%s.nc', datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd'));

oceanoArgin = {'dbName', dbName, 'productName', productName, ...
                'bBox', bBox, 'tBox', tBox, 'dBox', dBox, ...
                'variables', variables, 'outputDir', outputDir, ...
                'outputFile', outputFile, 'motuPath', motuPath};

promptMsg = 'Downloading T, S from CMEMS';
fprintf(promptMsg)
getDataFromCMEMS(oceanoArgin{:})
linePts = repelem('.', 53 - numel(promptMsg));
fprintf(' %s DONE\n', linePts);


%% Read data
fileNETCDF = fullfile(outputDir, outputFile);
data = getDataFromNETCDF(fileNETCDF);

% For the moment T and S are mean value in the area of interest and time
% averaged (4th dimension -> data are matrix with shape [nx, ny, nz, nt])
% T, S are averaged over the dimensions 1, 2 and 4 corresponding to x, y, t
% and thus the returned values only depend on depth 
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
    sprintf('Temporal mean from %s to %s', datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd'))})
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
    sprintf('Temporal mean from %s to %s', datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd'))})
hold on
scatter(mooring.mooringPos.lon, mooring.mooringPos.lat, 'r', 'filled')
saveas(gcf, fullfile(rootSaveInput, 'SalinitySpatial.png'));

%% Temporal evolution 
% time = datetime(tBox.startDate(1:10)):1:datetime(tBox.stopDate(1:10));
% Visualize temporal evolution of the mean temperature 
figure('Visible','off')
meanT = mean(data.thetao, [1, 2, 3], 'omitnan');
meanT = reshape(meanT, [1, numel(meanT)]);

if tBox.stopDate <= lowerLimitDate_024
    time = tBox.startDate:calmonths(1):tBox.stopDate;
    for i=1:numel(meanT)
        hold on 
        plot([time(i), time(i+1)], [meanT(i), meanT(i)]); % Constant value over the month (monthly-averaged)
    end
elseif tBox.startDate >= lowerLimitDate_024
    time = tBox.startDate:1:tBox.stopDate;
    plot(time, meanT)
else % TODO: To be modified for dates covering both periods --> need to be fix 
    time = tBox.startDate:1:tBox.stopDate;
    plot(time, meanT)
end
% plot(time, meanT)
xlabel('Time')
ylabel('Temperature °C')
xtickangle(30)
title({sprintf('Mean temperature evolution from %s to %s', datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd')), ...
    sprintf('lon = [%.2f, %.2f]  lat = [%.2f, %.2f]', min(data.longitude), max(data.longitude), min(data.latitude), max(data.latitude))})
saveas(gcf, fullfile(rootSaveInput, 'TemperatureTemporal.png'));

% Visualize temporal evolution of the mean salinity 
figure('Visible','off')
meanS = mean(data.so, [1, 2, 3], 'omitnan');
meanS = reshape(meanS, [1, numel(meanS)]);

if tBox.stopDate <= lowerLimitDate_024
    time = tBox.startDate:calmonths(1):tBox.stopDate;
    for i=1:numel(meanS)
        hold on 
        plot([time(i), time(i+1)], [meanS(i), meanS(i)], '-b'); % Constant value over the month (monthly-averaged)
    end
elseif tBox.startDate >= lowerLimitDate_024
    time = tBox.startDate:1:tBox.stopDate;
    plot(time, meanS)
else % TODO: To be modified for dates covering both periods --> need to be fix 
    time = tBox.startDate:1:tBox.stopDate;
    plot(time, meanS)
end

legend()
xlabel('Time')
ylabel('Salinity ppt')
xtickangle(30)
title({sprintf('Mean salinity evolution from %s to %s', datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd')), ...
    sprintf('lon = [%.2f, %.2f]  lat = [%.2f, %.2f]', min(data.longitude), max(data.longitude), min(data.latitude), max(data.latitude))})
saveas(gcf, fullfile(rootSaveInput, 'SalinityTemporal.png'));

end
