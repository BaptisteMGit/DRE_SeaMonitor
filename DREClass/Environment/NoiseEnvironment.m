classdef NoiseEnvironment < handle
    %NOISEENVIRONMENT Class to handle the ambient noise properties. 
    %   Baptiste MENETRIER. 
    
    properties
        
        computingMethod
        noiseLevel
        % The following parameters are needed if the user desire to derive
        % the noise level from data or model
        
        % From Wenz model 
        wenzModel % Object to handle wenz model properties 
        % From data 
        recording % Object to handle recording and estimation properties 
    end
    
    methods
        function obj = NoiseEnvironment(computingMethod, varargin)
            obj.setDefault()

            if nargin >= 1; obj.computingMethod = computingMethod; end
            if nargin >= 2 && strcmp(obj.computingMethod, 'Input value')
                assert(isnumeric(varargin{1}), 'Value is not numeric. When directly trying to set a ambient noise level the value must be a numeric value (in dB).')
                obj.noiseLevel = varargin{1};
            end
        end
    end 
    
    methods 

        function setDefault(obj)
            obj.noiseLevel = 40;
            obj.computingMethod = 'Input value';
        end

        function computeNoiseLevel(obj, d)
            switch obj.computingMethod
                case 'Derived from Wenz model'
                    obj.noiseLevel = obj.wenzModel.computeNoiseLevel();
                case 'Derived from recording'
                    cond = (~isempty(obj.recording) & ~isempty(obj.recording.recordingFile) & (ischar(obj.recording.recordingFile) | isstring(obj.recording.recordingFile)));
                    assert(cond, 'When trying to measure ambient noise level from a recording a .waw must be provided.')
                    obj.noiseLevel = obj.recording.computeNoiseLevel(d);
            end
        end
    end
end

