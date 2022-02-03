function g = computeDetectionFunction(varargin)
%COMPUTEDETECTIONFUNCTION Summary of this function goes here
%   Detailed explanation goes here
filename = getVararginValue(varargin, 'filename', '');
SL = getVararginValue(varargin, 'SL', 100); % Source level in decibel (dB) 
sigmaSL = getVararginValue(varargin, 'sigmaSL', 5); % Standard deviation (dB)
DT = getVararginValue(varargin, 'DT', []);
NL = getVararginValue(varargin, 'NL', []);
zTarget = getVararginValue(varargin, 'zTarget', []);
deltaZ = getVararginValue(varargin, 'deltaZ', 5);

[tl, zt, rt] = computeTL(filename); % Transmission loss 

if not (isempty(zTarget) && isempty(zt))
    izToKeep = (zt < zTarget + deltaZ) & (zt > zTarget - deltaZ);
    tl = tl(izToKeep, :);
end
tl = median(tl);

nr = numel(rt);

% Source level normal distribution 
Wsl = @(x) 1/(sqrt(2*pi)*sigmaSL) * exp(-1/2 * ((x - SL)/sigmaSL).^2);

% Detection function values ( g(r) ) 
g = double.empty([nr, 0]);

for i_r = 1:nr
    xmin = tl(i_r) + DT + NL;
    g(i_r) = integral(Wsl, xmin, Inf);
end


% %% Plot
% figure
% plot(rt, g)
% xlabel('Range [m]')
% ylabel('Detection probability')
% hold on 
% yline(0.5, '--r', 'LineWidth', 2, 'Label', '50 % detection threshold')
end

