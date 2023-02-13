% Script to show off-axis attenuation approximation used to derive
% detection function. 
% Ref: Passive Acoustic Monitoring of Cetaceans by Walter M. X. Zimmer 
% Page: 96 - 100

clear 
close all 
% Constants 
DI = 23.5; % Directivity index of Porpoise (PAMofC (p89)) [dB]
ka = 10^(DI/20);

% Broadband
% ka = 17.8; % 
C1 = 47; % dB
C2 = 0.218*ka;

%% X, Y plot to show loss
% Directionnal loss of the source as a function of off-axis angle for
% broadband signal (click). 
dth = 0.1;
thetadeg =-180:dth:180;
theta = thetadeg * pi/180;

cx = C2*sin(theta);
DLbb = C1 * (cx).^2 ./ (1 + abs(cx) + (cx).^2);

figure 
plot(thetadeg, DLbb, 'LineWidth', 1)
xlabel('Off-axis angle [°]')
ylabel('Off-axis attenuation [dB]')
title('DLbb', sprintf('DI = %.0f dB', DI))
set(gca, 'YDir', 'reverse')
xlim([-90, 90])

idxAlpha3dB = find((DLbb<=3), 1, 'first');
alpha3dB = thetadeg(idxAlpha3dB);
xline(alpha3dB, 'r', 'LineStyle', '--', 'LineWidth', 1)
xline(-alpha3dB, 'r', 'LineStyle', '--', 'LineWidth', 1, ...
    'Label', sprintf('-3dB Beamwidth = %.1f°', -alpha3dB), 'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment','right', 'LabelOrientation', 'horizontal')


%% Polar plot to show off-Axis attenuation
dth = 0.1;
thetadeg = -180:dth:180;
theta = thetadeg * pi/180;

idxDef = (thetadeg <=90) & (thetadeg>=-90);
idxNotDef = ~idxDef;
cx = C2*sin(theta(idxDef));
DLbb = zeros([numel(theta), 0]);
DLbb(idxDef) = C1 * (cx).^2 ./ (1 + abs(cx) + (cx).^2);
DLmax = C1 * C2^2 / (1 + C2 + C2^2);
DLbb(idxNotDef) = DLmax;

% Apparent source level
SL0 = 100;
ASLbb = SL0 - DLbb;
figure 
lgd = {};
polarplot(theta, ASLbb, 'LineWidth', 1)
lgd{end+1} = sprintf('Apparent source level with SL0 = %d dB', SL0);
hold on
polarplot([0; 0]*pi/180, [0; SL0],'LineWidth', 2)  
lgd{end +1} = 'Acoustic axis';
hold on 
polarplot([45; 45]*pi/180, [0; SL0], 'LineWidth', 2, 'LineStyle', '--')  
lgd{end +1} = 'Off-axis';

legend(lgd, 'Location', 'southoutside')

%% Narrow band off-axis attenuation
% dth = 0.01;
% thetadeg = -180:dth:180;
% theta = thetadeg * pi/180;

idxDef = (thetadeg <=90) & (thetadeg>=-90);
idxNotDef = ~idxDef;
DLnb = zeros([numel(theta), 0]);

% First-order Bessel function of the first kind 
J1 = @(x) besselj(1, x);

% Narrow band directional loss 
DLnb(idxDef) = ( 2*J1(ka*sin(theta(idxDef))) ./ (ka*sin(theta(idxDef))) ).^2;
DLnbmax = ( 2*J1(ka*sin(90 * pi/180)) / (ka*sin(90 * pi/180)) )^2;
DLnb(idxNotDef) = DLnbmax;
DLnb = -10*log10(DLnb);

% Circular piston model
figure
plot(thetadeg, DLnb, 'LineWidth', 1)
xlabel('Off-axis angle [°]')
ylabel('Off-axis attenuation [dB]')
title('Circular piston model', sprintf('DI = %.0f dB', DI))
set(gca, 'YDir', 'reverse')
xlim([-90, 90])


% Circular piston model + broadband approx
figure
plot(thetadeg, DLnb, 'LineWidth', 1.5)
hold on 
plot(thetadeg, DLbb, 'LineWidth', 1.5)
legend({'Circular piston', 'Broadband approximation'})
xlabel('Off-axis angle [°]')
ylabel('Off-axis attenuation [dB]')
title('Circular piston model', sprintf('DI = %.1f dB', DI))
set(gca, 'YDir', 'reverse')
xlim([-90, 90])

%% Find knots 
% Find zeros of J1 function 
lb = 0;             % Set a lower bound for the function.
ub = 1.1*pi/2;          % Set an upper bound for the function.
x = NaN*ones(100, 1);             % Initializes x.
starting_points=linspace(lb, ub, 100);
for i=1:100
        % Look for the zeros in the function's current window.
        x(i) = fzero(@(x) J1(ka*sin(x)), starting_points(i));
end
x_unique = x(diff(x)>1e-12);
x_unique = x_unique(2:end); % Get rid of the first 0 (corresponding to on-axis)

figure
dth = 0.01;
thetadeg = 0:dth:90;
theta = thetadeg * pi/180;
plot(thetadeg, J1(ka*sin(theta)), 'LineWidth', 1.5)
yline(0, 'k')
x_unique_deg = x_unique*180/pi;
for i = 1:numel(x_unique)
    xline(x_unique_deg(i), '--k', 'LineWidth', 1, 'Label', sprintf('%.1f°', x_unique_deg(i)))
end

legend({'J1(ka*sin(\theta))', '', '','', 'Zeros of the function'}, 'Location', 'southeast')
xlabel('\theta [°]')
ylabel('J1(ka*sin(\theta))')


%% Check that zeros correspond to knots with polar plot 
%%% Applying small offsets to theta_knots for future interpolation %%%
offset = 0.01   ;
% x_unique(1) = x_unique(1) - offset; % Reducing main lobe 

dth = 0.01;
thetadeg = -90:dth:90;
theta = thetadeg * pi/180;

idxDef = (thetadeg <=90) & (thetadeg>=-90);
idxNotDef = ~idxDef;
DLnb = zeros([numel(theta), 0]);

% Narrow band directional loss 
DLnb(idxDef) = ( 2*J1(ka*sin(theta(idxDef))) ./ (ka*sin(theta(idxDef))) ).^2;
DLnbmax = ( 2*J1(ka*sin(90 * pi/180)) / (ka*sin(90 * pi/180)) )^2;
DLnb(idxNotDef) = DLnbmax;
DLnb = -10*log10(DLnb);

figure
lgd = {};
% Apparent source level
SL0 = 100;
ASLnb = SL0 - DLnb; 
polarplot(theta, ASLnb)
lgd{end+1} = 'DL_{nb}';

% Plotting knots location
hold on 
for i=1:numel(x_unique)
    polarplot([x_unique(i); x_unique(i)], [0; SL0], 'k', 'LineWidth', 1, 'LineStyle', '--')  
    polarplot([-x_unique(i); -x_unique(i)], [0; SL0], 'k', 'LineWidth', 1, 'LineStyle', '--')  
    lgd{end +1} = sprintf('lobe_{%d} = %.1f°', i, x_unique(i)*180/pi);
    lgd{end +1} = '';
end

%%% Main lobe %%%
idxtheta_main = theta >= -x_unique(1) & theta <= x_unique(1);
% dl_main = DLnb(idxtheta_main);
% theta_firstlobe = abs(theta( (DLnb < DLnb(end) - 1) & idxtheta_main ));
idxMainLobe = (DLnb < DLnb(end) - 1) & idxtheta_main;
theta_firstlobe = theta(find(idxMainLobe, 1, 'last'));
% idxMainLobe = (theta >= -theta_firstlobe) & (theta <= theta_firstlobe);

% Narrow band directional loss for main lobe
DLnb_mainlobe = DLnb(idxMainLobe);
theta_mainlobe = theta(idxMainLobe);

ASLnb_mainlobe = SL0 - DLnb_mainlobe;
hold on
polarplot(theta_mainlobe, ASLnb_mainlobe, '--m', 'LineWidth', 2)
lgd{end +1} = 'DL_{nb}_{mainlobe}';

%%% Remaining angles %%%
if numel(x_unique) >= 2 % Fix to avoid pb if there is only 1 knot 
    theta_knot2 = x_unique(2) + offset;
    interpMethod = 'pchip';
else 
    theta_knot2 = x_unique(1) + 4*offset;
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
% DLnPart2WithSplope = 40 + yoffset; 

DLnbPart2 = DLnPart2WithSplope;

% DLnbPart2 = DLnbPart2 + 30; set an offset to increase attenuation ? 

ASLnbPart2 = SL0 - DLnbPart2;
hold on
polarplot(thetaPart2, ASLnbPart2, '--', 'LineWidth', 2)
lgd{end +1} = 'DL_{nb}_{sidelobes}';

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
thetadeg = -90:dth:90;
theta = thetadeg * pi/180;

thetaAll = [theta_mainlobe thetaPart2 ]; % Concatenate main and last lobe 
DLnbAll = [DLnb_mainlobe DLnbPart2];

DLnb_interp = interp1(thetaAll, DLnbAll, theta, interpMethod); 
 
%%% Extent DLnb, DLnb_interp to the all range -180, 180° 
angleInf = -180:dth:-90;
angleSup = 90:dth:180;
thetadeg = [angleInf thetadeg angleSup]; 
theta = thetadeg * pi/180;
% [C,ia,ic] = unique(theta);
% DLnb
val = DLnb(end);
DLnb = [ones(size(angleInf))*val DLnb ones(size(angleSup))*val];
% Extent DLnb_interp
val = DLnb_interp(end);
DLnb_interp = [ones(size(angleInf))*val DLnb_interp ones(size(angleSup))*val];


ASLnb_interp = SL0 - DLnb_interp;
hold on
polarplot(theta, ASLnb_interp, '--g', 'LineWidth', 2)
lgd{end +1} = 'DL_{nb}_{interp}';

legend(lgd)


% Regular plot 
figure
% plot(theta*180/pi, 10.^(DLnb_interp/20), 'LineWidth', 1)
plot(theta*180/pi, DLnb_interp, 'LineWidth', 1)

theta_DLnb = theta; 
theta_DLnb_deg = theta_DLnb*180/pi;

xlabel('Off-axis angle [°]')
ylabel('Off-axis attenuation [dB]')
title('Directionnal loss approximation for narrowband signal')
set(gca, 'YDir', 'reverse')

%% Plot for userguide 
figure 
lgd = {};
% Interp 
polarplot(theta, ASLnb_interp, 'LineWidth', 2)
lgd{end + 1} = 'ASL_{interp}';
hold on
% Slope
polarplot(thetaPart2, ASLnbPart2, 'LineWidth', 2)
lgd{end + 1} = 'ASL_{nb}';
hold on
% Main lobe 
polarplot(theta_mainlobe, ASLnb_mainlobe, 'LineWidth', 2) 
lgd{end + 1} = 'ASL_{mainlobe}';
hold on 

title({'ASL - Narrowband model', ...
    sprintf('DI = %ddB, SL_0 = %ddB', DI, SL0)})
legend(lgd, 'Location', 'southoutside')


figure 
lgd = {};
% Interp 
plot(theta*180/pi, DLnb_interp, 'LineWidth', 2)
lgd{end + 1} = 'ASL_{interp}';
hold on
% Slope
DLslope = DLnbPart2;
idxNotSlope = (thetaPart2 > -theta_knot2) & (thetaPart2 < theta_knot2);
DLslope(idxNotSlope) = nan;
plot(thetaPart2(thetaPart2 > -theta_knot2)*180/pi, DLslope(thetaPart2 > -theta_knot2), 'r', 'LineWidth', 2)
plot(thetaPart2(thetaPart2 < theta_knot2)*180/pi, DLslope(thetaPart2 < theta_knot2), 'r', 'LineWidth', 2)

lgd{end + 1} = 'ASL_{slope}';
lgd{end + 1} = '';
hold on
% Main lobe 
plot(theta_mainlobe*180/pi, DLnb_mainlobe, 'LineWidth', 2) 
lgd{end + 1} = 'ASL_{mainlobe}';
hold on 

set(gca, 'YDir', 'reverse')
xlim([-90, 90])

xlabel('Off-axis angle [°]')
ylabel('Off-axis attenuation [dB]')
title({'DL narrowband model', ...
    sprintf('DI = %.1fdB, SL_0 = %.0fdB', DI, SL0)})
legend(lgd)


% Circular piston model + narrow approx
figure
plot(theta*180/pi, DLnb, 'LineWidth', 1.5)
hold on 
plot(theta*180/pi, DLnb_interp, 'LineWidth', 1.5)

legend({'Circular piston', 'Narrow-band approximation'})
xlabel('Off-axis angle [°]')
ylabel('Off-axis attenuation [dB]')
title('Circular piston model', sprintf('DI = %.1f dB', DI))
set(gca, 'YDir', 'reverse')
xlim([-90, 90])



%% Compare models 
dth = 0.1;
thetadeg = -180:dth:180;
theta = thetadeg * pi/180;

figure 
lgd = {};
plot(theta_DLnb_deg, DLnb, 'k', 'LineWidth', 1)
lgd{end + 1} = 'DL';
hold on 
plot(thetadeg, DLbb, 'b', 'LineWidth', 1)
lgd{end + 1} = 'DL_{bb}';
hold on 
plot(theta_DLnb_deg, DLnb_interp, 'r', 'LineWidth', 1)
lgd{end + 1} = 'DL_{nb}';

% Compare -3dB beamwidth
% Broadband
idxAlpha3dB = find((DLbb<=3), 1, 'first');
alpha3dB = thetadeg(idxAlpha3dB);
xline(-alpha3dB, 'b', 'LineStyle', '--', 'LineWidth', 1)
xline(alpha3dB, 'b', 'LineStyle', '--', 'LineWidth', 1, ...
    'Label', sprintf('Broadband beamwidth = %.1f°', 2*abs(alpha3dB)), 'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment','right', 'LabelOrientation', 'aligned')
% Narrowband unmodified 
idxAlpha3dB = find((DLnb<3), 1, 'first');
alpha3dB = theta_DLnb_deg(idxAlpha3dB);
xline(alpha3dB, 'k', 'LineStyle', '--', 'LineWidth', 1)
xline(-alpha3dB, 'k', 'LineStyle', '--', 'LineWidth', 1, ...
    'Label', sprintf('Circular piston model beamwidth = %.1f°', 2*abs(alpha3dB)), 'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment','right', 'LabelOrientation', 'aligned')
% Narrowband modified 
idxAlpha3dB = find((DLnb_interp<3), 1, 'first');
alpha3dB = theta_DLnb_deg(idxAlpha3dB);
xline(alpha3dB, 'r', 'LineStyle', '--', 'LineWidth', 1, ...
    'Label', sprintf('Narrowband beamwidth = %.1f°', 2*abs(alpha3dB)), 'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment','left', 'LabelOrientation', 'aligned')
xline(-alpha3dB, 'r', 'LineStyle', '--', 'LineWidth', 1)

yline(3,  'k', 'LineStyle', '--', 'LineWidth', 1, ...
    'Label', '-3dB')
ylim([0 50])
xlim([-90, 90])
xlabel('Off-axis angle [°]')
ylabel('Off-axis attenuation [dB]')
title({'Directionnal loss approximation', ... 
     sprintf('DI = %.1fdB', DI)})
set(gca, 'YDir', 'reverse')

legend(lgd, 'Location', 'northwest')

% Polar plot 
% Apparent source level
SL0 = 100;
ASLnb = SL0 - DLnb;
figure 
lgd = {};
polarplot(theta_DLnb, ASLnb, 'LineWidth', 1)
lgd{end+1} = sprintf('ASL - narrowband piston model');
hold on
polarplot(theta_DLnb, ASLnb_interp, 'LineWidth', 1)
lgd{end+1} = sprintf('ASL - narrowband modified piston model');
hold on 
polarplot(theta, ASLbb, 'LineWidth', 1)
lgd{end+1} = sprintf('ASL - broadband');

title({'Apparent source level for a narrow band signal', ...
    sprintf('DI = %.1fdB, SL_0 = %.1fdB', DI, SL0)})
legend(lgd, 'Location', 'southoutside')


% polarplot(theta_mainlobe, DLnb_mainlobe)
% thetadeg_modified = thetadeg(~isnan(DLnb));
% DLnb_modified(idInf) = 100;
% DL = 1:0.1:100;
% thetaInv = interp1(DLnb_modified, thetadeg_modified, DL);

%%  Beam profile detectability 
% Beam profile detectability for an echolocation click with a SL of 191 dB re 1 lPa pp. Each point on the plot is coloured by the
% expected RL if a porpoise were facing in the y direction and located at (0,0)
% The idea is to repoduce the results given in the paper High resolution 
% three-dimensional beam radiation pattern of harbour porpoise clicks
% with implications for passive acoustic monitoring by 
% Jamie D. J. Macaulay, Chloe E. Malinka, Douglas Gillespie, and Peter T. Madsen

% From the paper 
SL0 = 191; % dB pp 
alpha = 0.04; % dB/m 
DTthreshold = 110; %dB 

dx = 1; %m
dy = 1; %m
y = -200.1:dx:800;    
x = -200.1:dy:200;

[XX, YY] = meshgrid(x, y); 
[THETA, R] = cart2pol(XX, YY); % Angle and range for each point of the grid 
THETA = THETA - pi/2; % Shift so that on-axis = yaxis 
  
idxDef = (THETA <=pi/2) & (THETA>=-pi/2);
idxNotDef = ~idxDef;
DLnbcart = zeros(size(THETA));
DLnbmodifiedcart = nan(size(THETA));
DLbbcart = zeros(size(THETA));

%%%% Narrow band directional loss %%%%
DLnbcart(idxDef) = ( 2*J1(ka*sin(THETA(idxDef))) ./ (ka*sin(THETA(idxDef))) ).^2;
DLnbmax = ( 2*J1(ka*sin(90 * pi/180)) / (ka*sin(90 * pi/180)) )^2;
DLnbcart(idxNotDef) = DLnbmax;
DLnbcart = -10*log10(DLnbcart);
ASLnb = SL0 - DLnbcart;

%%%% Broadband directionnal loss %%%%
cx = C2*sin(THETA(idxDef));
DLbbcart(idxDef) = C1 * (cx).^2 ./ (1 + abs(cx) + (cx).^2);
DLmax = C1 * C2^2 / (1 + C2 + C2^2);
DLbbcart(idxNotDef) = DLmax;
ASLbb = SL0 - DLbbcart;
clear DLbbcart

%%%% Narrowband modified %%%%
% Main lobe
% idxtheta_main = THETA >= -x_unique(1) & THETA <= x_unique(1);
% idxMainLobe = (DLnbcart < DLnbmax - 1) & idxtheta_main;

% theta_firstlobe = x_unique(1);
idxMainLobe = (THETA >= -theta_firstlobe) & (THETA <= theta_firstlobe);
% Narrow band directional loss for main lobe
DLnbmodifiedcart(idxMainLobe) = DLnbcart(idxMainLobe);

% Remaining angles
if numel(x_unique) >= 2 % Fix to avoid pb if there is only 1 knot 
    theta_knot2 = x_unique(2) + offset;
else 
    theta_knot2 = x_unique(1) + 4*offset;
end
idxPart2 = (THETA >= theta_knot2) | (THETA <= -theta_knot2);

% Narrow band directional loss for the angles out of main lobe 
% thetaPart2 = THETA(idxPart2);
DLnbmodifiedcart(idxPart2) = -10*log10(DLnbmax); % Constant with value DLnb(theta=90°)

% Interpolate main lobe and part 2
DLnbmodifiedcart = inpaintn(DLnbmodifiedcart);
ASLnbmodified = SL0 - DLnbmodifiedcart;

clear DLnbcart
clear DLnbmodifiedcart

clear THETA;
clear idxDef;
clear idxNotDef;

TL = 20*log10(R) + alpha.*R;
RLbb = ASLbb - TL;
RLnb = ASLnb - TL;
RLnbmodified = ASLnbmodified - TL;

areaPixel = dx * dy;
Area_nb = numel(RLnb(RLnb >= DTthreshold)) * areaPixel;
Area_bb = numel(RLbb(RLbb >= DTthreshold)) * areaPixel;
Area_nbmodified = numel(RLnbmodified(RLnbmodified >= DTthreshold)) * areaPixel;

fig = figure;
% Broadband
h2 = subplot(1, 3, 2);
imagesc(x, y, RLbb)
% Detection threshold contour
hold on 
contour(x, y, RLbb, [0, DTthreshold], '-w', 'LineWidth', 1.5)
colormap(jet)
% colorbar
caxis([100, 150])
set(gca,'YDir','normal')
set(gca, 'YTick', [])
set(gca, 'XTick', -200:200:200)
xtickangle(gca, 45)

title({'Broadband model', sprintf('Area: %.0f m^2', Area_bb)})
xlabel('x [m]')
% ylabel('y [m]')

% Narrowband
h1 = subplot(1, 3, 1);
imagesc(x, y, RLnb)
% Detection threshold contour
hold on
contour(x, y, RLnb, [0, DTthreshold], '-w', 'LineWidth', 1.5)
colormap(jet)
% colorbar
caxis([100, 150])
set(gca,'YDir','normal')
% set(gca, 'YTick', [])
set(gca, 'XTick', -200:200:200)
xtickangle(gca, 45)
title({'Circular piston model', sprintf('Area: %.0f m^2', Area_nb)})
% xlabel('x [m]')
ylabel('y [m]')

% Narrowband modified 
h3 = subplot(1, 3, 3);
imagesc(x, y, RLnbmodified)
% Detection threshold contour
hold on
contour(x, y, RLnbmodified, [0, DTthreshold], '-w', 'LineWidth', 1.5)
% colormap(jet)
% c = colorbar;
% c.Label.String = 'Received level [dB]'; 
caxis([100, 150])
set(gca,'YDir','normal')
set(gca, 'YTick', [])
set(gca, 'XTick', -200:200:200)
xtickangle(gca, 45)
title({'Narrowband model', sprintf('Area: %.0f m^2', Area_nbmodified)})

width = 0.25;
height = 0.796;
leftSpace = 0.03;
left0 = 0.09;
bottom0 = 0.1100;

h1.Position = [ left0               bottom0    width    height];
h2.Position = [ left0+(width+leftSpace)     bottom0    width    height];
h3.Position = [ left0+2*(width+leftSpace)              bottom0    width    height];

% Give common xlabel, ylabel and title to figure
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
% xlabel(han,'x [m]');
% ylabel(han,'y [m]');

c = colorbar(han,'Position', [left0+3*(width+leftSpace/1.2) bottom0  0.02 0.796]);  % attach colorbar to h
c.Label.String = 'Received level [dB]'; 
colormap(c,'jet')
caxis(han, [100, 150]);             % set colorbar limits

%% Plot only narrow-band model for Springer chapter 
fig = figure;
% % Broadband
% h2 = subplot(1, 3, 2);
% imagesc(x, y, RLbb)
% % Detection threshold contour
% hold on 
% contour(x, y, RLbb, [0, DTthreshold], '-w', 'LineWidth', 1.5)
% colormap(jet)
% % colorbar
% caxis([100, 150])
% set(gca,'YDir','normal')
% set(gca, 'YTick', [])
% set(gca, 'XTick', -200:200:200)
% xtickangle(gca, 45)
% 
% title({'Broadband model', sprintf('Area: %.0f m^2', Area_bb)})
% xlabel('x [m]')
% ylabel('y [m]')

% Narrowband
h1 = subplot(1, 2, 1);
imagesc(x, y, RLnb)
% Detection threshold contour
hold on
contour(x, y, RLnb, [0, DTthreshold], '-w', 'LineWidth', 1.5)
colormap(jet)
% colorbar
caxis([100, 150])
set(gca,'YDir','normal')
% set(gca, 'YTick', [])
set(gca, 'XTick', -200:200:200)
xtickangle(gca, 45)
title({'Circular piston model', sprintf('Area: %.0f m^2', Area_nb)})
xlabel('x [m]')
ylabel('y [m]')

% Narrowband modified 
h3 = subplot(1, 2, 2);
imagesc(x, y, RLnbmodified)
% Detection threshold contour
hold on
contour(x, y, RLnbmodified, [0, DTthreshold], '-w', 'LineWidth', 1.5)
% colormap(jet)
% c = colorbar;
% c.Label.String = 'Received level [dB]'; 
caxis([100, 150])
set(gca,'YDir','normal')
set(gca, 'YTick', [])
set(gca, 'XTick', -200:200:200)
xtickangle(gca, 45)
title({'Narrowband model', sprintf('Area: %.0f m^2', Area_nbmodified)})
xlabel('x [m]')

width = 0.35;
height = 0.796;
leftSpace = 0.03;
left0 = 0.09;
bottom0 = 0.1100;

h1.Position = [ left0               bottom0    width    height];
h3.Position = [ left0 + (width+leftSpace)     bottom0    width    height];
% h3.Position = [ left0+2*(width+leftSpace)              bottom0    width    height];

% Give common xlabel, ylabel and title to figure
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
% xlabel(han,'x [m]');
% ylabel(han,'y [m]');

c = colorbar(han,'Position', [left0+2*(width+leftSpace/1.2) bottom0  0.02 0.796]);  % attach colorbar to h
% c = colorbar(h3);  % attach colorbar to h

c.Label.String = 'Received level [dB]'; 
colormap(c,'jet')
caxis(h3, [100, 150]);             % set colorbar limits

% t = tiledlayout(2,2,'TileSpacing','Compact','Padding','Compact');

%% Theta limit for narrow band approximation 
dth = 0.01;
thetadeg = 0:dth:90;
theta = thetadeg * pi/180;
sigmaHdeg = 10;
sigmaH = sigmaHdeg * pi/180;
DL = theta./sigmaH .* exp(-1/2 * (theta./sigmaH).^2);

alpha = 0.95; % confidence level 

figure
plot(thetadeg, DL, 'LineWidth', 2)
xlabel('\theta [°]')
ylabel('W_{OAH}')
grid on
theta_alpha = sigmaH * sqrt(-2 * log(1 - alpha)) * 180/pi;
xline(theta_alpha, '--r', 'label', sprintf('\\theta_{\\alpha} = %.1f', theta_alpha), 'LabelOrientation','horizontal', 'LineWidth',1.5)

hold on
area(thetadeg(thetadeg<theta_alpha), DL(thetadeg<theta_alpha), 'EdgeColor', 'none', 'FaceColor', 'y', 'FaceAlpha', 0.3);
legend({'', '', '95%'})

title({sprintf('Confidence interval at the level \\alpha = %.2f', alpha), ...
    sprintf('W_{OAH} with \\sigma_H = %.0f°', sigmaHdeg)})
