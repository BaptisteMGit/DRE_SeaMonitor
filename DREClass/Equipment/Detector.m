classdef Detector
%% DETECTOR class to handle the different type of detectors 
    properties 
        detectionThreshold % Detection threshold used by the detector 
    end
    
    methods
        function obj = Detector(dThreshold)
            if nargin >= 1
                obj.detectionThreshold = dThreshold; 
            end
        end
    end

end
