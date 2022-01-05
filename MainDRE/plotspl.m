function plotspl(spl, zt, rt)
% Remove value for tlt = 1e-37
% Easy way: set threshold 

h = pcolor( rt, zt, spl );  ...
      shading flat
colormap( jet(256) )

icount = find(spl > -200); 
splmed = median( spl(icount) );    % median value
splstd = std( spl(icount) );       % standard deviation
splmax = splmed + 0.75 * splstd;       % max for colorbar
splmax = 10 * round( splmax / 10 );   % make sure the limits are round numbers
splmin = splmax - 50;                 % min for colorbar

xlab     = 'Range (m)';

caxisrev( [ splmin, splmax ] )
set( gca, 'YDir', 'Reverse' )
xlabel( xlab )
ylabel( 'Depth (m)' );
title( { deblank( PlotTitle ); [ 'Freq = ' num2str( freq ) ' Hz    z_{src} = ' num2str( Pos.s.z( isz ) ) ' m' ] } )

set( gca, 'ActivePositionProperty', 'Position', 'Units', 'centimeters' )
set( gcf, 'Units', 'centimeters' )
set( gcf, 'PaperPositionMode', 'auto');   % this is important; default is 6x8 inch page

if ( exist( 'm', 'var' ) )
  set( gca, 'Position', [ 2    2 + ( m - p ) * 9.0     14.0       7.0 ] )
  set( gcf, 'Position', [ 3                   15.0     19.0  m * 10.0 ] )
else
  set( gca, 'Position', [ 2    2                       14.0       7.0 ] )
  set( gcf, 'Units', 'centimeters' )
  set( gcf, 'Position', [ 3 15 19.0 10.0 ] )
end

drawnow

end