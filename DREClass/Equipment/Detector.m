classdef Detector
%% DETECTOR class to handle the different type of detectors 
    properties 
        detectionThreshold % Detection threshold used by the detector 
    end
    
    methods
        function obj = Detector(dThreshold)
            obj.detectionThreshold = dThreshold; 
        end
    end

end
