classdef WenzModel < handle
    %WENZMODEL Class to handle the estimation of the ambient noise level
    %using wenz model 
    %   Detailed explanation goes here
    
    properties
        windSpeed % Wind speed in m.s-1 
        trafficIntensity % traffic intensity on a scale from 0 to 3 <-> quiet, low, medium, heavy
        oceanEnvironment % Handle pH, T, S, depth
        frequencyRange % Bandwidth to integrate  
    end

    properties (Hidden)
        % Default values 
        windSpeedDefault = 10;
        trafficIntensityDefault = 1;

        % Limit of the model 
        modelMaxFrequency = 2e5;
        modelMinFrequency = 1;
    end 
    
    methods
        function obj = WenzModel(oceanEnv)
            obj.oceanEnvironment = oceanEnv;
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
                'TrafficIntensity', obj.trafficIntensity, 'WindSpeed', obj.windSpeed, ...
                'Temperature', obj.oceanEnvironment.temperatureC, 'Salinity', obj.oceanEnvironment.salinity, ...
                'pH', obj.oceanEnvironment.pH, 'depth', obj.oceanEnvironment.depth};
            noiseLevel = getNLFromWenzModel(wenzArgin{:});
        end

        function setDefault(obj)
            obj.windSpeed = obj.windSpeedDefault;
            obj.trafficIntensity = obj.trafficIntensityDefault;
        end
    end
end

