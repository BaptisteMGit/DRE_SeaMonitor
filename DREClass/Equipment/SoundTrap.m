classdef SoundTrap < Detector
%% SoundTrap hydrophone
    properties 
    end
    
    methods
        function obj = SoundTrap()
            obj.detectionThreshold = 10; 
        end
    end
end