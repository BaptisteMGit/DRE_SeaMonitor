classdef BottlenoseDolphin < MarineMammal
    % Source parameters of echolocation clicks from wild bottlenose
    % dolphins (Tursiops aduncus and Tursiops truncatus)
    % Tursiops truncatus 

    properties 
        % Properties specific to clicks 
        meanICI = 100; % Inter-click interval in ms
        peakFrequency = 100 * 1e3; % Peak frequency in Hz

        % Useless for the momment
%         signalEnergy  = []; % Signal energy in Ws 
%         signalLength = 23 * 1e-6; % Signal length in s
%         directivityIndex =  25; % Directivity index in dB 

    end

    methods
        function obj = BottlenoseDolphin()
            % Shared properties 
            obj.centroidFrequency = 81 * 1e3; % Centroid frequency in Hz

            % To be verified 
            obj.bandwidth = 89 * 1e3; % Soundscape Characterisation and Cetacean Presence in the Porcupine Basin 
            obj.duration = 40 * 1e-6; % (s)

            obj.sourceLevel = 202; % SL (dB re 1 μPa pp at 1 m)
            obj.sigmaSourceLevel = 5; % dB
            obj.directivityIndex = 26; % Directivity index in dB 
            
            % Source parameters of echolocation clicks from wild bottlenose
            % dolphins (Tursiops aduncus and Tursiops truncatus) -> 
            % Tursiops aduncus = 29 dB, Tursiops truncatus = 26 dB

            % Signal
            obj.signal = Click(obj.centroidFrequency, obj.bandwidth, obj.duration, obj.sourceLevel, obj.sigmaSourceLevel, obj.directivityIndex, obj.meanICI, obj.peakFrequency);

            obj.rMax = 1500; % TODO: check literature (rMax is inherited from MarineMammal)
            % TODO: check following values 
            obj.livingDepth = 25;
            obj.deltaLivingDepth = 100;
            obj.name = 'Bottlenose dolphin';
        end 

        function setSignal(obj)
            obj.signal = Click(obj.centroidFrequency, obj.bandwidth, obj.duration, obj.sourceLevel, obj.sigmaSourceLevel, obj.directivityIndex, obj.meanICI, obj.peakFrequency);
        end

    end 
end 