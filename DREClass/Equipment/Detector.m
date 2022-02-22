classdef Detector < handle
%% DETECTOR class to handle the different type of detectors 
    properties 
        name % Name of the detector
        detectionThreshold % Detection threshold used by the detector 
    end
    
    methods
        function obj = Detector(dThreshold)
            obj.setDefault();

            if nargin >= 1
                obj.detectionThreshold = dThreshold; 
            end
        end


        function setDefault(obj)
            obj.name = 'DefaultDetector';
            obj.detectionThreshold = 110; 
        end
    end

end
