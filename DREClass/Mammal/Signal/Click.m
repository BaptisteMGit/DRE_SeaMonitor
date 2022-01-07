classdef Click < Signal
    properties 
        meanICI % Mean inter-click interval in clicks/s
        peakFrequency % Peak frequency in kHz
    end

    methods
        function obj = Click(cFreq, sEnergy, sLength, dIndex, sLevel, mean_ICI, pFreq)
            obj = obj@Signal(cFreq, sEnergy, sLength, dIndex, sLevel)
            obj.meanICI = mean_ICI;
            obj.peakFrequency = pFreq;
        end
    end
end