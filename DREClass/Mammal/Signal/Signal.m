classdef Signal
    properties 
        name
        centroidFrequency % Centroid emission frequency (Hz) 
        sourceLevel % Source level in dB 
        sigmaSourceLevel % Standard deviation of the source level 
        
        % Useless for the moment 
%         bandWidth % Signal Bandwidth 
%         signalEnergy % Signal energy in Ws 
%         signalLength % Signal length in s
%         directivityIndex % Directivity index in dB 
    end

    methods
        function obj = Signal(name, cFreq, sLevel, ssLevel)
            % Mandatory parameters 
            obj.name = name; 
            obj.centroidFrequency = cFreq;
            obj.sourceLevel = sLevel;
            obj.sigmaSourceLevel = ssLevel;

            % Optional parameters 
%             Signal(name, cFreq, sLevel, bWidth, sEnergy, sLength, dIndex)
%             if nargin >= 3; obj.bandWidth = bWidth; end 
%             if nargin >= 4; obj.signalEnergy = sEnergy;end
%             if nargin >= 5; obj.signalLength = sLength;end
%             if nargin >= 6; obj.directivityIndex = dIndex;end            
        end
    end
end