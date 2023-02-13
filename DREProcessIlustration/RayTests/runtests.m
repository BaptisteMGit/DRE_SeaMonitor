function runtests()
%% runtests()
% plot eigenrays for a given 2D bathymetry profile to illustrate
% equivalence principle used to estimate Detection Range 
global units
units = 'km';


% %% Load Batymetry data 
% rootBathy = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\ENU\2DProfile\2008 HI1240 Runabay Head to Tuns';
% bathyFile = '2DBathy_azimuth10.1.txt';
% data = readmatrix(fullfile(rootBathy, bathyFile), 'Delimiter',' ');
% 
% %% Create bty file 
% testName = 'eqPrinciple';
% rootBTY = 'C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_MATLAB\DREProcessIlustration';
% BTYfilename = sprintf('%s.bty', testName);
% writebdry(fullfile(rootBTY, BTYfilename), 'L', data)

cd 'C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_SeaMonitor\DREProcessIlustration\RayTests';

%% Rays
% bellhop( 'eqPrinciple_ray' ) % Run BELLHOP model for env file 
% figure
% plotray( 'eqPrinciple_ray' ) % Plot ray 
% plotbty 'eqPrinciple' % Superpose bathy 

bellhop( 'testEquivalence_ray' ) % Run BELLHOP model for env file 
figure
plotray( 'testEquivalence_ray' ) % Plot ray 
plotbty 'testEquivalence_ray' % Superpose bathy 

%% Eigenrays
% bellhop( 'eqPrinciple_eigenray' ) % Run BELLHOP model for env file 
% figure
% plotray( 'eqPrinciple_eigenray' ) % Plot ray 
% plotbty 'eqPrinciple' % Superpose bathy 
% 
% % bellhop( 'testEquivalence_eigenray' ) % Run BELLHOP model for env file 
% % figure
% % plotray( 'testEquivalence_eigenray' ) % Plot ray 
% % plotbty 'testEquivalence_eigenray' % Superpose bathy 
% 
% scatter(0, 10, 50, 'k', 'filled') % Receiver 
% scatter(2000, 40, 50, 'r', 'filled') % Source 
% set(gca, 'XDir', 'reverse')
% rLabel = flipud(get(gca, 'XTickLabel'));
% set(gca, 'XTickLabel', rLabel)
% 
% legend({'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ...
%     '', '', '', '', '', '', '', '',  '', '', '', '', '', '', '', '', '', ...
%     'Receiver', 'Source'})
% title({'Simulated situation'})

figure
plotray( 'eqPrinciple_eigenray' ) % Plot ray 
plotbty 'eqPrinciple' % Superpose bathy 
hold on 
s1 = scatter(0, 10, 100, 'r', 'filled'); 
hold on 
s2 = scatter(2, 40, 100, 'filled');
s2.MarkerFaceColor = 'blue';

set(gca, 'XDir', 'reverse')
rLabel = flipud(get(gca, 'XTickLabel'));
set(gca, 'XTickLabel', rLabel)
legend({'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ...
    '', '', '', '', '', '', '', '',  '', '', '', '', '', '', '', '', '', ...
    'Source', 'Receiver'})
title({'Real situation'})



%% TL 
% bellhop( 'eqPrinciple' ) % Run BELLHOP model for env file 
figure
plotshd( 'eqPrinciple.shd' ) % Plot ray 
plotbty 'eqPrinciple' % Superpose bathy 

%% TL slices 
figure
% Range slice
receiverDepth = 30;
plottlr( 'eqPrinciple.shd', receiverDepth )
% Depth slice
receiverRange = 2.5;
plottld( 'eqPrinciple.shd', receiverRange )


% %% Range-dependent environment: SSP;
% testName = 'RangeDepSSP';
% % Create bty file
% % writebdry(fullfile(rootBTY, testName), 'L', data)
% 
% % Compute TL
% bellhop(testName)
% figure 
% plotssp2d(testName)
% figure
% plotshd(sprintf('%s.shd', testName))
% plotbty(testName)

%% Beam type effect 
% Geometric beam
% bellhop('BeamType_G')
% plotshd('BeamType_G.shd', 1, 2, 1)

% Gaussian Beam
% bellhop('BeamType_B')
% plotshd('BeamType_B.shd', 1, 2, 2)

% Plot manually instead of using plotshd to use the same color bar so that
% one can compare easily the two graphs 
% figure
itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
tej = flipud( jet( 256 ) );  % 'jet' colormap reversed

% Gaussian beam
[ PlotTitle, ~, freqVec, ~, ~, Pos, pressure_G ] = read_shd( 'BeamType_G.shd' );
freq = freqVec( 1 );
pressure_G = squeeze( pressure_G( itheta, isz, :, : ) );

zt       = Pos.r.z;
rt       = Pos.r.r;
% set labels in m or km
xlab     = 'Range (m)';
if ( strcmp( units, 'km' ) )
   rt      = rt / 1000.0;
   xlab    = 'Range (km)';
end

tlt_G = double( abs( pressure_G ) );   % pcolor needs 'double' because field.m produces a single precision
tlt_G( isnan( tlt_G ) ) = 1e-6;   % remove NaNs
tlt_G( isinf( tlt_G ) ) = 1e-6;   % remove infinities
icount = find( tlt_G > 1e-37 );        % for stats, only these values count
tlt_G( tlt_G < 1e-37 ) = 1e-37;          % remove zeros
tlt_G = -20.0 * log10( tlt_G );          % so there's no error when we take the log

tlmed_G = median( tlt_G( icount ) );    % median value
tlstd_G = std( tlt_G( icount ) );       % standard deviation
tlmax_G = tlmed_G + 0.75 * tlstd_G;       % max for colorbar
tlmax_G = 10 * round( tlmax_G / 10 );   % make sure the limits are round numbers
tlmin_G = tlmax_G - 50;                 % min for colorbar

% subplot(1, 2, 1)
% h = pcolor( rt, zt, tlt_G );  ...
%   shading flat
% colormap( tej )
% caxisrev( [ tlmin_G, tlmax_G ] )
% set( gca, 'YDir', 'Reverse' )
% xlabel( xlab )
% ylabel( 'Depth (m)' );
% title( { deblank( PlotTitle ); [ 'Freq = ' num2str( freq ) ' Hz    z_{src} = ' num2str( Pos.s.z( isz ) ) ' m' ] } )

[ PlotTitle, ~, freqVec, ~, ~, Pos, pressure_B ] = read_shd( 'BeamType_B.shd' );
pressure_B = squeeze( pressure_B( itheta, isz, :, : ) );
tlt_B = double( abs( pressure_B ) );   % pcolor needs 'double' because field.m produces a single precision
tlt_B( isnan( tlt_B ) ) = 1e-6;   % remove NaNs
tlt_B( isinf( tlt_B ) ) = 1e-6;   % remove infinities
icount = find( tlt_B > 1e-37 );        % for stats, only these values count
tlt_B( tlt_B < 1e-37 ) = 1e-37;          % remove zeros
tlt_B = -20.0 * log10( tlt_B );          % so there's no error when we take the log
% 
% subplot(1, 2, 2)
% h = pcolor( rt, zt, tlt_G );  ...
% shading flat
% colormap( tej )
% caxisrev( [ tlmin_G, tlmax_G ] )
% set( gca, 'YDir', 'Reverse' )
% xlabel( xlab )
% ylabel( 'Depth (m)' );
% title( { deblank( PlotTitle ); [ 'Freq = ' num2str( freq ) ' Hz    z_{src} = ' num2str( Pos.s.z( isz ) ) ' m' ] } )

% Difference 
delta_tlt = tlt_G -  tlt_B;
delta_tlmed = median( delta_tlt( icount ) );    % median value
delta_tlstd = std( delta_tlt( icount ) );       % standard deviation
delta_tlmax = delta_tlmed + 0.75 * delta_tlstd;       % max for colorbar
delta_tlmax = 10 * round( delta_tlmax / 10 );   % make sure the limits are round numbers
delta_tlmin = delta_tlmax - 50;                 % min for colorbar

figure
h = pcolor( rt, zt, delta_tlt );  ...
shading flat
caxisrev( [ -30, 30] )
colormap(bluewhitered)
set( gca, 'YDir', 'Reverse' )
xlabel( xlab )
ylabel( 'Depth (m)' );
plotbty 'BeamType_B'

figure
h = pcolor( rt, zt, delta_tlt );  ...
shading flat
caxisrev( [ -30, 30] )
colormap(bluewhitered)
set( gca, 'YDir', 'Reverse' )
xlabel( xlab )
ylabel( 'Depth (m)' );








