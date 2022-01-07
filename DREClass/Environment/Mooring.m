classdef Mooring
    properties
        mooringName     % Mooring name considered 
        mooringPos      % Position of the mooring [lon0, lat0, hgt0]
    end
    methods 
        function obj = Mooring(moorPos, moorName)
            % mooringName 
            if nargin >= 1
                obj.mooringName = moorName;
                
                % mooringPos
                if nargin >= 2
                    obj.mooringPos = moorPos;
                end
            end
        end
    end         
end  