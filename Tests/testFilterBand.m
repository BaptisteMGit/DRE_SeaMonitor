source = dsp.AudioFileReader('C:\Users\33686\Desktop\SeaMonitor\ExFamille\RawData\1208512546.211002123419.wav');
fs = source.SampleRate;

cal = 173.3;
cal = power (10, cal / 20); % convert calibration from dB into ratio

% player = audioDeviceWriter('SampleRate',fs);

SPL = splMeter( ...
    'Bandwidth','1/3 octave', ...
    'SampleRate',fs, ...
    'CalibrationFactor', cal, ...
    'PressureReference', 1e-5);
centerFrequencies = getCenterFrequencies(SPL);

scope  = dsp.ArrayPlot(...
    'XDataMode','Custom', ...
    'CustomXData',centerFrequencies, ...
    'XLabel','Octave Band Center Frequencies (Hz)', ...
    'YLabel','Equivalent-Continuous Sound Level (dB)', ...
    'YLimits',[20 90], ...
    'ShowGrid',true, ...
    'Name','Sound Pressure Level Meter');

LeqPrevious = zeros(size(centerFrequencies));
while ~isDone(source)
    x = source();
%     player(x);
    [~,Leq] = SPL(x);

    for i = 1:size(Leq,1)
        if LeqPrevious ~= Leq(i,:)
            scope(Leq(i,:)')
            LeqPrevious = Leq(i,:);
        end
    end

end