function [tl, zt, rt] = computeTL(filename)

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( filename );
zt       = Pos.r.z;
rt       = Pos.r.r;

itheta = 1;   % select the index of the receiver bearing
isz    = 1;   % select the index of the source depth
pressure = squeeze( pressure( itheta, isz, :, : ) );

tl = double( abs( pressure ) );   % pcolor needs 'double' because field.m produces a single precision
tl( isnan( tl ) ) = 1e-6;   % remove NaNs
tl( isinf( tl ) ) = 1e-6;   % remove infinities

% icount = find( tlt > 1e-37 );        % for stats, only these values count
tl( tl < 1e-37 ) = 1e-37;          % remove zeros
tl = -20.0 * log10( tl );

end

