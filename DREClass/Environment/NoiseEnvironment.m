classdef NoiseEnvironment
    %NOISEENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        noiseLevel
        computingMethod
    end
    
    methods
        function obj = NoiseEnvironment(cMethod)
            switch cMethod
                case ''
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

