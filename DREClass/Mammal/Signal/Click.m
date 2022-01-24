classdef Click < Signal
    properties 
        meanICI % Mean inter-click interval in ms
        peakFrequency % Peak frequency in kHz
    end

    methods
        function obj = Click(cFreq, bWidth, sEnergy, sLength, dIndex, sLevel, mean_ICI, pFreq)
            obj = obj@Signal(cFreq, bWidth, sEnergy, sLength, dIndex, sLevel)
            obj.meanICI = mean_ICI;
            obj.peakFrequency = pFreq;
            obj.name = 'Click';
        end
    end
end