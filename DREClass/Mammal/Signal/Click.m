classdef Click < Signal
    properties 
        meanICI % Mean inter-click interval in ms
        peakFrequency % Peak frequency in kHz
    end

    methods
        function obj = Click(cFreq, sLevel, mean_ICI, pFreq)
            obj = obj@Signal('Click', cFreq, sLevel)
            if nargin >= 3; obj.meanICI = mean_ICI; end
            if nargin >= 4; obj.peakFrequency = pFreq; end            
        end
    end
end