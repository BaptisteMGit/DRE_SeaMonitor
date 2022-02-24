classdef MarineMammal < handle
    properties
        name % name of the marine mammal

        centroidFrequency % centroid frequency
        sourceLevel % On axis average source level dB re 1uPa @ 1m 
        sigmaSourceLevel % Standard deviation of the source level 
        directivityIndex % Directivity index in dB 
        signalName % signal name (click, whistle, etc..) 
        signal % Signal object  

        rMax % Maximum detection range according to literature 
        livingDepth % Depth where the mammal is supposed to live 
        deltaLivingDepth % Range around livingDepth where the mammal has a high probability to be encountered 
    end

    properties (Hidden=true)
        %TODO: Check in literature for relevent min and max sl to
        %trigger unconsistent sl values 
        slmin = 10; %dB
        slmax = 250; %dB

        % Default values 
        centroidFrequencyDefault = 100 * 1e3; % centroid frequency
        sourceLevelDefault = 175;% source level dB re 1uPa @ 1m 
        rMaxDefault = 1500; % Maximum detection range according to literature 
        livingDepthDefault = 10; % Depth where the mammal is supposed to live 
        deltaLivingDepthDefault = 5; % Range around livingDepth where the mammal has a high probability to be encountered 
        sigmaSourceLevelDefault = 5; % Standard deviation of the source level 
        directivityIndexDefault = 25 % Directivity index in dB 

    end


    methods
        %% Constructor 
        function obj = MarineMammal(sig, rmax, lDepth, deltaLDepth)
            obj.setDefault();
            obj.setSignal();

            % Signal  
            if nargin >= 1
                if isa(sig, 'Signal')
                    obj.signal = sig;
                else
                    error('Signal should be an object from class Signal !')
                end
            end

            % rMax
            if nargin >= 2; obj.rMax = rmax; end
            % MinFrequency
            if nargin >= 3; obj.livingDepth = lDepth; end
            % MaxFrequency
            if nargin >= 4; obj.deltaLivingDepth = deltaLDepth; end
        end 
    
        
        function setSignal(obj)
            if isempty(obj.signalName)
                sigName = sprintf('signal_%s', obj.name);
            else
                sigName = obj.signalName;
            end
            obj.signal = Signal(sigName, obj.centroidFrequency, obj.sourceLevel, obj.sigmaSourceLevel, obj.directivityIndex);
        end

        function setDefault(obj)
            obj.name = 'DefaultMammal';
            obj.centroidFrequency =  obj.centroidFrequencyDefault;
            obj.sourceLevel = obj.sourceLevelDefault;
            obj.sigmaSourceLevel = obj.sigmaSourceLevelDefault;
            obj.rMax = obj.rMaxDefault; 
            obj.livingDepth = obj.livingDepthDefault; 
            obj.deltaLivingDepth = obj.deltaLivingDepthDefault;
            obj.directivityIndex = obj.directivityIndexDefault;
        end


        function [bool, msg] = checkParametersValidity(obj)
            bool = 1; 
            msg = {};
            % Abitrary source level limits (TODO: investigate)
            slMax = 250;
            slMin = 10; 
            if obj.sourceLevel > slMax || obj.sourceLevel < slMin
                bool = 0;
                msg{end+1} = sprintf(['Invalid source level. ' ...
                    'Please enter a source level between %ddB and %ddB.'], slMin, slMax);
            end

            % Abitrary sigma source level limits (TODO: investigate)
            sigmaSlMax = 50;
            sigmaSlMin = 0; 
            if obj.sigmaSourceLevel > sigmaSlMax || obj.sigmaSourceLevel < sigmaSlMin
                bool = 0;
                msg{end+1} = sprintf(['Invalid source level standard deviation. ' ...
                    'Please enter a source level standard deviation between %ddB and %ddB.'], sigmaSlMin, sigmaSlMax);
            end

            % Abitrary rMax limits (TODO: investigate)
            rMaxMax = 100000; % 100 km 
            rMaxMin = 100; % 100m 
            if obj.rMax > rMaxMax || obj.rMax < rMaxMin
                bool = 0;
                msg{end+1} = sprintf(['Invalid maximum range. ' ...
                    'Please enter a maximum range between %dm and %dm'], rMaxMin, rMaxMax);
            end

            if obj.livingDepth <= 0 
                bool = 0;
                msg{end+1} = sprintf(['Invalid living depth. ' ...
                    'Living depth must be greater than 0m.']);
            end


            if obj.deltaLivingDepth <= 0 
                bool = 0;
                msg{end+1} = sprintf(['Invalid range around living depth. ' ...
                    'Range must be greater than 0m.']);
            end


            if obj.directivityIndex < 1
                bool = 0;
                msg{end+1} = sprintf(['Invalid directivity index. ' ...
                    'Directivity index must be greater than 1dB'], rMaxMin, rMaxMax);
            end

        end


        %% Set methods 
        function set.rMax(obj, rmax)
            if rmax < 100
                error('Maximum detection range rMax should be greater than 100m !')
            else 
                obj.rMax = rmax;
            end
        end
    end 
    
end
