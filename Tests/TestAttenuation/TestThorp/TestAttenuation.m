cd ('C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_SeaMonitor\Tests\TestAttenuation')
removeR = 5; % Nb of range points to be removed 

idtest = 2; 


%% Bellhop with 'M' option and Thorp option : OPTIONS1(3:4) = 'MT'
nameThorp = 'testThorpM';
nameThorpshd = sprintf('%s.shd', nameThorp);
% bellhop( nameThorp )
% figure
subplot(2, 1, 1)
plotshd( nameThorpshd )
plotbty( nameThorp )
caxisrev( [ 20, 80 ] )
a = colorbar;
a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( nameThorpshd );
ztThorp       = Pos.r.z;
rtThorp       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tltThorp = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tltThorp( isnan( tltThorp ) ) = 1e-6;   % remove NaNs
tltThorp( isinf( tltThorp ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tltThorp( tltThorp < 1e-37 ) = 1e-37;          % remove zeros
tltThorp = -20.0 * log10( tltThorp );          % so there's no error when we take the log
tltThorp = tltThorp(:, removeR:end); % Remove first meters to compute statistic 
rtThorp = rtThorp(removeR:end);


%% Bellhop without Thorp option and with 'W' option : OPTIONS1(3) = 'W'
nameWithoutThorp = 'testWithoutThorp';
nameWithoutThorpshd = sprintf('%s.shd', nameWithoutThorp);

% bellhop( nameWithoutThorp )
% figure
subplot(2, 1, 2)
plotshd( sprintf('%s.shd', nameWithoutThorp))
plotbty( nameWithoutThorp )
caxisrev( [ 20, 80 ] )
a = colorbar;
a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( nameWithoutThorpshd );
zt       = Pos.r.z;
rt       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tlt = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tlt( isnan( tlt ) ) = 1e-6;   % remove NaNs
tlt( isinf( tlt ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tlt( tlt < 1e-37 ) = 1e-37;          % remove zeros
tlt = -20.0 * log10( tlt );          % so there's no error when we take the log
tlt = tlt(:, 5:end); % Remove first meters to compute statistic 
rt = rt(removeR:end);


% Compute difference 
delta_tlt = tlt - tltThorp;

figure
h = pcolor( rt, zt, delta_tlt );  ...
  shading flat
% colormap( jet(256) )
caxisrev( [ -5, 5 ] )
set( gca, 'YDir', 'Reverse' )
xlabel( 'Range(km)' );
ylabel( 'Depth (m)' );
title( { 'Delta tlt' ; [ 'Freq = 130kHz' ' Hz    z_{src} = ' num2str( Pos.s.z( isz ) ) ' m' ] } )

a = colorbar;
a.Label.String = 'Delta Transmission Loss (dB)';

%% Compute TL with thorp attenuation for different frequencies 
subplot(2, 1, 1)
plotshd( nameThorpshd )
plotbty( nameThorp )
caxisrev( [ 20, 80 ] )
a = colorbar;
a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';
% 10kHz

nameThorp10 = 'testThorpM10kHz';
nameThorpshd10 = sprintf('%s.shd', nameThorp10);
% bellhop( nameThorp10 )
% figure
subplot(2, 1, 2)
plotshd( nameThorpshd10 )
plotbty( nameThorp10 )
caxisrev( [ 20, 80 ] )
a = colorbar;
a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( nameThorpshd10 );
ztThorp       = Pos.r.z;
rtThorp       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tltThorp10 = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tltThorp10( isnan( tltThorp10 ) ) = 1e-6;   % remove NaNs
tltThorp10( isinf( tltThorp10 ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tltThorp10( tltThorp10 < 1e-37 ) = 1e-37;          % remove zeros
tltThorp10 = -20.0 * log10( tltThorp10 );          % so there's no error when we take the log
tltThorp10 = tltThorp10(:, removeR:end); % Remove first meters to compute statistic 
rtThorp = rtThorp(removeR:end);

% Diff with 130kHz model 
delta_tlt = tltThorp - tltThorp10;

figure
h = pcolor( rt, zt, delta_tlt );  ...
  shading flat
% colormap( jet(256) )
caxisrev( [ -5, 5 ] )
set( gca, 'YDir', 'Reverse' )
xlabel( 'Range(km)' );
ylabel( 'Depth (m)' );
title( { 'Delta tlt : 130kHz - 10kHz' ; [ 'z_{src} = ' num2str( Pos.s.z( isz ) ) ' m' ] } )
plotbty(nameThorp)

a = colorbar;
a.Label.String = 'Delta Transmission Loss (dB)';

%% Compare simulation results to geometric model
% Check in the upper layer to avoid problems with tl in the bottom 
% We could have slice tlt to remove values in the bottom but we don't want
% to get into complicated stuff here 
idMaxDepth = 100;

figure
str_legend = {};
tltUperlayer = tlt(1:idMaxDepth, :);
tltmedian = median(tltUperlayer); 
plot( rt, tltmedian);
str_legend{end+1} = 'TL - 130kHz';
hold on 

tltThorpUperlayer = tltThorp(1:idMaxDepth, :);
tltThorpmedian = median(tltThorpUperlayer); 
plot( rt, tltThorpmedian);
str_legend{end+1} = 'TL + Thorp - 130kHz';

hold on  

a = 20;
tltBasicWithoutAttenuation = a * log10 (rt); % Cylindrical spreading law 
plot( rt, tltBasicWithoutAttenuation);
str_legend{end+1} = [a 'log(r) - 130kHz'];

hold on

alpha = 38 ;  % dB/km http://resource.npl.co.uk/acoustics/techguides/seaabsorption/ for depth = 15, S = 35, T = 8 pH = 8 (Francois Garrison) 
alpha = alpha / 1000; % dB/m
tltBasicWithAttenuation = a * log10 (rt) + alpha * rt;
plot( rt, tltBasicWithAttenuation);
str_legend{end+1} = [a 'log(r) + \alpha * r - 130kHz'];

xlabel( 'Range (m)' );
ylabel( 'TL (dB)' )
legend(str_legend)


%% Compute TL without thorp attenuation for different frequencies 
subplot(4, 1, 1)
plotshd( nameWithoutThorpshd )
plotbty( nameWithoutThorp )
caxisrev( [ 20, 80 ] )
a = colorbar;
a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';

%%% 10kHz %%%
nameWithoutThorp10 = 'testWithoutThorp10kHz';
nameWithoutThorp10shd = sprintf('%s.shd', nameWithoutThorp10);
% bellhop( nameWithoutThorp10 )
% figure
subplot(4, 1, 2)
plotshd( nameWithoutThorp10shd )
plotbty( nameWithoutThorp10 )
caxisrev( [ 20, 80 ] )
a = colorbar;
a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( nameWithoutThorp10shd );
ztThorp       = Pos.r.z;
rtThorp       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tltWithoutThorp10 = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tltWithoutThorp10( isnan( tltWithoutThorp10 ) ) = 1e-6;   % remove NaNs
tltWithoutThorp10( isinf( tltWithoutThorp10 ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tltWithoutThorp10( tltWithoutThorp10 < 1e-37 ) = 1e-37;          % remove zeros
tltWithoutThorp10 = -20.0 * log10( tltWithoutThorp10 );          % so there's no error when we take the log
tltWithoutThorp10 = tltWithoutThorp10(:, removeR:end); % Remove first meters to compute statistic 
rtThorp = rtThorp(removeR:end);
%%%%%%%%%%%%%


%%% 500kHz %%%
nameWithoutThorp500 = 'testWithoutThorp500kHz';
nameWithoutThorp500shd = sprintf('%s.shd', nameWithoutThorp500);
bellhop( nameWithoutThorp500 )
% figure
subplot(4, 1, 3)
plotshd( nameWithoutThorp500shd )
plotbty( nameWithoutThorp500 )
caxisrev( [ 20, 80 ] )
a = colorbar;
a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( nameWithoutThorp500shd );
ztThorp       = Pos.r.z;
rtThorp       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tltWithoutThorp500 = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tltWithoutThorp500( isnan( tltWithoutThorp500 ) ) = 1e-6;   % remove NaNs
tltWithoutThorp500( isinf( tltWithoutThorp500 ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tltWithoutThorp500( tltWithoutThorp500 < 1e-37 ) = 1e-37;          % remove zeros
tltWithoutThorp500 = -20.0 * log10( tltWithoutThorp500 );          % so there's no error when we take the log
tltWithoutThorp500 = tltWithoutThorp500(:, removeR:end); % Remove first meters to compute statistic 
rtThorp = rtThorp(removeR:end);
%%%%%%%%%%%%

%%% 1kHz %%%
nameWithoutThorp1 = 'testWithoutThorp1kHz';
nameWithoutThorp1shd = sprintf('%s.shd', nameWithoutThorp1);
% bellhop( nameWithoutThorp1 )
% figure
subplot(4, 1, 4)
plotshd( nameWithoutThorp1shd )
plotbty( nameWithoutThorp1 )
caxisrev( [ 20, 80 ] )
a = colorbar;
a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( nameWithoutThorp1shd );
ztThorp       = Pos.r.z;
rtThorp       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tltWithoutThorp1 = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tltWithoutThorp1( isnan( tltWithoutThorp1 ) ) = 1e-6;   % remove NaNs
tltWithoutThorp1( isinf( tltWithoutThorp1 ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tltWithoutThorp1( tltWithoutThorp1 < 1e-37 ) = 1e-37;          % remove zeros
tltWithoutThorp1 = -20.0 * log10( tltWithoutThorp1 );          % so there's no error when we take the log
tltWithoutThorp1 = tltWithoutThorp1(:, removeR:end); % Remove first meters to compute statistic 
rtThorp = rtThorp(removeR:end);
%%%%%%%%%%%%


% Diff with 130kHz model 
delta_tlt = tlt - tltWithoutThorp1;

figure
h = pcolor( rt, zt, delta_tlt );  ...
  shading flat
% colormap( jet(256) )
caxisrev( [ -5, 5 ] )
set( gca, 'YDir', 'Reverse' )
xlabel( 'Range(km)' );
ylabel( 'Depth (m)' );
title( { 'Delta tlt : 130kHz - 10kHz' ; [ 'z_{src} = ' num2str( Pos.s.z( isz ) ) ' m' ] } )
plotbty(nameThorp)
a = colorbar;
a.Label.String = 'Delta Transmission Loss (dB)';

figure
str_legend = {};
tltUperlayer = tlt(1:idMaxDepth, :);
tltmedian = median(tltUperlayer); 
plot( rt, tltmedian);
str_legend{end+1} = 'TL - 130kHz';
hold on 

tltWithoutThorp10Uperlayer = tltWithoutThorp10(1:idMaxDepth, :);
tltWithoutThorp10median = median(tltWithoutThorp10Uperlayer); 
plot( rt, tltWithoutThorp10median);
str_legend{end+1} = 'TL - 10kHz';

hold on 
tltWithoutThorp500Uperlayer = tltWithoutThorp500(1:idMaxDepth, :);
tltWithoutThorp500median = median(tltWithoutThorp500Uperlayer); 
plot( rt, tltWithoutThorp500median);
str_legend{end+1} = 'TL - 500kHz';

hold on 
tltWithoutThorp1Uperlayer = tltWithoutThorp1(1:idMaxDepth, :);
tltWithoutThorp1median = median(tltWithoutThorp1Uperlayer); 
plot( rt, tltWithoutThorp1median);
str_legend{end+1} = 'TL - 1kHz';

legend(str_legend)

