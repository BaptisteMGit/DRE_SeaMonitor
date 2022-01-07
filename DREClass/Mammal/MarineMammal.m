classdef MarineMammal
    properties
        signal % Signal object  
        rMax % Maximum detection range according to literature 

        minFrequency % Minimum emission frequency (Hz) 
        maxFrequency % Maximum emission frequency (Hz) 

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
        function obj = MarineMammal(sig, rmax, minFreq, maxFreq)
            % Signal  
            if nargin >= 1
                if isa(sig, 'Signal')
                    obj.signal = sig;
                else
                    error('Signal should be an object from class Signal !')
                end

                % rMax
                if nargin >= 2
                    obj.rMax = rmax;

                    % MinFrequency
                    if nargin >= 3 
                        obj.minFrequency = minFreq;

                        % MaxFrequency
                        if nargin >= 4
                            obj.maxFrequency = maxFreq;
                        end
                    end
                end
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
