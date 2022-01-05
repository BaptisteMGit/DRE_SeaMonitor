function [spl, zt, rt] = computeSpl(varargin)

filename = getVararginValue(varargin, 'filename', '');
sl = getVararginValue(varargin, 'SL', 100); % Source level in decibel (dB) 

[ ~, ~, ~, ~, ~, Pos, pressure ] = read_shd( filename );
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

spl = sl - tlt;

end