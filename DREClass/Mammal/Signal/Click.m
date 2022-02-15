classdef Click < Signal
    properties 
        meanICI % Mean inter-click interval in ms
        peakFrequency % Peak frequency in kHz
    end

    methods
        function obj = Click(cFreq, sLevel, ssLevel, mean_ICI, pFreq, dirIndex)
            obj = obj@Signal('Click', cFreq, sLevel, ssLevel, dirIndex)
            if nargin >= 3; obj.meanICI = mean_ICI; end
            if nargin >= 4; obj.peakFrequency = pFreq; end            
        end
    end
end