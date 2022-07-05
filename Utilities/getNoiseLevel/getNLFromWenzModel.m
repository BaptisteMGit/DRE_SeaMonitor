function NLvalue = getNLFromWenzModel(varargin)
% Compute noise level using wenz model 
% Ref: 
% Michel Legris, Systèmes sonars de bathymétrie et d'imagerie. Rapp.
% tech. Ensta-Bretagne, 2020, v1.4.1
% Passive Acoustic Monitoring of Cetaceans by Walter M. X. Zimmer 

fMin = getVararginValue(varargin, 'fMin', 1);
fMax = getVararginValue(varargin, 'fMax', 200000);
Is = getVararginValue(varargin, 'TrafficIntensity', 0); % 0, 1, 2, 3 <-> quiet, low, medium, heavy 
Wsp = getVararginValue(varargin, 'WindSpeed', 0); % Wind speed in m.s-1   
T = getVararginValue(varargin, 'Temperature', 13); % Temperature in °C
S = getVararginValue(varargin, 'Salinity', 35); % Salinity in ppt
pH = getVararginValue(varargin, 'pH', 7.8); % pH 
Depth = getVararginValue(varargin, 'Depth', 10); % Hydrophone depth m 

Depth = round(Depth, 0); 

% freq = fMin:1:fMax;
freq = 1:1:300000;
fkHz = freq/1000;

% Correction of the hydrophone depth 
Alpha = FrancoisGarrison(fkHz, T, S, Depth, pH); % Attenuation coefficient in dB.km-1
Alpha = Alpha/1000; % dB.m-1
dCorr1 = Alpha*Depth; % Decrease of the contribution of individual source due to propagation loss 
dCorr2 = 10*log(1 + dCorr1/8.686); % Decrease of the number of contributing sources 
depthCorr = dCorr1 + dCorr2;

% Label for traffic intenty
listLabel = {'quiet', 'low', 'medium', 'heavy'};
trafficIntensityLabel = listLabel{Is+1};

%% Ultra Low Frequency
% Noise due to oceanic turbulence 0Hz - 10Hz
NLturb = 17 - 30*log10(fkHz);

%% Very Low Frequency
% Shipping noise 10Hz - 1KHz
NL_ship_0 = 60 + 10*Is - 20*log10(max(0.1, fkHz)); 
NL_ship_d = NL_ship_0 - depthCorr; % Shipping noise contribution at the hydrophone depth

%% Low to high frequency 
% Surface noise (wind, waves)
NLsurf_0 = 44 + 23*log10(Wsp+1) - 17*log10(max(1, fkHz)); % Noise level at the surface 
NLsurf_d = NLsurf_0 - depthCorr; % Surface noise contribution at the hydrophone depth

%% High frequency 
% Thermal noise
NLtherm = -15 + 20*log10(fkHz);

%% Overall ambient noise spectrum 
NL = 10.^(NLturb/10) + 10.^(NL_ship_d/10) + 10.^(NLsurf_d/10) + 10.^(NLtherm/10);

% Get the bandwidth of interest 
idxBW = (freq > fMin) & (freq < fMax);
NLBW = NL(idxBW);
% Integrate over the bandwidth
NLvalue = sum(NLBW);
NLvalue = 10 * log10(NLvalue); % dB/Hz
NLvalue = round(NLvalue, 0);
sprintf('Noise level = %d dB', NLvalue)

%% Plot
NLspectrum = 10*log10(NL); % Convert to dB

figure 
hp = plot(freq, [NLturb; NL_ship_d; NLsurf_d; NLtherm; NLspectrum]);
set(hp(1), {'LineStyle', 'LineWidth', 'Color'}, {'--', 1, 'b'})
set(hp(2), {'LineStyle', 'LineWidth', 'Color'}, {'-.', 1, 'r'})
set(hp(3), {'LineStyle', 'LineWidth', 'Color'}, {'--', 1, 'g'})
set(hp(4), {'LineStyle', 'LineWidth', 'Color'}, {'-.', 1, 'm'})
set(hp(5), {'LineStyle', 'LineWidth', 'Color'}, {'-', 2, 'k'})

hold on
xline([fMin, fMax], '-',...
    {sprintf('fMin = %d Hz', fMin), sprintf('fMax = %d Hz', fMax)},...
    'LabelOrientation', 'aligned', 'LabelHorizontalAlignment', 'left')

set(gca,'XScale','log') 
xlabel('Frequency [Hz]')
ylabel('Spectral noise level [dB re 1 \muPa^2/Hz]')
legend({'NL_{Turb}',...
    sprintf('NL_{Ship} with %s ship traffic', trafficIntensityLabel),...
    sprintf('NL_{Surf} with wind = %.1f m.s-1', Wsp),...
    'NL_{Therm}', 'NL_{Tot}'},...
    'Location','southwest')

hold on
area(freq(idxBW), NLspectrum(idxBW), 'EdgeColor', 'none', 'FaceColor', 'y', 'FaceAlpha', 0.3, 'DisplayName', 'Area integrated');

ylim([0, 100])
legend()
title(sprintf('Wenz curves - hydrophone depth of %.0fm', Depth))


% NIS_1 = zeros([1, numel(freq)]);
% NIS_2 = zeros([1, numel(freq)]);
% NIS_3 = zeros([1, numel(freq)]);
% NIS_4 = zeros([1, numel(freq)]);

% %% Ultra Low Frequency
% % Noise due to oceanic turbulence 0Hz - 10Hz
% idx = (freq < 10);
% f = freq(idx);
% NIS_1(idx) = 107 - 30 * log10(f);
% plot(f, NIS_1(idx), 'LineWidth', 3)
% lgd{end+1} = 'Oceanic mouvement';
% NIS_1 = 10.^(NIS_1/10); 
% 
% %% Very Low Frequency
% % Anthropogenic noise 10Hz - 500Hz
% idx = ((freq >= 10) & (freq < 500));
% f = freq(idx);
% NIS_2(idx) = 76 - 20 * (log10(f/30)).^2 + 5 *(Is - 4);
% hold on
% plot(f, NIS_2(idx), 'LineWidth', 3)
% lgd{end+1} = sprintf('Anthropogenic noise with trafic intensity = %d', Is);
% NIS_2 = 10.^(NIS_2/10); 
% 
% %% Low to high frequency 
% % Natural noise (wind, waves)
% idxinf = (freq >= 200) & (freq < 1000);
% finf = freq(idxinf);
% NIS_3(idxinf) = 44 + sqrt(21*Wsp) + 17*(3 - log10(finf)) .* (log10(finf) - 2);
% 
% idxsup = (freq >= 1000) & (freq < 100000);
% fsup = freq(idxsup);
% NIS_3(idxsup) = 95 + sqrt(21*Wsp) - 17*(log10(fsup));
% 
% hold on
% plot(freq(idxinf | idxsup), NIS_3(idxinf | idxsup), 'LineWidth', 3)
% lgd{end+1} = sprintf('Natural noise with wind speed = %d kts', Wsp);
% 
% NIS_3 = 10.^(NIS_3/10); 
% 
% %% High frequency 
% % Thermal noise
% idx = (freq >= 100000); 
% f = freq(idx);
% NIS_4(idx) = -75 + 20*(log10(f));
% hold on
% plot(f, NIS_4(idx), 'LineWidth', 3)
% lgd{end+1} = 'Thermic noise';
% NIS_4 = 10.^(NIS_4/10); 
% 
% NIS = NIS_1 + NIS_2 + NIS_3 + NIS_4;

% % Get the bandwidth of interest 
% idxBW = (freq > fMin) & (freq < fMax);
% NISBW = NIS(idxBW);
% % Integrate over the bandwidth
% NL = sum(NISBW);
% NL = 10 * log10(NL); % Back to dB
% NL = round(NL, 0);
% sprintf('Noise level = %d dB', NL)
% % toc
% %% Plot
% NIS = 10*log10(NIS); % Convert to dB
% hold on
% plot(freq, NIS, '--k', 'LineWidth', 1)
% lgd{end+1} = 'Total ambient noise';
% xline([fMin, fMax], '-', {sprintf('fMin = %d Hz', fMin), sprintf('fMax = %d Hz', fMax)}, 'LabelOrientation', 'aligned', 'LabelHorizontalAlignment', 'left')
% 
% set(gca,'XScale','log') 
% xlabel('Frequency (Hz)')
% ylabel('Spectral density (dB/\surdHz)')
% ylim([0, max(NIS)+20])
% legend(lgd, 'Location','southwest')
% hold on
% area(freq(idxBW), NIS(idxBW), 'EdgeColor', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.2, 'DisplayName', 'Area integrated');
% 
% title('Wenz curves')
end

