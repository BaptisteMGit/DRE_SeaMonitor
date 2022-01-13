classdef FPOD < Detector 
%% FPOD hydrophone
    properties 
    end
    
    methods
        function obj = FPOD()
            obj.name = 'FPOD';
            obj.detectionThreshold = 10; 
        end
    end
end 