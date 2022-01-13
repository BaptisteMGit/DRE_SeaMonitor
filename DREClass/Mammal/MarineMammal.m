classdef MarineMammal
    properties
        name % name of the marine mammal
        signal % Signal object  
        rMax % Maximum detection range according to literature 
        livingDepth % Depth where the mammal is supposed to live 
        deltaLivingDepth % Range around livingDepth where the mammal has a high probability to be encountered 

%         minFrequency % Minimum emission frequency (Hz) 
%         maxFrequency % Maximum emission frequency (Hz) 
        
        %TODO: add directionnality later 
    end

    properties (Hidden=true)
        %TODO: Check in literature for relevent min and max sl to
        %trigger unconsistent sl values 
        slmin = 10; %dB
        slmax = 200; %dB
    end


    methods
        %% Constructor 
        function obj = MarineMammal(sig, rmax, lDepth, deltaLDepth)
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
