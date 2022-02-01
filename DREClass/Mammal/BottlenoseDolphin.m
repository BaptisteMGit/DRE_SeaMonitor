classdef BottlenoseDolphin < MarineMammal
    properties
    end

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
        function obj = BottlenoseDolphin()
            % Shared properties 
            obj.centroidFrequency = 80 * 1e3; % Centroid frequency in Hz
            obj.sourceLevel = 213; % dB for clicks, Passive Acoustic Monitoring of Cetaceans (Walter M. X. Zimmer)
            % Signal
            obj.signal =  Click(obj.centroidFrequency, obj.sourceLevel, obj.meanICI, obj.peakFrequency);

            obj.rMax = 1500; % TODO: check literature (rMax is inherited from MarineMammal)
            obj.livingDepth = 25;
            obj.deltaLivingDepth = 100;
            obj.name = 'Bottlenose dolphin';
        end 
    end 
end 