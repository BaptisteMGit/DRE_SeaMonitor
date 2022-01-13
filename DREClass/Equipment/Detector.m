classdef Detector
%% DETECTOR class to handle the different type of detectors 
    properties 
        name % Name of the detector
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
