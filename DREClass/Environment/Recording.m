classdef Recording < handle
    %RECORDING Class to handle the estimation of the ambient noise level
    %from a .wav recording. 
    %   Detailed explanation goes here
    
    properties
        recordingFile % fullpath to the sound file 
        calibrationCoefficient % Calibration coefficient to convert volt values in the .wav file into micro pascals 
        centroidFrequency % center frequency of interest
        bandwidthType  % '1 octave', '1/3 octave' or 'ManuallyDefined'
        filterOrder % filter order 
        temporalWindow  % width of temporal window used to compute noise level (in s) 
        frequencyRange % for manually defined bandwidth: struct with min and max properties 
    end

    properties (Hidden)
        bandwidthTypeDefault = '1 octave'; % Clik are large band signals 
        filterOrderDefault = 6; % Default value of the function octaveFilter
        temporalWindowDefault = 60;
            calibrationCoefficientDefault = 173; 
            signal
        filteredSignal
    end 
    
    properties (Dependent)
    end

    methods
        function obj = Recording(centroidFrequency, bandwidthType, recordingFile, filterOrder)
            obj.setDefault()

            if nargin >= 1; obj.centroidFrequency = centroidFrequency; end 
            if nargin >= 2; obj.bandwidthType = bandwidthType; end 
            if nargin >= 3; obj.recordingFile = recordingFile; end 
            if nargin >= 4; obj.filterOrder = filterOrder; end 
        end
        

        function setDefault(obj)
            obj.recordingFile = '';
            obj.bandwidthType = obj.bandwidthTypeDefault;
            obj.filterOrder = obj.filterOrderDefault;
            obj.temporalWindow = obj.temporalWindowDefault; 
            obj.calibrationCoefficient = obj.calibrationCoefficientDefault;
        end

        function [bool, msg] = checkParametersValidity(obj)
            bool = 1;
            msg = {};
            
            if isempty(obj.recordingFile)
                bool = 0;
                msg{end+1} = 'No recording file selected. Please select a valid sound file (.wav).';
            end

            if isempty(obj.calibrationCoefficient)
                bool = 0;
                msg{end+1} = 'No calibration coefficient. Please enter a valid calibration coefficient.';
            end


        end

        function noiseLevel = computeNoiseLevel(obj, d)
            % Continuous equivalent level (RMS over temporalWindow s) 
            info = audioinfo(obj.recordingFile);
            
            deltaSample = obj.temporalWindow * info.SampleRate;
            starting_sample = 1;
            ending_sample = 1 + deltaSample;

            n = floor(info.TotalSamples / (obj.temporalWindow * info.SampleRate));
            listLeq = int32.empty([n, 0]);

            % Loop through the sound file 
            for i=1:n 
                % Update process bar 
                d.Value = i/n;
                d.Message = sprintf('Processing recording from %.2f s to %.2f s ...', starting_sample / info.SampleRate, ending_sample / info.SampleRate);
                
                samplesRange = [starting_sample, ending_sample];
                obj.signal = obj.loadSignal(samplesRange);
                listLeq(i) = getNLFromWavFile_Leq(obj.filteredSignal, obj.calibrationCoefficient);
                
                % Next window sample 
                starting_sample = starting_sample + obj.temporalWindow * info.SampleRate;
                ending_sample = ending_sample + obj.temporalWindow * info.SampleRate;
            end
            noiseLevel = mean(listLeq);
            noiseLevel = round(noiseLevel, 0);

            % Spectral power 
%             noiseLevel = getNLFromWavFile_Power(obj.filteredSignal, obj.calibrationCoefficient, obj.temporalWindow);
        end

        function signal = loadSignal(obj, samplesRange)
            [y, fs] = audioread(obj.recordingFile, samplesRange);
            signal = struct('y', y, 'fs', fs);
        end

        function filteredSignal = get.filteredSignal(obj) 
            switch obj.bandwidthType
                case 'ManuallyDefined'
                    % Butterworth filter 
                    fcutlow = obj.frequencyRange.min / (obj.signal.fs/2);
                    fcuthigh = obj.frequencyRange.max / (obj.signal.fs/2);
                    [b,a]    = butter(obj.filterOrder, [fcutlow,fcuthigh], 'bandpass');
                    filteredSignal.y = filter(b, a, obj.signal.y);
                otherwise
                    % octaveFilter
                    ofilter = octaveFilter('FilterOrder', obj.filterOrder, 'CenterFrequency', obj.centroidFrequency,  ...
                          'Bandwidth', obj.bandwidthType, 'SampleRate', obj.signal.fs);
                    filteredSignal.y = ofilter(obj.signal.y);
            end
            filteredSignal.fs = obj.signal.fs;
        end
     
    end
end

