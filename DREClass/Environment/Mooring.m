classdef Mooring
    properties
        mooringName = 'DefaultMooringName';   % Mooring name considered 
        mooringPos    % Position of the mooring [lon0, lat0, hgt0]
        hydrophoneDepth = 5; % Depth of the hydrophone (for source position)
    end
    methods 
        function obj = Mooring(moorPos, moorName, hydroDepth)
            % mooringName 
            if nargin >= 1
                obj.mooringName = moorName;
                
                % mooringPos
                if nargin >= 2
                    obj.mooringPos = moorPos;

                    % hydrophoneDepth
                    if nargin >= 3
                        obj.hydrophoneDepth = hydroDepth;
                    end
                end
            end
        end
    end         
end  