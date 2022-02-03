function MainDRE(varargin) 
rootBathy      =   getVararginValue(varargin, 'rootBathy', 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry');
bathyFile      =   getVararginValue(varargin, 'bathyFile', '2008 HI1240 Runabay Head to Tuns.csv'); % Bathymetric file in WGS84
inputSRC       =   getVararginValue(varargin, 'inputSRC', 'WGS84'); % SRC of the input bathyFile 
mooringPos     =   getVararginValue(varargin, 'mooringPos', [-6.427, 55.3, -65.33]); % [lon0, lat0, hgt0]
mooringName    =   getVararginValue(varargin, 'mooringName', 'MooringTest');
listAz         =   getVararginValue(varargin, 'listAz', 0.1:10:360); % List of azimuth to process (in degree) 
drBathy        =   getVararginValue(varargin, 'drBathy', 100); % Horizontal resolution for bathymetric profile 
freq           =   getVararginValue(varargin, 'freq', 1000); % Central frequency 
SSP            =   getVararginValue(varargin, 'SPP', []); % Sound Speed Profile at Mooring Position: struct -> SSP.depth, SSP.
% SSPType      =   getVararginValue(varargin, 'SSPType', '1D'); % Type of SSP: '1D' (profile at mooring point) or '2D' (several profiles along the 2D bathy profile)
SL             =   getVararginValue(varargin, 'SL', 100); % Source level in decibel (dB) 
NL             =   getVararginValue(varargin, 'NL', 30); % Noise level for the frequency band (Wenz model or smthg else) 
rMax           =   getVararginValue(varargin, 'rMax', 2000); % Maximum distance based on literature 

%% Convert bathymetric data set from inputSRC to ENU using mooringPos
if ~exist(fullfile(rootBathy ,'ENU', bathyFile), 'file')
    varConvBathy = {'bathyFile', bathyFile, 'SRC_source', inputSRC, 'SRC_dest', 'ENU', 'mooringPos', mooringPos};
    fprintf('Conversion of bathymetry data \n\tBathy file: %s \n\t%s -> %s ', bathyFile, inputSRC, 'ENU');
    data = convertBathyFile(varConvBathy{:});
    data = table2array(data);
else
    fprintf('Load existing bathymetry data \n\tBathy file: %s \n\tSRC: %s', bathyFile, 'ENU');
    data = readmatrix(fullfile(rootBathy ,'ENU', bathyFile), 'Delimiter', ' ');
end

% %% Plot bathymetric map (ENU)
% varPlotBathy = {'bathyFile', bathyFile, 'SRC', 'ENU'};
% plotBathy(varPlotBathy{:})

%% Settings 
% Source 
Pos.s.z = 10; % Source depth
% Receiver 
recStep.range = 0.01; % Range step (km) between receivers: more receivers increase accuracy but also increase CPU time 
recStep.z = 0.5; % Depth step (m) between receivers: more receivers increase accuracy but also increase CPU time 
% Beam 
Beam.RunType(1) = 'C'; % 'C': Coherent, 'I': Incoherent, 'S': Semi-coherent, 'R': ray, 'E': Eigenray, 'A': Amplitudes and travel times 
Beam.RunType(2) = 'B'; % 'G': Geometric beams (default), 'C': Cartesian beams, 'R': Ray-centered beams, 'B': Gaussian beam bundles.
Beam.Nbeams = 5001; % Number of launching angles
Beam.alpha = [-80, 80]; % Launching angles in degrees
Beam.deltas = 0; % Ray-step (m) used in the integration of the ray and dynamic equations, 0 let bellhop choose 
% Top boundary 
topOption = 'SVW'; % To describe 

%% Main process 
fprintf('Starting DRE\n');

rootSaveResult = fullfile('C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Result', mooringName);
if ~exist(rootSaveResult, 'dir'); mkdir(rootSaveResult);end

listDetectionRange = [];
for theta = listAz 
    %% Extract 2D profile
    fprintf('Extraction of 2D profile, azimuth = %2.1f°\n', theta);
    varGetProfiles = {'rootBathy', rootBathy, 'bathyFile', bathyFile, 'SRC', 'ENU', 'dr', drBathy, 'data', data, 'theta', theta, 'rMax', rMax};
    [dataProfile] = getBathy2Dprofile(varGetProfiles{:});
    
    bathyProfile.z = dataProfile.z;
    bathyProfile.range = dataProfile.r; 
    
    dataProfile = table2array(dataProfile);
    
    %% Create bty file 
    interpMethodBTY = 'L';  % 'L' Linear piecewise, 'C' Curvilinear  
    nameProfile = sprintf('%s%2.1f', mooringName, theta);
    BTYfilename = sprintf('%s.bty', nameProfile);
    fprintf('Creation of bty file \n\tfilename = %s\n', BTYfilename);
    writebdry(fullfile(rootSaveResult, BTYfilename), interpMethodBTY, dataProfile)
    
    %% Set environment 
    % SSP 
    % TODO: replace by importation function call to get SSP
    SSP.z = [0, 100, 200];
    SSP.c = [1500, 1542, 1512];
    if max(SSP.z) < max(dataProfile(:, 2))
        SSP.z(end+1) = floor(max(dataProfile(:, 2))) + 1;  % Assert bathy doesn't drops below lowest point in the sound speed profile 
        SSP.c(end+1) = SSP.c(end);          % Extend ssp 
    end

    % Bottom properties 
    % TODO: replace by importation function call to get bottom properties
    % from ascii file (Chris) 
    bott.c = 1600; % Sound celerity in bottom half space 
    bott.ssc = 0.0; % Shear Sound Celerity in bottom half space 
    bott.rho = 1.8; % Density in bottom half space 
    bott.cwa = 0.8; % Compression Wave Absorption in bottom half space 
    bott.swa = []; % Shear Wave Absorption in bottom half space 
    
    % Beam 
    % Dimensions used to stop the tracing of rays leaving the box
    Beam.Box.z = max(SSP.z) + 10; % zmax (m), larger than SSP max depth to avoid problems  
    Beam.Box.r = max(dataProfile(:, 1)) + 0.1; % rmax (km), larger than bathy max range to avoid problems 
    
    % Receivers
    Pos.r.range = 0:recStep.range:max(dataProfile(:, 1)); % Receiver ranges (km)
    Pos.r.z = 0:recStep.z:max(dataProfile(:, 2)); % Receiver depths (m)
    
    envfile = fullfile(rootSaveResult, nameProfile);
    varEnv = {'envfil', envfile, 'freq', freq, 'SSP', SSP, 'Pos', Pos,...
        'Beam', Beam, 'BOTTOM', bott, 'topOption', topOption, 'TitleEnv', nameProfile};
    writeEnvDRE(varEnv{:})
%     write_env( envfil, model, TitleEnv, freq, SSP, Bdry, Pos, Beam, cInt, RMax)
    %% Run BELLHOP
    cd(rootSaveResult)
    bellhop( nameProfile )

    %% Plot TL  
    figure;
    plotshd( sprintf('%s.shd', nameProfile) );
    plotbty( nameProfile );
    saveas(gcf, sprintf('%sTL.png', nameProfile));
    close(gcf);
    
    %% Compute and plot SPL 
    varSpl = {'filename',  sprintf('%s.shd', nameProfile), 'SL', SL};
    [SPL, zt, rt] = computeSPL(varSpl{:});
    figure;
    plotSPL(varSpl{:});
    plotbty( nameProfile );
    saveas(gcf, sprintf('%sSPL.png', nameProfile));
    close(gcf);
    
    computeArgin = {'SPL', SPL, 'Depth', zt, 'Range', rt, 'NL', NL, 'DT', 10, 'zTarget', 15};
    DetectionRange = computeDetectionRange(computeArgin{:});
    listDetectionRange = [listDetectionRange DetectionRange];

end
figure;
polarplot(listAz * pi / 180, listDetectionRange)
%% Plot bathymetric map (ENU)
figure;
varPlotBathy = {'bathyFile', bathyFile, 'SRC', 'ENU'};
plotBathy(varPlotBathy{:})
xx = listDetectionRange .* cos(listAz * pi / 180);
yy = listDetectionRange .* sin(listAz * pi / 180);
plot(xx, yy)

end 