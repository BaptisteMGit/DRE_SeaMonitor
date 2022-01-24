classdef Signal
    properties 
        centroidFrequency % Centroid emission frequency (Hz) 
        bandWidth % Signal Bandwidth 
        signalEnergy % Signal energy in Ws 
        signalLength % Signal length in s
        directivityIndex % Directivity index in dB 
        sourceLevel % Source level in dB 
        name
    end

    methods
        function obj = Signal(cFreq, bWidth, sEnergy, sLength, dIndex, sLevel)
            obj.centroidFrequency = cFreq;
            obj.bandWidth = bWidth;
            obj.signalEnergy = sEnergy;
            obj.signalLength = sLength;
            obj.directivityIndex = dIndex;
            obj.sourceLevel = sLevel;
        end
    end
end