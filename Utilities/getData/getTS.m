function [T, S, D] = getTS(mooring, rootSaveInput, bBox, tBox, dBox)

%% Used datasets
% current_date = dd/mm/yyyy
% GLOBAL_ANALYSISFORECAST_PHY_001_024  Analysis and Forecast product is
% available for the period 01/mm+1/yyyy-3 to dd+10/mm/yyyy 
% https://doi.org/10.48670/moi-00016

% GLOBAL_MULTIYEAR_PHY_001_030 reanalysis product is available for the
% period 1 Jan 1993 to 31/12/yyyy - 3 
% https://doi.org/10.48670/moi-00021

today = datetime('today');
dd = today.Day;
mm = today.Month;
yyyy = today.Year;

lowerLimitDate_024 = datetime(yyyy-3, mm+1, 01);
upperLimitDate_024 = datetime(yyyy, mm, dd+9);

lowerLimitDate_030 = datetime(1993, 01, 01);
upperLimitDate_030 = datetime(yyyy-3, 12, 31);

% lowerLimitDate_024 = datetime('2019-01-01', 'InputFormat', 'yyyy-MM-dd');
% upperLimitDate_030 = datetime('2019-12-31', 'InputFormat', 'yyyy-MM-dd');


%% Query T, S data from CMEMS
variables = {'thetao', 'so'}; % T, S
outputDir = rootSaveInput; % Dir to save> the profile used 

if tBox.stopDate <= upperLimitDate_030
    motuPath = 'http://my.cmems-du.eu/motu-web/Motu'; % MY server 
    dbName = 'GLOBAL_MULTIYEAR_PHY_001_030-TDS';
    productName = 'cmems_mod_glo_phy_my_0.083_P1D-m';

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
    
    % Read data
    fileNETCDF = fullfile(outputDir, outputFile);
    data = getDataFromNETCDF(fileNETCDF);

elseif tBox.startDate >= lowerLimitDate_024 && tBox.stopDate <= upperLimitDate_024
    motuPath = 'http://nrt.cmems-du.eu/motu-web/Motu';
    dbName = 'GLOBAL_ANALYSISFORECAST_PHY_001_024-TDS';
    base_productName = 'cmems_mod_glo_phy-%s_anfc_0.083deg_P1D-m';
    
    data = struct();
    for i_v = 1:length(variables)
        var = variables{i_v};
        productName = sprintf(base_productName, var);
        
        outputFile = sprintf('%s_%s_%s.nc', var, datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd'));
        
        oceanoArgin = {'dbName', dbName, 'productName', productName, ...
                        'bBox', bBox, 'tBox', tBox, 'dBox', dBox, ...
                        'variables', {var}, 'outputDir', outputDir, ...
                        'outputFile', outputFile, 'motuPath', motuPath};
        
        promptMsg = sprintf('Downloading %s from CMEMS', var);
        fprintf(promptMsg)
        getDataFromCMEMS(oceanoArgin{:})
        linePts = repelem('.', 53 - numel(promptMsg));
        fprintf(' %s DONE\n', linePts);
            
        % Read data
        fileNETCDF = fullfile(outputDir, outputFile);
        d = getDataFromNETCDF(fileNETCDF);
        data = mergeStruct(data, d);
        
    end

else 
    % Todo : get default values 
    fprintf('Period not covered by CMEMS period')

end



% %% Read data
% fileNETCDF = fullfile(outputDir, outputFile);
% data = getDataFromNETCDF(fileNETCDF);
% 
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

% if strcmp(dbName,'GLOBAL_MULTIYEAR_PHY_001_030-TDS')
%     time = tBox.startDate:calmonths(1):tBox.stopDate;
%     for i=1:numel(meanT)
%         hold on 
%         plot([time(i), time(i+1)], [meanT(i), meanT(i)]); % Constant value over the month (monthly-averaged)
%     end
% elseif strcmp(dbName, 'GLOBAL_ANALYSISFORECAST_PHY_001_024-TDS')
%     time = tBox.startDate:1:tBox.stopDate;
time = tBox.startDate:1:tBox.stopDate;
plot(time, meanT)
% else 
%     time = tBox.startDate:1:tBox.stopDate;
%     plot(time, meanT)
% end
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

% if tBox.stopDate <= lowerLimitDate_024
%     time = tBox.startDate:calmonths(1):tBox.stopDate;
%     for i=1:numel(meanS)
%         hold on 
%         plot([time(i), time(i+1)], [meanS(i), meanS(i)], '-b'); % Constant value over the month (monthly-averaged)
%     end
% elseif tBox.startDate >= lowerLimitDate_024
time = tBox.startDate:1:tBox.stopDate;
plot(time, meanS)
% else % TODO: To be modified for dates covering both periods --> need to be fix 
%     time = tBox.startDate:1:tBox.stopDate;
%     plot(time, meanS)
% end

legend()
xlabel('Time')
ylabel('Salinity ppt')
xtickangle(30)
title({sprintf('Mean salinity evolution from %s to %s', datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd')), ...
    sprintf('lon = [%.2f, %.2f]  lat = [%.2f, %.2f]', min(data.longitude), max(data.longitude), min(data.latitude), max(data.latitude))})
saveas(gcf, fullfile(rootSaveInput, 'SalinityTemporal.png'));

end
