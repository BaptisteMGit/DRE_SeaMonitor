function plotSE(varargin)
% Plot signal excess 
spl = getVararginValue(varargin, 'SPL', []);
zt = getVararginValue(varargin, 'Depth', []);
rt = getVararginValue(varargin, 'Range', []);
nl = getVararginValue(varargin, 'NL', 0);
dt = getVararginValue(varargin, 'DT', 0);
zTarget = getVararginValue(varargin, 'zTarget', []);
deltaZ = getVararginValue(varargin, 'deltaZ', 5);

SNR = spl -  nl;
SE = SNR - dt; 

pcolor( rt, zt, SE);
shading flat

colormap(red2white) 
caxis([-20, 20])

a = colorbar;
a.Label.String = 'Signal excess [dB]';
set( gca, 'YDir', 'Reverse' )
xlabel('Range [m]')
ylabel('Depth [m]')

yline(zTarget, '--k', 'Living depth', 'LineWidth', 1, 'LabelVerticalAlignment', 'bottom')
yline([zTarget-deltaZ, zTarget+deltaZ], ':k', 'LineWidth', 1)
drawnow

end