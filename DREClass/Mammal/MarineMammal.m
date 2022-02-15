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
