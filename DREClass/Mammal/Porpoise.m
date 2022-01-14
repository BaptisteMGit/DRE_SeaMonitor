classdef Porpoise < MarineMammal
    properties
    end

    properties
        % Signal properties 
        centroidFrequency = 130 * 1e3; % Centroid frequency in Hz
        bandWidth = 50 * 1e3; % Bandwidth of the signal 
        
        % Useless for the momment
        signalEnergy  = []; % Signal energy in Ws 
        signalLength = 65 * 1e-6; % Signal length in s
        directivityIndex = 22; % Directivity index in dB 
        sourceLevel = 165; % Source level in dB 
        meanICI = 100; % Inter-click interval in ms
        peakFrequency = 130; % Peak frequency in kHz
    end

    methods
        function obj = Porpoise()
            obj.signal = Click(obj.centroidFrequency, obj.bandWidth, obj.signalEnergy, obj.signalLength,...
                                obj.directivityIndex, obj.sourceLevel, obj.meanICI, obj.peakFrequency);
%             Estimating effective detection area of static passive acoustic 
%             data loggers from playback experiments with cetacean 
%             vocalisations -> he maximum detection distance for the recorded porpoise séquence was 566 m (C-POD 4C) and the mean maximum distance for
%             all the C-PODs was 248 m (95% CI: 181–316).
            obj.rMax = 1000; % Detection distance depend on the environment (especially with modeling), 1000m is taken to be sure 
            obj.name = 'Porpoise';
        end 

        function obj = set.centroidFrequency(obj, f)
            obj.centroidFrequency = f * 1e3; % kHz in Hz 
        end

        function obj = set.bandWidth(obj, BW)
            obj.bandWidth = BW * 1e3; % kHz in Hz 
        end
    end
end