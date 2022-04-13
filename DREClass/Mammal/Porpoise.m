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

            % Quantifying harbour porpoise foraging behaviour in CPOD data: identification, automatic detection and potential application
            obj.bandwidth = 40 * 1e3; 
            obj.duration = 100 * 1e-6; % (s)

            obj.sourceLevel = 165; % Source level in dB 
            obj.sigmaSourceLevel = 5; % TODO: check this value 
            obj.directivityIndex = 22; % Directivity index in dB 

            % Signal
            obj.signal = Click(obj.centroidFrequency, obj.bandwidth, obj.duration, obj.sourceLevel, obj.sigmaSourceLevel, obj.directivityIndex, obj.meanICI, obj.peakFrequency);

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
            obj.signal = Click(obj.centroidFrequency, obj.bandwidth, obj.duration, obj.sourceLevel, obj.sigmaSourceLevel, obj.directivityIndex, obj.meanICI, obj.peakFrequency);
        end

    end
end