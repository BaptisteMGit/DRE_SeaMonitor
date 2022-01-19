cd ('C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_SeaMonitor\Tests\TestAttenuation\TestAttManualy\')

removeR = 20;
cwa = 1;
cwa = cwa / 1000;

%%% Ref test, f=130kHz, cwa = 0;
name = 'testref';
nameshd = sprintf('%s.shd', name);
% bellhop( name )
% figure
subplot(2, 1, 1)
plotshd( nameshd )
% plotbty( name )
caxisrev( [ 40, 90 ] )
a = colorbar;
% a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( nameshd );
ztThorp       = Pos.r.z;
rtref       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tltref = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tltref( isnan( tltref ) ) = 1e-6;   % remove NaNs
tltref( isinf( tltref ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tltref( tltref < 1e-37 ) = 1e-37;          % remove zeros
tltref = -20.0 * log10( tltref );          % so there's no error when we take the log
tltref = tltref(:, removeR:end); % Remove first meters to compute statistic 
rtref = rtref(removeR:end);
ax = gca;
title({ax.Title.String{1}, [ax.Title.String{2}, '  cwa = ', num2str(cwa), ' dB/m'] })

%%% test 1, f=130kHz, cwa = 38dB/km;
name1 = 'test1';
name1shd = sprintf('%s.shd', name1);
% bellhop( name1 )
% figure
subplot(2, 1, 2)
plotshd( name1shd )
% plotbty( name1 )
caxisrev( [ 40, 90 ] )
a = colorbar;
% a.Limits = [20, 80];
a.Label.String = 'Transmission Loss (dB)';
ax = gca;
title({ax.Title.String{1}, [ax.Title.String{2}, '  cwa = ', num2str(cwa), ' dB/m'] })

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( name1shd );
zt1       = Pos.r.z;
rt1       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tlt1 = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tlt1( isnan( tlt1 ) ) = 1e-6;   % remove NaNs
tlt1( isinf( tlt1 ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tlt1( tlt1 < 1e-37 ) = 1e-37;          % remove zeros
tlt1 = -20.0 * log10( tlt1 );          % so there's no error when we take the log
tlt1 = tlt1(:, removeR:end); % Remove first meters to compute statistic 
rt1 = rt1(removeR:end);

% TL vs range 
idMaxDepth = numel(zt1);
figure
str_legend = {};
tltrefUperlayer = tltref(1:idMaxDepth, :);
tltrefmedian = median(tltrefUperlayer); 
scatter( rtref, tltrefmedian, 5, 'black', 'filled');
str_legend{end+1} = 'cwa = 0.0 dB/m';

hold on 

tlt1Uperlayer = tlt1(1:idMaxDepth, :);
tlt1median = median(tlt1Uperlayer); 
scatter( rt1, tlt1median, 5, 'blue', 'filled');
str_legend{end+1} = ['cwa = ' num2str(cwa) ' dB/m'];

hold on 
a = 10;

tltBasicWithAttenuation = a * log10 (rtref) + cwa * rtref;
plot( rtref, tltBasicWithAttenuation, 'LineWidth', 2, 'Color', 'm', 'LineStyle','--');
str_legend{end+1} = [num2str(a) 'log(r) + ' num2str(cwa) ' * r'];

hold on 
a = 20;
tltBasicWithAttenuation = a * log10 (rtref) + cwa * rtref;
plot( rtref, tltBasicWithAttenuation, 'LineWidth', 2, 'Color', 'g', 'LineStyle','-.');
str_legend{end+1} = [num2str(a) 'log_{10}(r) + ' num2str(cwa) ' * r'];

hold on 
a = 15;
tltBasicWithAttenuation = a * log10 (rtref) + cwa * rtref;
plot( rtref, tltBasicWithAttenuation, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-.');
str_legend{end+1} = [num2str(a) 'log_{10}(r) + ' num2str(cwa) ' * r'];

xlabel( 'Range (m)' );
ylabel( 'TL (dB)' )
legend(str_legend, Location="best")
title({'Median TL for different models', 'f=10kHz'})


