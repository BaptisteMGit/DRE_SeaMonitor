function NL = getNLFromWenzModel(varargin)
% Compute noise level using wenz model 
% Ref: Michel Legris, Systèmes sonars de bathymétrie et d'imagerie. Rapp.
% tech. Ensta-Bretagne, 2020, v1.4.1
% tic
fMin = getVararginValue(varargin, 'fMin', 1);
fMax = getVararginValue(varargin, 'fMax', 200000);
Is = getVararginValue(varargin, 'TrafficIntensity', 3); % Between 1 and 7
Wsp = getVararginValue(varargin, 'WindSpeed', 20); % Wind speed in knots  

% freq = fMin:1:fMax;
freq = 1:1:200000;
NIS_1 = zeros([1, numel(freq)]);
NIS_2 = zeros([1, numel(freq)]);
NIS_3 = zeros([1, numel(freq)]);
NIS_4 = zeros([1, numel(freq)]);

figure 
lgd = {};
%% Ultra Low Frequency
% Noise due to oceanic mouvements 0Hz - 10Hz
idx = (freq < 10);
f = freq(idx);
NIS_1(idx) = 107 - 30 * log10(f);
plot(f, NIS_1(idx), 'LineWidth', 3)
lgd{end+1} = 'Oceanic mouvement';
NIS_1 = 10.^(NIS_1/10); 

%% Very Low Frequency
% Anthropogenic noise 10Hz - 500Hz
idx = ((freq >= 10) & (freq < 500));
f = freq(idx);
NIS_2(idx) = 76 - 20 * (log10(f/30)).^2 + 5 *(Is - 4);
hold on
plot(f, NIS_2(idx), 'LineWidth', 3)
lgd{end+1} = sprintf('Anthropogenic noise with trafic intensity = %d', Is);
NIS_2 = 10.^(NIS_2/10); 

%% Low to high frequency 
% Natural noise (wind, waves)
idxinf = (freq >= 200) & (freq < 1000);
finf = freq(idxinf);
NIS_3(idxinf) = 44 + sqrt(21*Wsp) + 17*(3 - log10(finf)) .* (log10(finf) - 2);

idxsup = (freq >= 1000) & (freq < 100000);
fsup = freq(idxsup);
NIS_3(idxsup) = 95 + sqrt(21*Wsp) - 17*(log10(fsup));

hold on
plot(freq(idxinf | idxsup), NIS_3(idxinf | idxsup), 'LineWidth', 3)
lgd{end+1} = sprintf('Natural noise with wind speed = %d kts', Wsp);

NIS_3 = 10.^(NIS_3/10); 

%% High frequency 
% Thermal noise
idx = (freq >= 100000); 
f = freq(idx);
NIS_4(idx) = -75 + 20*(log10(f));
hold on
plot(f, NIS_4(idx), 'LineWidth', 3)
lgd{end+1} = 'Thermic noise';
NIS_4 = 10.^(NIS_4/10); 

NIS = NIS_1 + NIS_2 + NIS_3 + NIS_4;

% Get the bandwidth of interest 
idxBW = (freq > fMin) & (freq < fMax);
NISBW = NIS(idxBW);
% Integrate over the bandwidth
NL = sum(NISBW);
NL = 10 * log10(NL); % Back to dB
NL = round(NL, 0);
sprintf('Noise level = %d dB', NL)
% toc
%% Plot
NIS = 10*log10(NIS); % Convert to dB
hold on
plot(freq, NIS, '--k', 'LineWidth', 1)
lgd{end+1} = 'Total ambient noise';
xline([fMin, fMax], '-', {sprintf('fMin = %d Hz', fMin), sprintf('fMax = %d Hz', fMax)}, 'LabelOrientation', 'aligned', 'LabelHorizontalAlignment', 'left')

set(gca,'XScale','log') 
xlabel('Frequency (Hz)')
ylabel('Spectral density (dB/\surdHz)')
ylim([0, max(NIS)+20])
legend(lgd, 'Location','southwest')
hold on
area(freq(idxBW), NIS(idxBW), 'EdgeColor', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.2, 'DisplayName', 'Area integrated');

title('Wenz curves')
end

