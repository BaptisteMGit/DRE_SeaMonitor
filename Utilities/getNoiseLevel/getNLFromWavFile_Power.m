function NL = getNLFromWavFile_Power(filteredSignal, cal, Twindow)

y = filteredSignal.y;
fs = filteredSignal.fs;

cal = power (10, cal / 20); % convert calibration from dB into ratio
y = y * cal; % multiply wav data by calibration to convert to units of uPa

% Compute power spectral density estimate
window = 500;
noverlap = 300;
nfft = 500;

[pxx, f] = pwelch(y, window, noverlap, nfft, fs);

f_inf = BW(1);
f_sup = BW(2);
idx = (f>f_inf) & (f<f_sup);

% Extract band of interest 
pxx = pxx(idx);
f = f(idx);

% Integrate spectral density for the bandwidth B  
NLlinear = trapz(pxx);

% Convert into dB
NL = 10*log10(NLlinear);
toc

end