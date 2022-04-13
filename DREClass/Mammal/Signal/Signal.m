classdef Signal
    properties 
        name
        centroidFrequency % Centroid emission frequency (Hz) 
        bandwidth % signal bandwidth (freq_max - min_freq) (Hz)
        duration % signal duration 
        sourceLevel % Source level in dB 
        sigmaSourceLevel % Standard deviation of the source level 
        directivityIndex % Directivity index in dB 

        % Useless for the moment 
%         bandWidth % Signal Bandwidth 
%         signalEnergy % Signal energy in Ws 
%         signalLength % Signal length in s
    end

    methods
        function obj = Signal(name, cFreq, bWidth, dur, sLevel, ssLevel, dirIndex)
            % Mandatory parameters 
            obj.name = name; 
            obj.centroidFrequency = cFreq;
            obj.bandwidth = bWidth;
            obj.duration = dur; 
            obj.sourceLevel = sLevel;
            obj.sigmaSourceLevel = ssLevel;
            obj.directivityIndex = dirIndex;

            % Optional parameters 
%             Signal(name, cFreq, sLevel, bWidth, sEnergy, sLength, dIndex)
%             if nargin >= 3; obj.bandWidth = bWidth; end 
%             if nargin >= 4; obj.signalEnergy = sEnergy;end
%             if nargin >= 5; obj.signalLength = sLength;end
%             if nargin >= 6; obj.directivityIndex = dIndex;end            
        end
    end
end