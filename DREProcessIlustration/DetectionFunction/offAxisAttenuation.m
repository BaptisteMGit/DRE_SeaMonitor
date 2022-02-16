% Script to show off-axis attenuation approximation used to derive
% detection function. 
% Ref: Passive Acoustic Monitoring of Cetaceans by Walter M. X. Zimmer 
% Page: 96 - 100

% Constants 

DI = 1; % Directivity index of Porpoise (PAMofC (p89)) [dB]
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
title('Directionnal loss approximation for broadband signal')
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

figure 
lgd = {};
plot(thetadeg, DLnb, 'r', 'LineWidth', 1)
lgd{end + 1} = 'Narrowband signal';
hold on 
plot(thetadeg, DLbb, 'b', 'LineWidth', 1)
lgd{end + 1} = 'Broadband signal';

idxAlpha3dB = find((DLbb<=3), 1, 'first');
alpha3dB = thetadeg(idxAlpha3dB);
xline(-alpha3dB, 'b', 'LineStyle', '--', 'LineWidth', 1)
xline(alpha3dB, 'b', 'LineStyle', '--', 'LineWidth', 1, ...
    'Label', sprintf('Broadband beamwidth = %.1f°', abs(alpha3dB)), 'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment','right', 'LabelOrientation', 'aligned')

xlabel('Off-axis angle [°]')
ylabel('Off-axis attenuation [dB]')
title({'Directionnal loss approximation', ... 
     'Porpoise - DI = 22dB'})
set(gca, 'YDir', 'reverse')

idxAlpha3dB = find((DLnb<3), 1, 'first');
alpha3dB = thetadeg(idxAlpha3dB);
xline(alpha3dB, 'r', 'LineStyle', '--', 'LineWidth', 1)
xline(-alpha3dB, 'r', 'LineStyle', '--', 'LineWidth', 1, ...
    'Label', sprintf('Narrowband beamwidth = %.1f°', abs(alpha3dB)), 'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment','right', 'LabelOrientation', 'aligned')
yline(3,  'k', 'LineStyle', '--', 'LineWidth', 1, ...
    'Label', '-3dB')
ylim([0 50])
xlim([-90, 90])

% Polar plot 
% Apparent source level
SL0 = 100;
ASLnb = SL0 - DLnb;
figure 
lgd = {};
polarplot(theta, ASLnb, 'LineWidth', 1)
lgd{end+1} = sprintf('Apparent source level - narrow band');

hold on 
polarplot(theta, ASLbb, 'LineWidth', 1)
lgd{end+1} = sprintf('Apparent source level - broadband');

hold on
polarplot([0; 0]*pi/180, [0; SL0],'LineWidth', 2)  
lgd{end +1} = 'Acoustic axis';
hold on 
polarplot([45; 45]*pi/180, [0; SL0], 'LineWidth', 2, 'LineStyle', '--')  
lgd{end +1} = 'Off-axis';

title({'Apparent source level for a narrow band signal', ...
    'Porpoise - DI = 22dB, SL_0 = 173dB'})
legend(lgd, 'Location', 'southoutside')

%% DLnb restricted to main lobe ?
dth = 0.01;
thetadeg = -90:dth:90;
theta = thetadeg * pi/180;

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

figure
lgd = {};
% Apparent source level
SL0 = 100;
ASLnb = SL0 - DLnb;
polarplot(theta, ASLnb)
lgd{end+1} = 'DL_{nb}';

%%% Main lobe %%%
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

idxThetaFirstKnot = find(diff(DLnb) < 0, 1, "first");
thetadeg_mainlobe = thetadeg(idxThetaFirstKnot);

thetadeg = -thetadeg_mainlobe:dth:thetadeg_mainlobe;
theta = thetadeg * pi/180;

% Narrow band directional loss for main lobe
DLnb_mainlobe = ( 2*J1(ka*sin(theta)) ./ (ka*sin(theta)) ).^2;
DLnb_mainlobe = -10*log10(DLnb_mainlobe);

ASLnb_mainlobe = SL0 - DLnb_mainlobe;
hold on
polarplot(theta, ASLnb_mainlobe, '--r', 'LineWidth', 2)
lgd{end +1} = 'DL_{nb}_{mainlobe}';
hold on 
polarplot([thetadeg_mainlobe; thetadeg_mainlobe]*pi/180, [0; SL0], 'k', 'LineWidth', 2, 'LineStyle', '--')  
polarplot([-thetadeg_mainlobe; -thetadeg_mainlobe]*pi/180, [0; SL0], 'k', 'LineWidth', 2, 'LineStyle', '--')  
lgd{end +1} = sprintf('\\theta_{mainlobe} = %.0f', thetadeg_mainlobe);
legend(lgd)

% polarplot(theta_mainlobe, DLnb_mainlobe)
% thetadeg_modified = thetadeg(~isnan(DLnb));
% DLnb_modified(idInf) = 100;
% DL = 1:0.1:100;
% thetaInv = interp1(DLnb_modified, thetadeg_modified, DL);

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
