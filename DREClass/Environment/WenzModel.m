classdef WenzModel
    %RECORDING Class to handle the estimation of the ambient noise level
    %using wenz model 
    %   Detailed explanation goes here
    
    properties
        centroidFrequency
        bandwidthType
        bandwidth
        userDesignedBandwidth
    end

    properties (Hidden)
        modelMaxFrequency = 1e5;
        modelMinFrequency = 1;
    end 
    
    methods
        function obj = WenzModel(centroidFrequency, bandwidthType, userDesignedBandwidth)
            obj.centroidFrequency = centroidFrequency;
            obj.bandwidthType = bandwidthType;
            obj.userDesignedBandwidth = userDesignedBandwidth;
        end
      
        function [bool, msg] = checkParametersValidity(obj)
            bool = 1;
            msg = {};
            
            if (obj.bandwidth.max > obj.modelMaxFrequency) || (obj.bandwidth.max < obj.modelMinFrequency)
                bool = 0;
                msg{end+1} = sprintf(['Frequency is out of range for Wenz model.\n', ...
                                        'Wenz model is designed for frequency from %dHz to %dHz'], ...
                                        obj.modelMinFrequency, obj.modelMaxFrequency);
            end
        end

        function noiseLevel = computeNoiseLevel(obj)
%             noiseLevel = wenz()
        end
    end
end

