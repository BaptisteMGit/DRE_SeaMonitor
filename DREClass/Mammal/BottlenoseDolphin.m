classdef BottlenoseDolphin < MarineMammal
    % Source parameters of echolocation clicks from wild bottlenose
    % dolphins (Tursiops aduncus and Tursiops truncatus)
    % Tursiops truncatus 

    properties 
        % Properties specific to clicks 
        meanICI = 100; % Inter-click interval in ms
        peakFrequency = 100 * 1e3; % Peak frequency in Hz
        bandWidth = 28.5 * 1e3; % Bandwidth of the signal 

        % Useless for the momment
%         signalEnergy  = []; % Signal energy in Ws 
%         signalLength = 23 * 1e-6; % Signal length in s
%         directivityIndex =  25; % Directivity index in dB 

    end

    methods
        function obj = BottlenoseDolphin()
            % Shared properties 
            obj.centroidFrequency = 81 * 1e3; % Centroid frequency in Hz
            obj.sourceLevel = 202; % SL (dB re 1 μPa pp at 1 m)
            obj.sigmaSourceLevel = 5; % dB
            obj.directivityIndex = 26; % Directivity index in dB 
            
            % Source parameters of echolocation clicks from wild bottlenose
            % dolphins (Tursiops aduncus and Tursiops truncatus) -> 
            % Tursiops aduncus = 29 dB, Tursiops truncatus = 26 dB

            % Signal
            obj.signal =  Click(obj.centroidFrequency, obj.sourceLevel, obj.sigmaSourceLevel, obj.meanICI, obj.peakFrequency, obj.directivityIndex);

            obj.rMax = 1500; % TODO: check literature (rMax is inherited from MarineMammal)
            % TODO: check following values 
            obj.livingDepth = 25;
            obj.deltaLivingDepth = 100;
            obj.name = 'Bottlenose dolphin';
        end 
    end 
end 