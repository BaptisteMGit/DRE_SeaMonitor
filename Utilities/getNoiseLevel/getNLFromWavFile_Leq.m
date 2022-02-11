function Lrms = getNLFromWavFile_Leq(signal, cal)
    % GETNLFROMWAVFILE_LEQ Derive continuous equivalent sound pressure
    % (rms) from time serie. 
    y = signal.y;
    fs = signal.fs;
    
    %% Calibrate signal
    cal = 10^(cal / 20); % convert calibration from dB into ratio
    p = y * cal; % multiply wav data by calibration to convert to units of uPa
    pref = 1; % RMS Reference pressure in uPa 
    

    %% Derive RMS SPL 
    nT = numel(p);
    p_average = 1/nT * sum(p.^2);
    p_rms = sqrt(p_average);
    Lrms = 10 * log10(p_rms / pref);
    fprintf('Lrms = %2.2f dB (derived from time serie)\n', Lrms)

end