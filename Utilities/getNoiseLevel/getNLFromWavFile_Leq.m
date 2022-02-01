function Leq = getNLFromWavFile_Leq(signal, cal)
    y = signal.y;
    fs = signal.fs;
    
    cal = 10^(cal / 20); % convert calibration from dB into ratio
    p = y * cal; % multiply wav data by calibration to convert to units of uPa
    pref = 1; % Reference pressure in uPa 
    
    nT = numel(p);
    Leq = 10 * log10 (1 / nT * sum(p.^2 / pref.^2));
    fprintf('Leq = %2.2f dB\n', Leq)
end