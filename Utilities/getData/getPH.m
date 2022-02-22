function pH = getPH(mooring, rootSaveInput,  bBox, tBox, dBox)
%% Query pH data from CMEMS
% motuPath = 'https://nrt.cmems-du.eu/motu-web/Motu';
% dbName = 'GLOBAL_ANALYSIS_FORECAST_BIO_001_028-TDS';
% productName = 'global-analysis-forecast-bio-001-028-daily';

% Fix to allow simulation prior to 01/01/2019 which is the low limit date
% for global-analysis-forecast-bio-001-028-daily model
lowerLimitDate_028 = datetime('2019-05-04', 'InputFormat', 'yyyy-MM-dd'); % global-analysis-forecast-bio-001-028-daily
upperLimitDate_029 = datetime('2020-12-31', 'InputFormat', 'yyyy-MM-dd'); % cmems_mod_glo_bgc_my_0.25_P1M-m No daily data available -> monthly 


if tBox.stopDate <= lowerLimitDate_028
    motuPath = 'https://my.cmems-du.eu/motu-web/Motu'; % MY server
    dbName = 'GLOBAL_MULTIYEAR_BGC_001_029-TDS';
    productName = 'cmems_mod_glo_bgc_my_0.25_P1M-m';

    % For monthly-mean data dates need to be updated to fit with the
    % requirement 
    tBox.startDate.Day = 16;    
    tBox.stopDate.Day = 16;

elseif tBox.startDate >= lowerLimitDate_028
    motuPath = 'https://nrt.cmems-du.eu/motu-web/Motu'; % NRT server
    dbName = 'GLOBAL_ANALYSIS_FORECAST_BIO_001_028-TDS';
    productName = 'global-analysis-forecast-bio-001-028-daily';
    tBox.startDate.Hour = 12;
    tBox.stopDate.Hour = 12;
else % TODO: To be modified for dates covering both periods --> need to be fix
    motuPath = 'https://nrt.cmems-du.eu/motu-web/Motu'; % NRT server 
    dbName = 'GLOBAL_ANALYSIS_FORECAST_BIO_001_028-TDS';
    productName = 'global-analysis-forecast-bio-001-028-daily';
    tBox.startDate.Hour = 12;
    tBox.stopDate.Hour = 12;
end

% bBox = setbBoxAroundMooring(mooring.mooringPos); % Boundary box
% tBox = gettBox(mooring.deploymentDate.startDate, mooring.deploymentDate.stopDate); % Time box
% dBox = getdBox(0, maxDepth); % Depth box 

variables = {'ph'}; % pH
outputDir = rootSaveInput; % Dir to save the profile used 
outputFile = sprintf('pH_%s_%s.nc', datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd'));


oceanoArgin = {'dbName', dbName, 'productName', productName, ...
                'bBox', bBox, 'tBox', tBox, 'dBox', dBox, 'variables', variables, ...
                'outputDir', outputDir, 'outputFile', outputFile, 'motuPath', motuPath};

getDataFromCMEMS(oceanoArgin{:})

%% Read data
fileNETCDF = fullfile(outputDir, outputFile);
data = getDataFromNETCDF(fileNETCDF);

% For the moment pH is the mean value in the area of interest 
pH = mean(data.ph, 'all', 'omitnan');

%% Spatial evolution 
% % Visualize mean pH in the bBox 
figure('Visible','off')
meanpH = mean(data.ph, [3, 4], 'omitnan');
meanpH = meanpH';
imagesc(data.longitude, data.latitude, meanpH, 'AlphaData', ~isnan(meanpH))
set(gca, 'Color', [132 67 32]/256) 
xlabel('lon (°)')
ylabel('lat (°)')
set( gca, 'YDir', 'normal' )
a = colorbar;
a.Label.String = 'pH';
title({'Mean pH over the water column', ...
    sprintf('Temporal mean from %s to %s', datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd'))})
hold on
scatter(mooring.mooringPos.lon, mooring.mooringPos.lat, 'r', 'filled')
saveas(gcf, fullfile(rootSaveInput, 'pHSpatial.png'));

%% Temporal evolution 
% Visualize temporal evolution of the mean temperature 
figure('Visible','off')
meanPH_temporal = mean(data.ph, [1, 2, 3], 'omitnan');
meanPH_temporal = reshape(meanPH_temporal, [1, numel(meanPH_temporal)]);

if tBox.stopDate <= lowerLimitDate_028
    time = tBox.startDate:calmonths(1):tBox.stopDate;
    for i=1:numel(meanPH_temporal)
        hold on 
        plot([time(i), time(i+1)], [meanPH_temporal(i), meanPH_temporal(i)], '-b'); % Constant value over the month (monthly-averaged)
    end
elseif tBox.startDate >= lowerLimitDate_028
    time = tBox.startDate:1:tBox.stopDate;
    plot(time, meanPH_temporal)
else % TODO: To be modified for dates covering both periods --> need to be fix 
    time = tBox.startDate:1:tBox.stopDate;
    plot(time, meanPH_temporal)
end

xlabel('Time')
ylabel('pH')
xtickangle(30)
title({sprintf('Mean pH evolution from %s to %s', datestr(tBox.startDate, 'yyyy-mm-dd'), datestr(tBox.stopDate, 'yyyy-mm-dd')), ...
    sprintf('lon = [%.2f, %.2f]  lat = [%.2f, %.2f]', min(data.longitude), max(data.longitude), min(data.latitude), max(data.latitude))})
saveas(gcf, fullfile(rootSaveInput, 'pHTemporal.png'));

% Previous use 
%%%%%% For MULTIOBS_GLO_BIO_CARBON_SURFACE_REP_015_008-TDS model %%%%%
% motuPath = 'https://nrt.cmems-du.eu/motu-web/Motu';
% dbName = 'MULTIOBS_GLO_BIO_CARBON_SURFACE_REP_015_008-TDS'; 
% productName = 'dataset-carbon-rep-monthly';

% bBox = setbBoxAroundMooring(mooring.mooringPos); % Boundary box
% WARNING: The dataset used there uses map coordinates in the CRS EPSG:3395
% WGS 84 / World Mercator whereas our coordinate for the mooring position
% are geodetic coordinates in the CRS WGS84 (with the ellipsoid WGS84). To
% troubleshoot this problem we use the function projfwd to convert our
% coordinates to the desired projection CRS 
% proj = projcrs(3395);
% [bBox.lon.min, bBox.lat.min] = projfwd(proj, bBox.lon.min, bBox.lat.min);
% [bBox.lon.max, bBox.lat.max] = projfwd(proj, bBox.lon.max, bBox.lat.max);

% % Time limit of the dataset = 2020-12-15 00:00:00
% limitDate = '2020-12-15 00:00:00';
% tlimDataset = datetime(limitDate);
% tmax = datetime(mooring.deploymentDate.stopDate); 
% if tmax >= tlimDataset
%     tBox = gettBox(limitDate, limitDate);
% else
%     tBox = gettBox(mooring.deploymentDate.startDate, mooring.deploymentDate.stopDate); % Time box
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end