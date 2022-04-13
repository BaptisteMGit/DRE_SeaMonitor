classdef Click < Signal
    properties 
        meanICI % Mean inter-click interval in ms
        peakFrequency % Peak frequency in kHz
    end

    methods
        function obj = Click(cFreq, bWidth, dur, sLevel, ssLevel, dirIndex, mean_ICI, pFreq)
            obj = obj@Signal('Click', cFreq, bWidth, dur, sLevel, ssLevel, dirIndex)
            if nargin >= 7; obj.meanICI = mean_ICI; end
            if nargin >= 8; obj.peakFrequency = pFreq; end            
        end
    end
end