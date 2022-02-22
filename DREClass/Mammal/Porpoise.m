classdef Porpoise < MarineMammal

    properties
        % Properties specific to clicks 
        meanICI = 100; % Inter-click interval in ms
        peakFrequency = 130 * 1e3; % Peak frequency in Hz
        
        % Useless for the momment
%         bandWidth = 50 * 1e3; % Bandwidth of the signal 
%         signalEnergy  = []; % Signal energy in Ws 
%         signalLength = 65 * 1e-6; % Signal length in s

    end

    methods
        function obj = Porpoise()
            % Shared properties 
            obj.centroidFrequency = 130 * 1e3; % Centroid frequency in Hz
            obj.sourceLevel = 165; % Source level in dB 
            obj.sigmaSourceLevel = 5; % TODO: check this value 
            obj.directivityIndex = 22; % Directivity index in dB 

            % Signal
            obj.signal = Click(obj.centroidFrequency, obj.sourceLevel, obj.sigmaSourceLevel, obj.meanICI, obj.peakFrequency, obj.directivityIndex);

%             Estimating effective detection area of static passive acoustic 
%             data loggers from playback experiments with cetacean 
%             vocalisations -> the maximum detection distance for the recorded porpoise séquence was 566 m (C-POD 4C) and the mean maximum distance for
%             all the C-PODs was 248 m (95% CI: 181–316).
            obj.rMax = 1500; % Detection distance depend on the environment (especially with modeling), 1500m is taken to be sure 
            % TODO: check following values 
            obj.livingDepth = 50;
            obj.deltaLivingDepth = 100;
            obj.name = 'Porpoise';
        end

        function setSignal(obj)
            obj.signal = Click(obj.centroidFrequency, obj.sourceLevel, obj.sigmaSourceLevel, obj.meanICI, obj.peakFrequency, obj.directivityIndex);
        end

    end
end