cd ('C:\Users\33686\MATLAB\Projects\SeaMonitor\DRE_SeaMonitor\Tests\TestArrivals\')

zTarget = 2; % Receiver depth (m)
rTarget = 5000; % Receiver range (m)
name = 'testArrivals';
% bellhop( name )
ARRFIL = sprintf('%s.arr', name);
% irr = index of receiver range
% ird = index of receiver depth
% isd = index of source   depth
[ Arr, Pos ] = read_arrivals_asc( ARRFIL );

% irr =   
z_epsilon = 1e-2;
r_epsilon = 1e-2;
isd = 1;
irr = find(abs(Pos.r.r - rTarget) < r_epsilon); % Range index
ird = find(abs(Pos.r.z - zTarget) < z_epsilon); % Depth index

plotarr( ARRFIL, irr, ird, isd )
