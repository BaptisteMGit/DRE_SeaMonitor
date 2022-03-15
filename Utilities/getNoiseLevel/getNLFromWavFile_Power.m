function Lrms = getNLFromWavFile_Power(signal, cal)
    % GETNLFROMWAVFILE_POWER Derive noise level from Power Spectral Density
    % estimate. 
    y = signal.y;
    fs = signal.fs;
    
    cal = power (10, cal / 20); % convert calibration from dB into ratio
    y = y * cal; % multiply wav data by calibration to convert to units of uPa
    
    % Estimate power spectral density 
    % Those values could be discuss ? 
    window = 1024; 
    nfft = 1024;
    noverlap = nfft/2; % 50% overlapping
    
    % Hanning window seems to be adapted to our purpose (According to Understanding FFTs 
    % and Windowing) 
    [PSD, f] = pwelch(y, hann(window), noverlap, nfft, fs);
    
    % Integrate power spectral density over the bandwidth
    df = fs/nfft;
    L = sum(df * PSD);
    Lrms = sqrt(L);
    
    % Convert into dB
    Lrms = 10*log10(Lrms);
    fprintf('Lrms = %2.2f dB (derived from PSD)\n', Lrms)
    
    %% Plot 
    % figure 
    % plot(f, PSD)
    % set(gca, 'XScale', 'log')
    % xlabel('Frequency [Hz]')
    % ylabel('PSD [dB re \muPa^2/Hz]')
    % grid on 

end