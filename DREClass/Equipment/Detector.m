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

        function [bool, msg] = checkParametersValidity(obj)
            bool = 1; 
            msg = {};
            % Abitrary detectionThreshold limits (TODO: investigate)
            dtMax = 200;
            dtMin = 1; 
            if obj.detectionThreshold > dtMax || obj.detectionThreshold < dtMin
                bool = 0;
                msg{end+1} = sprintf(['Invalid detection threshold. ' ...
                    'Please enter a detection threshold between %ddB and %ddB'], dtMin, dtMax);
            end
        end
    end

end
