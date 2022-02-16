function [g, detectionRange] = computeDetectionFunction(varargin)
%COMPUTEDETECTIONFUNCTION Summary of this function goes here
%   Detailed explanation goes here
filename = getVararginValue(varargin, 'filename', '');
SL0 = getVararginValue(varargin, 'SL', 100); % Npminal source level in decibel (dB) 
sigmaSL = getVararginValue(varargin, 'sigmaSL', 5); % Standard deviation (dB)
DT = getVararginValue(varargin, 'DT', []);
NL = getVararginValue(varargin, 'NL', []);
zTarget = getVararginValue(varargin, 'zTarget', []);
deltaZ = getVararginValue(varargin, 'deltaZ', 5);
DRThreshold = getVararginValue(varargin, 'DRThreshold', '50%');
offAxisDistribution = getVararginValue(varargin, 'offAxisDistribution', 'Uniformly distributed on a sphere (random off-axis)');
sigmaHdeg = getVararginValue(varargin, 'sigmaH', 10);
DI = getVararginValue(varargin, 'DI', 22); % Directivity index 

%% Transmission loss 
[tl, zt, rt] = computeTL(filename); % Transmission loss 
if not (isempty(zTarget) && isempty(zt))
    izToKeep = (zt < zTarget + deltaZ) & (zt > zTarget - deltaZ);
    tl = tl(izToKeep, :);
end
tl = median(tl);

%% Crop tl to avoid uncoherent values in the first meters 
% The first meters have import TL values which are note traducing any
% physical phenomenon. Those value are due to the limited anglular aperture covered by
% the rays emitted by the source ([-89; 89])

epsilon = 1; % Allowed diff in DB 
f = fittype('a*log10(x) + b*x', ... 
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'a','b'});
% We only consider the first value for fitting in order to be as close as
% possible to the TL computed by BELLHOP for small range (the zone where
% the issue occurs) 
rtCrop = rt(1:200);
tlCrop = tl(1:200);
[fit1,~,~] = fit(rtCrop',tlCrop',f,'StartPoint',[1 1], 'Robust','on', 'Exclude', rtCrop < 10);

TLR = fit1.a*log10(rt) + fit1.b*rt; % Fitted spreading law
% Values to far (diff > epsilon) from the fitted spreading law are replaced by the value of
% the fitted spreading law itself 
idxCrop = (abs(tl - TLR) > epsilon);
idxCropMax = find(~idxCrop, 1, 'first');
idxCrop(idxCropMax:end) = 0;
tl(idxCrop) = TLR(idxCrop);

nr = numel(rt);
%% Source level distribution 
% Source level normal distribution 
Wsl = @(x) 1/(sqrt(2*pi)*sigmaSL) * exp(-1/2 * ((x - SL0)/sigmaSL).^2);

%% Off-axis attenuation 
% Ref: Passive Acoustic Monitoring of Cetaceans, Walter M. X. Zimmer,
% p260-267
% ka = 17.8; % 
% p99: Eq. 3.8 adapted considering DI = 20 log(ka) 
% NOTE: This approximation of DI is valid for narrowband signal with ka>>1
% yet we use it to derive ka fort all short pulses 

ka = 10^(DI/20);
C1 = 47; % dB
C2 = 0.218*ka;
DLmax = C1 * C2^2 / (1 + C2 + C2^2);

% Inverse function of off-axis attenuation
% It is a piecewise-defined function 
DLinv = @(DL)...
    0 * (DL <= 0) + ... % DL = 0
    asin(1/(2*C2) * (DL/(DL - C1)) * real(-sqrt(1-4*(DL-C1)/DL - 1))) * (0 < DL & DL < DLmax) + ... % 0 < DL < DLmax
    pi * (DL >= DLmax); % DL >= DLmax

%% Figure of merit 
% Constant part of the figure of merit describing environmental and PAM system parameters 
% The non-constant part of FOM is given by SL (normally distributed)
F0 = NL + DT; 
FOM0 = SL0 - F0; % Nominal figure of merit 

%% Detection probability 
switch offAxisDistribution
    case 'Uniformly distributed on a sphere (random off-axis)'
        % Here we consider that the off-axis angle is uniformly distributed
        % on a sphere. That is to say that the marine mammal (= the
        % acoustic source)  is not necessarily heading toward the
        % hydrophone. 

        % Intermidiate function to compute the second integral 
        h = @(u, v) exp(-1/2 * ((u + v - FOM0) / sigmaSL).^2) .* (1 - cos(DLinv(u)));
        
        % Detection function values ( g(r) ) 
        g = double.empty([nr, 0]);
        for i_r = 1:nr
            % Transmission loss at given range r = rt(i_r)
            TL = tl(i_r);

            % Integrating over all source levels for which detection occurs 
            x0 = F0 + TL + DLmax;
            phi = integral(Wsl, x0, Inf); 
            
            % Part that handle the cases where the off-axis angles matter
            f_TL = @(u) h(u, TL);
            omega = integral(f_TL, 0, DLmax);
            
            % Total detection probability 
            g(i_r) = phi + 1/(2*sqrt(2*pi)*sigmaSL) * omega;
        end

    case 'Near on-axis'
        % Here we only consider the cues emitted by a marine mammal (= the
        % acoustic source)  heading toward the hydrophone. That is to say
        % when the receiver is on-axis with the animal orientation. We
        % assume that the head of the animal is moving randomly relative to
        % the on-axis with no vertical or horizontal preference. Therefore 
        % the off-axis distribution is a Reyleigh distribution. 
        
        % Head angle standard deviation 
        sigmaH = sigmaHdeg * pi/180;

        % Intermidiate function to compute the second integral: psy
        k = @(u, v) 1 / (sigmaSL * sqrt(2*pi)) * exp(-1/2 * ((u + v - FOM0) / sigmaSL).^2);

        % Intermidiate function to compute the third integral: omega
        h = @(u, v) 1 / (sigmaSL * sqrt(2*pi)) * exp(-1/2 * ( ((u + v - FOM0) / sigmaSL).^2 + (DLinv(u) / sigmaH).^2) );
        
        % Detection function values ( g(r) ) 
        g = double.empty([nr, 0]);
        for i_r = 1:nr
            % Transmission loss at given range r = rt(i_r)
            TL = tl(i_r);

            % Integrating over all source levels for which detection occurs 
            x0 = F0 + TL + DLmax;
            phi = integral(Wsl, x0, Inf); 
            
            % Part that handle the cases where the off-axis angles matter
            l_TL = @(u) k(u, TL);
            psy = integral(l_TL, 0, DLmax);

            f_TL = @(u) h(u, TL);
            omega = integral(f_TL, 0, DLmax);
            
            % Total detection probability 
            g(i_r) = phi + psy - omega;
        end
end


%% Compute detection range 
threshold = str2double(DRThreshold(1:end-1)) / 100;
y = threshold * ones(size(rt));
idxSup = (g >= y);
idxThreshold = find(idxSup, 1, 'last');
if isempty(idxThreshold)
    detectionRange = 0;
else
    detectionRange = rt(idxThreshold);
end

%% Plot
% figure
% plot(rt, g)
% xlabel('Range [m]')
% ylabel('Detection probability')
% hold on 
% yline(0.5, '--r', 'LineWidth', 2, 'Label', '50 % detection threshold')
end

