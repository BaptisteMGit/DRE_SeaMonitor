classdef Recording < handle
    %RECORDING Class to handle the estimation of the ambient noise level
    %from a .wav recording. 
    %   Detailed explanation goes here
    
    properties
        recordingFile % fullpath to the sound file 
        listRecordingFile % List of file to process 
        calibrationCoefficient % Calibration coefficient to convert volt values in the .wav file into micro pascals 
        centroidFrequency % center frequency of interest
        bandwidthType  % '1 octave', '1/3 octave' or 'ManuallyDefined'
        filterOrder % filter order 
        temporalWindow  % width of temporal window used to compute noise level (in s) 
        frequencyRange % for manually defined bandwidth: struct with min and max properties 
    end

    properties (Hidden)
        % Default values 
        bandwidthTypeDefault = '1 octave'; % Clik are large band signals 
        filterOrderDefault = 6; % Default value of the function octaveFilter
        temporalWindowDefault = 60;
        calibrationCoefficientDefault = 173; % TODO: check this value (SoundTrap)  
        
        % Signal to process 
        signal
        filteredSignal
    end 
    
    properties (Dependent)
    end

    methods
        function obj = Recording(centroidFrequency, bandwidthType, listRecordingFile, filterOrder)
            obj.setDefault()

            if nargin >= 1; obj.centroidFrequency = centroidFrequency; end 
            if nargin >= 2; obj.bandwidthType = bandwidthType; end 
            if nargin >= 3; obj.listRecordingFile = listRecordingFile; end 
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
            
            if isempty(obj.listRecordingFile)
                bool = 0;
                msg{end+1} = 'No recording file selected. Please select a valid sound file (.wav).';
            end

            if isempty(obj.calibrationCoefficient)
                bool = 0;
                msg{end+1} = 'No calibration coefficient. Please enter a valid calibration coefficient.';
            end
            
            if ~isempty(obj.listRecordingFile)
                [~, fs] = audioread(obj.listRecordingFile{1}, [1:2]);
                fNyquist = fs/2;
                if obj.frequencyRange.max >= fNyquist
                    bool = 0;
                    msg{end+1} = sprintf('Frequency band upper bound exceeds Nyquist frequency %.2fHz for the selected file. Please select another sound file or change frequency band.', fNyquist) ;
                end
            end
        end

        function noiseLevel = computeNoiseLevel(obj, d)
            figure
            p1 = scatter(nan, nan, 20, 'r', 'filled');
%             listNL = int32.empty([numel(obj.listRecordingFile), 0]);
            listNL = [];
            for j = 1:numel(obj.listRecordingFile)
                obj.recordingFile = obj.listRecordingFile{j};
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
                    d.Message = sprintf('Processing recording n°%d/%d from %.2f s to %.2f s ...', j, numel(obj.listRecordingFile), ...
                                    starting_sample / info.SampleRate, ending_sample / info.SampleRate);
                    
                    samplesRange = [starting_sample, ending_sample];
                    obj.signal = obj.loadSignal(samplesRange);

                    % Using equivalent continuous sound pressure 
                    listLeq(i) = getNLFromWavFile_Lrms(obj.filteredSignal, obj.calibrationCoefficient);
                    % Using spectral power density 
%                     listLeq(i) = getNLFromWavFile_Power(obj.filteredSignal, obj.calibrationCoefficient);

                    % Next window sample 
                    starting_sample = starting_sample + obj.temporalWindow * info.SampleRate;
                    ending_sample = min(ending_sample + obj.temporalWindow * info.SampleRate, info.TotalSamples);
                end
                
                hold on
                T = [1:n] + n*(j-1);
                scatter(T, listLeq, 20, 'k', 'filled')
                scatter(T(1), listLeq(1), 20, 'r', 'filled')
                drawnow
                listNL = [listNL listLeq];

            end
            % Get rid off outlayers with 95% confidence level to get rid of
            % electrical noises (at the begining of each sound file)
            muNL = mean(double(listNL));
            sigmaNL = std(double(listNL));
            yline(muNL, '--b', 'label', '\mu')
            yline(muNL + 2*sigmaNL, '--b', 'label', '\mu + 2*\sigma')
            yline(muNL - 2*sigmaNL, '--b', 'label', '\mu - 2*\sigma')
            idxOutlayers = (listNL >= muNL + 2*sigmaNL) | (listNL <= muNL - 2*sigmaNL);
            listNL = listNL(~idxOutlayers);

            noiseLevel = double(median(listNL));

            hold on 
            yline(noiseLevel, '--r', sprintf('Ambient noise level computed = %d dB', noiseLevel), 'LabelVerticalAlignment', 'bottom')
            ylabel('SPL_{rms} [dB re 1\muPa]')
            xlabel('Time [minute]')
            legend(p1, sprintf('SPL for first %.fs of each .wav file', obj.temporalWindow), 'Location', 'southeast');
            title({sprintf('SPL_{rms} (%.fs windows) derived from  %d .wav recordings', obj.temporalWindow, numel(obj.listRecordingFile)),...
                sprintf('Frequency band: %.fHz - %.fHz', obj.frequencyRange.min, obj.frequencyRange.max)})
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

