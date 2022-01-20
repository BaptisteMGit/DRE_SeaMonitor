function NL = getNLFromWavFileV2(filename, Bandwidth, filterOrder, centerFrequency)
% BW = '1/3 octave';  % Bandwidth : 
% filename = 'C:\Users\33686\Desktop\SeaMonitor\ExFamille\RawData\1208512546.211002123419.wav';
tic
[y, fs] = audioread(filename);

N  = filterOrder;           % Filter order
F0 = centerFrequency;        % Center frequency (Hz)
Fs = fs;       % Sampling frequency (Hz)
of = octaveFilter('FilterOrder', N, 'CenterFrequency', F0,  ...
                  'Bandwidth', Bandwidth, 'SampleRate',Fs);
y = of(y);

% x = y(1:1000);
% yfft = fft(x);
% n = length(x);          % number of samples
% f = (0:n-1)*(fs/n);     % frequency range
% power = abs(yfft).^2/n;    % power of the DFT
% figure
% plot(f,power)
% xlabel('Frequency')
% ylabel('Power')


cal = 173.3;
cal = 10^(cal / 20); % convert calibration from dB into ratio
p = y * cal; % multiply wav data by calibration to convert to units of uPa
pref = 1; % Reference pressure in uPa 

Twindow = 60; % 60 seconds time window 
nT = Twindow * fs;

iT = 1;
iTnext = nT;
listLeq = [];
while iTnext < numel(p)
    p_T = p(iT:iTnext);
    Leq = 10 * log10 (1 / (Twindow * fs) * sum(p_T.^2 / pref.^2));
    fprintf('Leq = %2.2f dB\n', Leq)
    iT = iTnext;
    iTnext = iTnext + nT; 
    listLeq = [listLeq, Leq];
end

NL = mean(listLeq);
fprintf('MeanLeq = %2.2f dB', NL)

end