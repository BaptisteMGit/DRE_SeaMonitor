function writeEnvDRE(varargin)
%% writeEnvDRE() 
% Write an environmental file, function inspired by write_env from AT and
% adapteted to the purpose of DRE 
envfil = getVararginValue(varargin, 'envfil', 'TestEnv');
model = getVararginValue(varargin, 'model', 'BELLHOP');
TitleEnv = getVararginValue(varargin, 'TitleEnv', sprintf('Environment file for profile %s', envfil));
freq = getVararginValue(varargin, 'freq', 1000);
ssp = getVararginValue(varargin, 'SSP', []);% CHECK
bott = getVararginValue(varargin, 'BOTTOM', []);% CHECK
Pos = getVararginValue(varargin, 'Pos', '');% CHECK
Beam = getVararginValue(varargin, 'Beam', '');% CHECK
SspOption = getVararginValue(varargin, 'SspOption', 'SVW');% CHECK

cInt = getVararginValue(varargin, 'cInt', '');% CHECK
RMax = getVararginValue(varargin, 'RMax', 100);% CHECK

% For more clarity SSP and Bdry parameter are renamed with the
% following correspondance (names from write_env -> names used in writeEnvDRE):
%       .z -> .z : Depth name unchanged
%       .alphaR -> .c : Sound celerity
%       .betaR -> .ssc : Shear Sound Celerity 
%       .rho -> . rho : Density unchanged 
%       .alphaI -> .cwa : Compression Wave Absorption
%       .betaI -> .swa : Shear Wave Absorption

%% SSP 
SSP.NMedia = 1;
SSP.N = 15; % nmesh: unused parameter for BELLHOP (According to paper: General description of
% the BELLHOP ray tracing program)  -> Dummy parameter for compatibility
% with KRAKEN model 
SSP.sigma = 0.0; % sigmas: same thing
SSP.raw(1).z = ssp.z; % Depth in water column 
SSP.raw(1).c = ssp.c; % Sound celerity in water column 

SSP.raw(1).cwa = ssp.cwa; % Compression Wave Absorption in water column 

SSP.raw(1).ssc = repelem(0.00, length(ssp.z)); % Shear Sound Celerity in water column 
SSP.raw(1).rho = repelem(0.00, length(ssp.z)); % Density in water column 
SSP.raw(1).swa = repelem(0.00, length(ssp.z)); % Shear Wave Absorption in water column 

SSP.depth = [0, max(ssp.z)]; % Depth of the different water layers (for the moment just 1 layer (Nmedia =1))  

%% Boundary 
% Top 
Bdry.Top.Opt = SspOption;
% Bottom
Bdry.Bot.Opt = 'A*'; % 'A': acoustic half space, '*' : use of bathymetry file with format '.bty' 
Bdry.Bot.HS.c = bott.c; % Sound celerity in bottom half space 
Bdry.Bot.HS.ssc = bott.ssc; % Shear Sound Celerity in bottom half space 
Bdry.Bot.HS.rho = bott.rho; % Density in bottom half space 
Bdry.Bot.HS.cwa = bott.cwa; % Compression Wave Absorption in bottom half space 
Bdry.Bot.HS.swa = bott.swa; % Shear Wave Absorption in bottom half space 

if ( strcmp( envfil, 'ENVFIL' ) == 0 && ~strcmp( envfil( end-3: end ), '.env' ) )
  envfil = [ envfil '.env' ]; % append extension
end

% if ( size( varargin ) == 0 )
fid = fopen( envfil, 'wt' );   % create new envfil
% else
%     fid = fopen( envfil, 'at' );   % append to existing envfil
% end

if ( fid == -1 )
    disp( envfil )
    error( 'Unable to create environmental file', 'write_env' );
end

model = upper( model );   % convert to uppercase

fprintf( fid, '''%s'' ! Title \n', TitleEnv );
fprintf( fid, '%8.2f  \t \t \t ! Frequency (Hz) \n', freq );
fprintf( fid, '%5i    \t \t \t ! NMedia \n', SSP.NMedia );
fprintf( fid, '''%s'' \t \t \t ! Top Option \n', Bdry.Top.Opt );

if ( Bdry.Top.Opt( 2:2 ) == 'A' )
    fprintf( fid, '    %6.2f %6.2f %6.2f %6.2g %6.2f %6.2f /  \t ! upper halfspace \n', SSP.depth( 1 ), ...
        Bdry.Top.HS.c, Bdry.Top.HS.ssc, Bdry.Top.HS.rho, Bdry.Top.HS.cwa, Bdry.Top.HS.swa);
end

% SSP
% TODO: fix pour gérer la présence ou non des autres colonnes 
% for medium = 1 : SSP.NMedia
%     
%     fprintf( fid, '%5i %4.2f %6.2f \t ! N sigma depth \n', SSP.N( medium ), SSP.sigma( medium ), SSP.depth( medium+1 ) );
%     for ii = 1 : length( SSP.raw( medium ).z )
%         fprintf( fid, '\t %6.2f %6.2f %6.2f %6.2g %10.6f %6.2f / \t ! Depth  Celerity  ShearSoundCelerity Rho CompressionWaveAbso ShearWaveAbso\n', ...
%             [ SSP.raw( medium ).z( ii ) ...
%               SSP.raw( medium ).c( ii ) SSP.raw( medium ).ssc( ii ) SSP.raw( medium ).rho( ii ) ...
%               SSP.raw( medium ).cwa( ii ) SSP.raw( medium ).swa( ii ) ] );
%     end
% end

for medium = 1 : SSP.NMedia
    
    fprintf( fid, '%5i %4.2f %6.2f \t ! N sigma depth \n', SSP.N( medium ), SSP.sigma( medium ), SSP.depth( medium+1 ) );
    for ii = 1 : length( SSP.raw( medium ).z )
        fprintf( fid, '\t %6.2f %6.2f %6.2f %6.2f %6.6f %6.2f / \t ! Depth  Celerity  ShearSoundCelerity Rho CompressionWaveAbso ShearWaveAbso\n', ...
            [ SSP.raw( medium ).z( ii ) SSP.raw( medium ).c( ii ) SSP.raw( medium ).ssc( ii ) SSP.raw( medium ).rho( ii ) SSP.raw( medium ).cwa( ii ) SSP.raw( medium ).swa( ii ) ] );
    end
end

% lower halfspace
fprintf( fid, '''%s'' %6.2f  \t \t ! Bottom Option, sigma \n', Bdry.Bot.Opt, 0.0 ); % SSP.sigma( 2 ) );

if ( Bdry.Bot.Opt( 1:1 ) == 'A' )
    fprintf( fid, '    %6.2f %6.2f %6.2f %6.2f %6.2f %6.2f /  \t ! lower halfspace \n', SSP.depth( SSP.NMedia+1 ), ...
        Bdry.Bot.HS.c, Bdry.Bot.HS.ssc, Bdry.Bot.HS.rho, Bdry.Bot.HS.cwa, Bdry.Bot.HS.swa );
end

% source depths
fprintf( fid, '%5i \t \t \t \t ! NSz \n', length( Pos.s.z ) );
if ( length( Pos.s.z ) >= 2 && equally_spaced( Pos.s.z ) )
    fprintf( fid, '    %6f %6f', Pos.s.z( 1 ), Pos.s.z( end ) );
else
    fprintf( fid, '    %6f  ', Pos.s.z );
end
fprintf( fid, '/ \t ! Sz(1)  ... (m) \n' );

% receiver depths
fprintf( fid, '%5i \t \t \t \t ! NRz \n', length( Pos.r.z ) );

if ( length( Pos.r.z ) >= 2 && equally_spaced( Pos.r.z ) )
    fprintf( fid, '    %6f %6f ', Pos.r.z( 1 ), Pos.r.z( end ) );
else
    fprintf( fid, '    %6f  ', Pos.r.z );
end
fprintf( fid, '/ \t ! Rz(1)  ... (m) \n' );

% receiver ranges
fprintf( fid, '%5i \t \t \t \t ! NRr \n', length( Pos.r.range ) );
if ( length( Pos.r.range ) >= 2 && equally_spaced( Pos.r.range ) )
    fprintf( fid, '    %6f %6f', Pos.r.range( 1 ), Pos.r.range( end ) );
else
    fprintf( fid, '    %6f ', Pos.r.range );
end
fprintf( fid, '/ \t ! Rr(1)  ... (km) \n' );
write_bell( fid, Beam );

fclose( fid );
end