function [T, S] = getTS(mooring, maxDepth, rootSaveInput)
%% Query data from CMEMS
dbName = 'GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS';
productName = 'global-analysis-forecast-phy-001-024';
bBox = setbBoxAroundMooring(mooring.mooringPos); % Boundary box
tBox = gettBox(mooring.deploymentDate.startDate, mooring.deploymentDate.stopDate); % Time box
dBox = getdBox(0, maxDepth); % Depth box 
variables = {'thetao', 'so'}; % T, S
outputDir = rootSaveInput; % Dir to save the profile used 
outputFile = sprintf('TSprofile_%s_%s.nc', tBox.startDate(1:10), tBox.stopDate(1:10));

oceanoArgin = {'dbName', dbName, 'productName', productName, ...
                'bBox', bBox, 'tBox', tBox, 'dBox', dBox, ...
                'variables', variables, 'outputDir', outputDir, ...
                'outputFile', outputFile};

getDataFromCMEMS(oceanoArgin{:})

%% Read data
fileNETCDF = fullfile(outputDir, outputFile);
data = getDataFromNETCDF(fileNETCDF);

end