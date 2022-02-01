classdef MarineMammal
    properties
        name % name of the marine mammal

        centroidFrequency % centroid frequency
        sourceLevel % source level dB re 1uPa @ 1m 
        signalName % signal name (click, whistle, etc..) 
        signal % Signal object  

        rMax % Maximum detection range according to literature 
        livingDepth % Depth where the mammal is supposed to live 
        deltaLivingDepth % Range around livingDepth where the mammal has a high probability to be encountered 

        %TODO: add directionnality later 
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

    end


    methods
        %% Constructor 
        function obj = MarineMammal(sig, rmax, lDepth, deltaLDepth)
            obj = obj.setDefault();
            % Signal  
            if nargin >= 1
                if isa(sig, 'Signal')
                    obj.signal = sig;
                else
                    error('Signal should be an object from class Signal !')
                end
            end

            % rMax
            if nargin >= 2
                obj.rMax = rmax;
            end
            
            % MinFrequency
            if nargin >= 3 
                obj.livingDepth = lDepth;
            end

            % MaxFrequency
            if nargin >= 4
                obj.deltaLivingDepth = deltaLDepth;
            end
        end 
    
        
        function obj = setDefaultSignal(obj)      
            obj.signal = Signal(obj.signalName, obj.centroidFrequency, obj.sourceLevel);
        end

        function updateSignal(obj)
            obj.signal.name = obj.signalName;
            obj.signal.centroidFrequency = obj.centroidFrequency;
            obj.signal.sourceLevel = obj.sourceLevel;
        end

        function obj = setDefault(obj)
            obj.name = 'DefaultMammal';
            obj.centroidFrequency =  obj.centroidFrequencyDefault;
            obj.sourceLevel = obj.sourceLevelDefault;
            obj.rMax = obj.rMaxDefault; 
            obj.livingDepth = obj.livingDepthDefault; 
            obj.deltaLivingDepth = obj.deltaLivingDepthDefault;
        end

        %% Set methods 
        function obj = set.rMax(obj, rmax)
            if rmax < 100
                error('Maximum detection range rMax should be greater than 100m !')
            else 
                obj.rMax = rmax;
            end
        end

%         function obj = set.sourceLevel(obj, sl)
%             %TODO: check sl limits for marine mammals 
%             if sl > 100
%                 error('Maximum detection range rMax should be greater than 100m !')
%             else 
%                 obj.sourceLevel = sl;
%             end
%         end
        %% Get methods 
%         function value = get.PropertyName(obj)
%         end
    end 
    
end
