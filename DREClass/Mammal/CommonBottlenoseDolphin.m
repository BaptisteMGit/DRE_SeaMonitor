classdef CommonBottlenoseDolphin < MarineMammal
    properties
    end

    properties 
        centroidFrequency = 80 * 1e3; % Centroid frequency in Hz
        signalEnergy  = []; % Signal energy in Ws 
        signalLength = 23 * 1e-6; % Signal length in s
        directivityIndex =  25; % Directivity index in dB 
        sourceLevel = 213; % dB for clicks, Passive Acoustic Monitoring of Cetaceans (Walter M. X. Zimmer)
        meanICI = 100; % Inter-click interval in ms
        peakFrequency = 100; % Peak frequency in kHz
    end

    methods
        function obj = CommonBottlenoseDolphin()
            obj.signal = Click(obj.centroidFrequency, obj.signalEnergy, obj.signalLength,...
                obj.directivityIndex, obj.sourceLevel, obj.meanICI, obj.peakFrequency);
            obj.rMax = 1500; % TODO: check literature (rMax is inherited from MarineMammal)
            obj.livingDepth = 25;
            obj.deltaLivingDepth = 100;
            obj.name = 'Common bottlenose dolphin';
        end 
    end 
end 