classdef SoundTrap < Detector
%% SoundTrap hydrophone
    properties 
    end
    
    methods
        function obj = SoundTrap()
            obj.name = 'SoundTrap';
            obj.detectionThreshold =  111.5; % 114.5 - 3  TODO: check
        end
    end
end