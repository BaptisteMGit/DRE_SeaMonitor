function NL = getNLFromWavFile(filename, B)

% filename = 'C:\Users\33686\Desktop\SeaMonitor\ExFamille\RawData\1208512546.211002123419.wav';
[y, fs] = audioread(filename);

y = y(1:100000);
cal = 173.3;
cal = power (10, cal / 20); % convert calibration from dB into ratio
y = y * cal; % multiply wav data by calibration to convert to units of uPa

% Compute power spectral density estimate
window = 500;
noverlap = 300;
nfft = 500;
[pxx, f] = pwelch(y, window, noverlap, nfft, fs);

f_inf = B(1);
f_sup = B(2);
idx = (f>f_inf) & (f<f_sup);

% Extract band of interest 
pxx = pxx(idx);
f = f(idx);

% Integrate spectral density for the bandwidth B  
NLlinear = trapz(pxx);

% Convert into dB
NL = 10*log10(NLlinear);

end