classdef NoiseEnvironment
    %NOISEENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        noiseLevel
        computingMethod
        % The following parameters are needed if the user desire to derive
        % the noise level from data or model
        centroidFrequency
        frequencyBandwidth
    end
    
    methods
        function obj = NoiseEnvironment(cMethod, varargin)

            assert(nargin>=1, 'The computing method must be specified when creating a NoiseEnvironment object.')
            if 
            switch cMethod
                case 'Wenz'
                    assert(numel(varargin) >= 1, 'Centroid frequency missing.')
                    % TODO: call to a function Wenz()
                case 'FromRecording'
                    cond = ((nargin >= 2) & ~isempty(varargin(1)) & (ischar(varargin(1)) | isstring(varargin(1))));
                    assert(cond, 'When trying to measure ambient noise level from a recording a .waw must be provided.')
                    % TODO: call to a function computeNoiseLevel
                case 'ValueInput'
                    cond = (nargin >= 2) & ~isempty(varargin(1)) & isnumeric(varargin(1));
                    assert(cond, 'A numeric value must be used.' )
            end

        end
        
        function obj = Wenz(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

