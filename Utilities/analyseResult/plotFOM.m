function plotFOM(varargin)

filename = getVararginValue(varargin, 'filename', '');
sl = getVararginValue(varargin, 'SL', 100); % Source level in decibel (dB) 
[spl, zt, rt] = computeSpl(varargin{:});

[ PlotTitle, ~, freqVec, ~, ~, Pos, ~ ] = read_shd( filename );
freq = freqVec( 1 );

h = pcolor( rt, zt, spl );  ...
      shading flat
colormap( jet(256) )

icount = find(spl > -200); % Remove value conresponding to tlt = 1e-37 -> Easy way: set threshold 
splmed = median( spl(icount) );    % median value
splstd = std( spl(icount) );       % standard deviation
% splmax = splmed + 0.75 * splstd;       % max for colorbar
splmax = sl-20;
splmax = 10 * round( splmax / 10 );   % make sure the limits are round numbers
splmin = splmax - 50;                 % min for colorbar

xlab     = 'Range (m)';

caxis( [ splmin, splmax ] )
a = colorbar;
a.Label.String = 'Sound Pressure Level (dB)';
set( gca, 'YDir', 'Reverse' )
xlabel( xlab )
ylabel( 'Depth (m)' );
title( { deblank( PlotTitle ); [ 'Freq = ' num2str( freq ) ' Hz    z_{src} = ' num2str( Pos.s.z( 1 ) ) ' m' ] } )    
drawnow

end