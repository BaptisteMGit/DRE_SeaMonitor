classdef FPOD < Detector 
%% FPOD hydrophone
    properties 
    end
    
    methods
        function obj = FPOD()
            obj.name = 'FPOD';
            obj.detectionThreshold = 111.5; % 114.5 - 3  TODO: check
        end
    end
end 