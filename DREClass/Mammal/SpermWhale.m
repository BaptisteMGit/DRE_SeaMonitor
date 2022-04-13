classdef SpermWhale < MarineMammal
%     Ref: 
% Frouin-Mouy, H., S. Hipsey, S. Denes, and R. Burns. 2017. Soundscape Characterisation and 
% Cetacean Presence in the Porcupine Basin: June to November 2016. Document 01320, Version 1.0.
% Technical report by JASCO Applied Sciences for Woodside Energy (Ireland) Pty Ltd.


    properties
        % Properties specific to clicks 
        meanICI = 100; % Inter-click interval in ms        
    
        % Useless for the momment
%         bandWidth = 50 * 1e3; % Bandwidth of the signal 
%         signalEnergy  = []; % Signal energy in Ws 
%         signalLength = 65 * 1e-6; % Signal length in s

    end

    methods
        function obj = SpermWhale()
            % Shared properties 
            obj.centroidFrequency = 15 * 1e3; % Centroid frequency (Hz)

            % Soundscape Characterisation and Cetacean Presence in the Porcupine Basin 
            obj.bandwidth = 19 * 1e3; % Bandwidth (Hz) 
            obj.duration = 0.0001; % (s)

            obj.sourceLevel = 232; % Source level in dB 
            obj.sigmaSourceLevel = 5; % TODO: check this value 
            obj.directivityIndex = 27; % Directivity index in dB 

            obj.rMax = 15000; % Detection distance depend on the environment (especially with modeling), 1500m is taken to be sure 
            obj.livingDepth = 1800;
            obj.deltaLivingDepth = 1000;
            obj.name = 'SpermWhale';

            % Signal
            obj.signal = Click(obj.centroidFrequency, obj.bandwidth, obj.duration, obj.sourceLevel, obj.sigmaSourceLevel, obj.directivityIndex, obj.meanICI);
        end

        function setSignal(obj)
            obj.signal = Click(obj.centroidFrequency, obj.bandwidth, obj.duration, obj.sourceLevel, obj.sigmaSourceLevel, obj.directivityIndex, obj.meanICI);
        end

    end
end