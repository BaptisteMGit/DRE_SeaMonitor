classdef CPOD < Detector 
%% CPOD hydrophone
    properties 
    end
    
    methods
        function obj = CPOD()
            obj.name = 'CPOD';
            obj.detectionThreshold = 10; 
        end
    end

end
