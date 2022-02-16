classdef CPOD < Detector 
%% CPOD hydrophone
    properties 
    end
    
    methods
        function obj = CPOD()
            obj.name = 'CPOD';
            obj.detectionThreshold = 111.5; % 114.5 - 3  
        end
    end

end
