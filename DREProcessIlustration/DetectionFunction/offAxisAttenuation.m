% Script to show off-axis attenuation approximation used to derive
% detection function. 
% Ref: Passive Acoustic Monitoring of Cetaceans by Walter M. X. Zimmer 
% Page: 96 - 100

% Constants 
C1 = 47; % dB
ka = 17.8; % 
C2 = 0.218*ka;

%% X, Y plot to show loss
% Directionnal loss of the source as a function of off-axis angle for
% broadband signal (click). 
dth = 0.1;
thetadeg = 0:dth:90;
theta = thetadeg * pi/180;

cx = C2*sin(theta);
DLbb = C1 * (cx).^2 ./ (1 + abs(cx) + (cx).^2);

figure 
plot(thetadeg, DLbb)
xlabel('Off-axis angle [°]')
ylabel('Off-axis attenuation [dB]')
title('Directionnal loss approximation for broadband signal')
set(gca, 'YDir', 'reverse')


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
ASL = SL0 - DLbb;
figure 
lgd = {};
polarplot(theta, ASL, 'LineWidth', 1)
lgd{end+1} = sprintf('Apparent source level with SL0 = %d dB', SL0);
hold on
polarplot([0; 0]*pi/180, [0; SL0],'LineWidth', 2)  
lgd{end +1} = 'Acoustic axis';
hold on 
polarplot([45; 45]*pi/180, [0; SL0], 'LineWidth', 2, 'LineStyle', '--')  
lgd{end +1} = 'Off-axis';

legend(lgd, 'Location', 'southoutside')