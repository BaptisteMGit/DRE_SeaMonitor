classdef NoiseEnvironment < handle
    %NOISEENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        noiseLevel
        computingMethod
        % The following parameters are needed if the user desire to derive
        % the noise level from data or model
        
        % From data 
        recordingFile = '';
        bandwidthStyle = '1/3 Octave band';
        frequencyBandwidth = struct('min', 130000, 'max', 80000)

        % From both (data or model) 
        centroidFrequency = 100000;

    end
    
    methods
        function obj = NoiseEnvironment(cMethod, varargin)

            assert(nargin>=1, 'The computing method must be specified when creating a NoiseEnvironment object.')
%             if 
            switch cMethod
                case 'Wenz'
                    assert(numel(varargin) >= 1, 'Centroid frequency missing.')
                    % TODO: call to a function Wenz()
                case 'FromRecording'
                    cond = ((nargin >= 2) & ~isempty(varargin{1}) & (ischar(varargin{1}) | isstring(varargin{1})));
                    assert(cond, 'When trying to measure ambient noise level from a recording a .waw must be provided.')
                    % TODO: call to a function computeNoiseLevel
                case 'ValueInput'
                    cond = (nargin >= 2) & ~isempty(varargin{1}) & isnumeric(varargin{1});
                    assert(cond, 'A numeric value must be used.' )
            end

        end
    end 

    methods 
        function Wenz(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end

        function computeFromRecording(obj)
            % TODO: add method to compute nl using freq and BW and file 
        end


        function [bool, msg] = checkParametersValidity(obj)
            bool = 1;
            msg = {};
            
            if isempty(obj.recordingFile)
                bool = 0;
                msg{end+1} = 'No recording file selected. Please select a valid sound file (.wav).';

            end
        end
    end
end

