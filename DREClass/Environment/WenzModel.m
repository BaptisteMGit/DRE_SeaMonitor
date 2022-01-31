classdef WenzModel < handle
    %RECORDING Class to handle the estimation of the ambient noise level
    %using wenz model 
    %   Detailed explanation goes here
    
    properties
        windSpeed % Wind speed in knots 
        trafficIntensity % traffic intensity on a scale from 1 to 7 
        frequencyRange % Bandwidth to integrate  
    end

    properties (Hidden)
        % Default values 
        windSpeedDefault = 10;
        trafficIntensityDefault = 3;

        % Limit of the model 
        modelMaxFrequency = 2e5;
        modelMinFrequency = 1;
    end 
    
    methods
        function obj = WenzModel()
            obj.setDefault()
        end
      
        function [bool, msg] = checkParametersValidity(obj)
            bool = 1;
            msg = {};
            
            if (obj.frequencyRange.max > obj.modelMaxFrequency) || (obj.frequencyRange.max < obj.modelMinFrequency)
                bool = 0;
                msg{end+1} = sprintf(['Frequency is out of range for Wenz model.\n', ...
                                        'Wenz model is designed for frequency from %dHz to %dHz'], ...
                                        obj.modelMinFrequency, obj.modelMaxFrequency);
            end
        end

        function noiseLevel = computeNoiseLevel(obj)
            wenzArgin = {'fMin', obj.frequencyRange.min, 'fMax', obj.frequencyRange.max, ...
                'trafficIntensity', obj.trafficIntensity, 'windSpeed', obj.windSpeed};
            noiseLevel = getNLFromWenzModel(wenzArgin{:});
        end

        function setDefault(obj)
            obj.windSpeed = obj.windSpeedDefault;
            obj.trafficIntensity = obj.trafficIntensityDefault;
        end
    end
end

