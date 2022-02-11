function Lrms = getNLFromWavFile_Lrms(signal, cal)
    % GETNLFROMWAVFILE_LEQ RMS sound pressure level from time serie. 
    
    % According to NPL Good Practice Guide No. 133, ISSN: 1368-6550:
    % "The metric most suitable for continuous sounds (including ambient 
    % noise) is: Sound Pressure Level (SPL). 
    % Note that by convention, this is a time-averaged quantity and is most
    % commonly understood as an RMS value. The averaging time used in the 
    % calculation of the values of SPL must be stated."

    y = signal.y;
    fs = signal.fs;
    
    %% Calibrate signal
    cal = 10^(cal / 20); % convert calibration from dB into ratio
    p = y * cal; % multiply wav data by calibration to convert to units of uPa
    pref = 1; % RMS Reference pressure in uPa 
    
    %% Derive RMS SPL 
    N = numel(p);
    p_rms = sqrt( 1/N * sum(p.^2) );
    Lrms = 20 * log10(p_rms / pref);
%     fprintf('Lrms = %2.2f dB (derived from time serie)\n', Lrms)

end