cd ('C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_SeaMonitor\Tests\TestEquivalence')

zTarget = 2;
deltaZ = 0.5;
zHydro = 10;
removeR = 5; % Nb of range points to be removed 

flagPlot = true;
flagCompute = false;
%% Forward profile 
name = 'testEquivalence';
if flagCompute
    bellhop( name )
end
if flagPlot
    figure
    plotshd( 'testEquivalence.shd')
    plotbty( name )
    a = colorbar;
    a.Label.String = 'Transmission Loss (dB)';
    hold on 
    % Hydrophone 
    scatter(0, zHydro, 50, 'filled', 'k')
    hold on 
    % Acoustic source 
    scatter(5000, zTarget, 50, 'filled', 'r')
    % get labels for x-axis
    

end

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( 'testEquivalence.shd' );
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

%% Backward profile 
name = 'testEquivalenceReverse';
if flagCompute
    bellhop( name )
end

if flagPlot
    figure
    plotshd( 'testEquivalenceReverse.shd')
    plotbty( name )
    a = colorbar;
    a.Label.String = 'Transmission Loss (dB)';
    hold on 
    % Hydrophone 
    scatter(5000, zHydro, 50, 'filled', 'k')
    hold on 
    % Acoustic source 
    scatter(0, zTarget, 50, 'filled', 'r')
    set(gca, 'XDir', 'Reverse')
    rLabel = flipud(get(gca, 'XTickLabel'));
    set(gca, 'XTickLabel', rLabel)

end

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( 'testEquivalenceReverse.shd' );
ztReverse       = Pos.r.z;
rtReverse       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tltReverse = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tltReverse( isnan( tltReverse ) ) = 1e-6;   % remove NaNs
tltReverse( isinf( tltReverse ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tltReverse( tltReverse < 1e-37 ) = 1e-37;          % remove zeros
tltReverse = -20.0 * log10( tltReverse );          % so there's no error when we take the log
tltReverse = tltReverse(:, removeR:end); % Remove first meters to compute statistic 
rtReverse = rtReverse(removeR:end);

% xticklabels(cellstr(num2str(fliplr(rtReverse))))

%% Compare result 
% We want to make sure the level computed for the red point with the
% forward profile is equivalent to the level for the black point with the
% reverse profile
% Red point = mammal 
% Black point = hydrophone 

%%% TL around hydrophone / mammal %%%
% forward profile
izToKeep = (zt < zTarget + deltaZ) & (zt > zTarget - deltaZ);
tltAtMammalLoc = tlt(izToKeep, end); % z profile 
% backward profile 
izToKeepReverse = (ztReverse < zHydro + deltaZ) & (ztReverse > zHydro - deltaZ);
tltAtHydroLoc = tltReverse(izToKeepReverse, end); 

fprintf('Comparison of the 2 simulations :\n')
fprintf('Mean:\n \tForward = %2.1f \n\tBackward = %2.1f \n\tRelative error = %4.3f %%\n\n', mean(tltAtMammalLoc), mean(tltAtHydroLoc), abs(mean(tltAtMammalLoc) - mean(tltAtHydroLoc)) / mean(tltAtHydroLoc) * 100)
fprintf('Median:\n \tForward = %2.1f \n\tBackward = %2.1f \n\tRelative error = %4.3f %%\n\n', median(tltAtMammalLoc), median(tltAtHydroLoc), abs(median(tltAtMammalLoc) - median(tltAtHydroLoc)) / median(tltAtHydroLoc) * 100)

% Plot z profiles 
% figure
% plot(tltAtMammalLoc, zt(izToKeep))
% hold on
% plot(tltAtHydroLoc, ztReverse(izToKeepReverse))
% 
% set( gca, 'YDir', 'Reverse' )
% legend({'Forward', 'Backward'})

%%% median TL around hydrophone / mammal as a function of r %%%
% forward profile
izToKeep = (zt < zTarget + deltaZ) & (zt > zTarget - deltaZ);
tltAtMammalLoc = tlt(izToKeep, :); % z profile 
tltAtMammalLoc = median(tltAtMammalLoc);
% backward profile 
izToKeepReverse = (ztReverse < zHydro + deltaZ) & (ztReverse > zHydro - deltaZ);
tltAtHydroLoc = tltReverse(izToKeepReverse, :); 
tltAtHydroLoc = median(tltAtHydroLoc);


figure 
plot(rt, tltAtMammalLoc)
hold on 
plot(rtReverse, tltAtHydroLoc)
legend({'Forward', 'Backward'})
xlabel('Range (m)')
ylabel('median TL (dB)')
ylim([0, 100])
title('Median TL for both profiles')

figure
delta = tltAtMammalLoc - tltAtHydroLoc;
plot(rt, delta)
medDelta = median(delta);
stdDelta = std(delta);
yline(medDelta)
yline(medDelta + stdDelta, '--', 'Color', 'r')
yline(medDelta - stdDelta, '--', 'Color', 'r')

relError = delta/tltAtMammalLoc * 100;
fprintf('Comparison of the 2 simulations :\n')
fprintf('Mean error: %4.3f %%\n', mean(delta))
fprintf('Median error: %4.3f %%\n', medDelta)
fprintf('Standard deviation error: %4.3f %%\n', stdDelta)
fprintf('Mean relative error: %4.3f %%\n', median(relError))


legend({'\Delta median TL', '\mu', '\mu +/- \sigma'})
xlabel('Range (m)')
ylabel('\Delta median TL (dB)')
% ylim([medDelta - 3*stdDelta, medDelta + 3*stdDelta])
ylim([-10, 10])
title('Absolute error statistics (|backward - forward|)')
