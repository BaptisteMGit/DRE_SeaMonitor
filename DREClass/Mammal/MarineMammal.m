classdef MarineMammal
    properties
        sourceLevel % Source level (According to literature) 
        CentroidFrequency % Centroid emission frequency (Hz) 
        rMax % Maximum detection range according to literature 

        MinFrequency % Minimum emission frequency (Hz) 
        MaxFrequency % Maximum emission frequency (Hz) 

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
        function obj = MarineMammal(sl, cFreq, rmax, minFreq, maxFreq)
            % sourceLevel 
            if nargin >= 1
                if (sl < slmax) && (sl > slmin)
                    obj.sourceLevel = sl;
                else
                    error('sourceLevel should belongs to the interval [%d, %d]dB !', slmin, slmax)
                end

                % CentroidFrequency
                if nargin >= 2
                    obj.CentroidFrequency = cFreq;
                    
                    % rMax
                    if nargin >= 3
                        obj.rMax = rmax;

                        % MinFrequency
                        if nargin >= 4 
                            obj.MinFrequency = minFreq;

                            % MaxFrequency
                            if nargin >= 5
                                obj.MaxFrequency = maxFreq;
                            end
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

        function obj = set.sourceLevel(obj, sl)
            %TODO: check sl limits for marine mammals 
            if sl > 100
                error('Maximum detection range rMax should be greater than 100m !')
            else 
                obj.sourceLevel = sl;
            end
        end
        %% Get methods 
%         function value = get.PropertyName(obj)
%         end
    end 
    
end
