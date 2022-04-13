classdef CommonDolphin < MarineMammal

    properties 
        % Properties specific to clicks 
        meanICI = 100; % Inter-click interval in ms
        peakFrequency = 100 * 1e3; % Peak frequency in Hz

        % Useless for the momment
%         bandWidth = 50 * 1e3; % Bandwidth of the signal 
%         signalEnergy  = []; % Signal energy in Ws 
%         signalLength = 23 * 1e-6; % Signal length in s
%         directivityIndex =  25; % Directivity index in dB 

    end

    methods
        function obj = CommonDolphin()
            % Shared properties 
            obj.centroidFrequency = 80 * 1e3; % Centroid frequency in Hz

            % To be verified 
            obj.bandwidth = 89 * 1e3; % Soundscape Characterisation and Cetacean Presence in the Porcupine Basin 
            obj.duration = 40 * 1e-6; % (s)

            obj.sourceLevel = 213; % dB for clicks, Passive Acoustic Monitoring of Cetaceans (Walter M. X. Zimmer)
            obj.directivityIndex =  25; % Directivity index in dB 

            % Signal
            obj.signal = Click(obj.centroidFrequency, obj.bandwidth, obj.duration, obj.sourceLevel, obj.sigmaSourceLevel, obj.directivityIndex, obj.meanICI, obj.peakFrequency);

            obj.rMax = 1500; % TODO: check literature (rMax is inherited from MarineMammal)
            % TODO: check following values 
            obj.livingDepth = 25;
            obj.deltaLivingDepth = 100;
            obj.name = 'Common dolphin';
        end 

        function setSignal(obj)
            obj.signal = Click(obj.centroidFrequency, obj.bandwidth, obj.duration, obj.sourceLevel, obj.sigmaSourceLevel, obj.directivityIndex, obj.meanICI, obj.peakFrequency);
        end

    end 
end 