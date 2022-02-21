function [DLinv, DLmax] = deriveNarrowbandDLinv(ka)

% First-order Bessel function of the first kind 
J1 = @(x) besselj(1, x);

knots = findDLKnots(ka);
offset = 0.01   ;
knots(1) = knots(1) - offset; % Reducing main lobe 

dth = 0.01;
thetadeg = 0:dth:90;
theta = thetadeg * pi/180;

idxDef = (thetadeg <=90) & (thetadeg>=-90);
idxNotDef = ~idxDef;
DLnb = zeros([numel(theta), 0]);

% Narrow band directional loss 
DLnb(idxDef) = ( 2*J1(ka*sin(theta(idxDef))) ./ (ka*sin(theta(idxDef))) ).^2;
DLnbmax = ( 2*J1(ka*sin(90 * pi/180)) / (ka*sin(90 * pi/180)) )^2;
DLnb(idxNotDef) = DLnbmax;
DLnb = -10*log10(DLnb);

%%% Main lobe %%%
theta_firstlobe = knots(1);
idxMainLobe = (theta >= -theta_firstlobe) & (theta <= theta_firstlobe);

% Narrow band directional loss for main lobe
DLnb_mainlobe = DLnb(idxMainLobe);
theta_mainlobe = theta(idxMainLobe);

%%% Remaining angles %%%
if numel(knots) >= 2 % Fix to avoid pb if there is only 1 knot 
    theta_knot2 = knots(2) + offset;
    interpMethod = 'pchip';
else 
    theta_knot2 = knots(1) + 4*offset;
    interpMethod = 'linear'; 
end
idxPart2 = (theta >= theta_knot2) | (theta <= -theta_knot2);

% Narrow band directional loss for the angles out of main lobe 
thetaPart2 = theta(idxPart2);
DLnbPart2 = ones(size(thetaPart2)) * DLnb(end); % Constant with value DLnb(theta=90°)
% We add a small slope to ensure the final distribution is injective on 
% the interval [0, 90]° so that we can inverse it 
eps = 0.1;
a = +eps/(max(thetaPart2)-theta_knot2);
b = -eps * (1+theta_knot2/((max(thetaPart2)-theta_knot2)));
yoffset = a*abs(thetaPart2) + b; 
DLnPart2WithSplope = DLnbPart2 + yoffset; 
DLnbPart2 = DLnPart2WithSplope;

% DLnbPart2 = DLnbPart2 + 30; set an offset to increase attenuation ? 

%%% Interpolate main lobe and part 2 %%%
% Interpolation to consider main lobe as well as side lobes effect and 
% backward energy for a directionnal source modelled by a piston. The 
% solution adopted here is a compromise between the original piston model
% which is not an injective function on [0, 90]° and thus can't be used to
    % model the detection function and a model with only the main lobe which
    % seems to lead to largely underestimate detection probability according to
% the paper. 
% Based on results from paper High resolution three-dimensional beam radiation pattern of harbour porpoise clicks
% with implications for passive acoustic monitoring
% Jamie D. J. Macaulay, Chloe E. Malinka, Douglas Gillespie, and Peter T. Madse

dth = 0.01;
thetadeg = 0:dth:90;
theta = thetadeg * pi/180;

thetaAll = [theta_mainlobe thetaPart2 ]; % Concatenate main and last lobe 
DLnbAll = [DLnb_mainlobe DLnbPart2];

DLnb_interp = interp1(thetaAll, DLnbAll, theta, interpMethod); 
 
% Inverse function of off-axis attenuation
DLmax = max(DLnb_interp);
% It is a piecewise-defined function 
DLinv = @(DL)...
    0 * (DL <= 0) + ... % DL = 0
    interp1(theta, DLnb_interp, DL, 'linear', 0) .* (0 < DL & DL < DLmax) + ... % 0 < DL < DLmax
    pi * (DL >= DLmax); % DL >= DLmax
end

