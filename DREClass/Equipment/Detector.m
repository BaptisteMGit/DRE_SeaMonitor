classdef Detector
%% DETECTOR class to handle the different type of detectors 
    properties 
        detectionThreshold % Detection threshold used by the detector 
        signalEnergy % Signal energy in Ws 
        signalLength % Signal length in s
        directivityIndex % Directivity index in dB 
        sourceLevel % Source level in dB 
    end
    
    methods
        function obj = Signal(cFreq, sEnergy, sLength, dIndex, sLevel)
            obj.centroidFrequency = cFreq;
            obj.signalEnergy = sEnergy;
            obj.signalLength = sLength;
            obj.directivityIndex = dIndex;
            obj.sourceLevel = sLevel;
        end
    end

end
