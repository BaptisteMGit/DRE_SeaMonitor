function pH = getPH(mooring, maxDepth, rootSaveInput)
dbName = 'GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS';
productName = 'global-analysis-forecast-phy-001-024';
bBox = setbBoxAroundMooring(mooring.mooringPos); % Boundary box
tBox = gettBox(mooring.deploymentDate.startDate, mooring.deploymentDate.stopDate); % Time box
dBox = getdBox(0, maxDepth); % Depth box 
variables = {'thetao', 'so'}; % T, S
outputDir = rootSaveInput; % Dir to save the profile used 
outputFile = sprintf('TSprofile_%s_%s.nc', tBox.startDate, tBox.stopDate);

oceanoArgin = {'dbName', dbName, 'productName', productName, ...
                'bBox', bBox, 'tBox', tBox, 'dBox', dBox, ...
                'variables', variables, 'outputDir', outputDir, ...
                'outputFile', outputFile};

getDataFromCMEMS(oceanoArgin{:})

end