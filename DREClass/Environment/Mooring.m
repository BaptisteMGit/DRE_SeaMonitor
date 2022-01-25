classdef Mooring
    
    properties
        mooringName = 'DefaultMooringName';   % Name of the considered mooring
%         mooringPos = [0, 0, 0];   % Position of the mooring [lon0, lat0, hgt0]
        mooringPos % Struct with fields lon, lat, hgt
        hydrophoneDepth = 5; % Depth of the hydrophone (for source position)
        deploymentDate % yyyy-mm-dd hh:mm:ss
    end

    methods 
        function obj = Mooring(moorPos, moorName, hydroDepth, depDate)
            
            % mooringName 
            if nargin >= 1
                obj.mooringName = moorName;
            else
                obj.mooringPos % TODO: check the purpose of this line 
            end

            % mooringPos
            if nargin >= 2
                obj.mooringPos.lon = moorPos.lon;
                obj.mooringPos.lat = moorPos.lat;
                % Hgt is the height of the projection of the mooring point
                % at the surface of the ocean. Thus, as the ocean surface
                % match the geoid, the ellipsoid height given by h = H + N 
                % where N is the geoid height and H is the orthometric 
                % height can be reduced to h = N (H = 0).  
                obj.mooringPos.hgt = geoidheight(moorPos.lat, moorPos.lon);
            end

            % hydrophoneDepth
            if nargin >= 3
                obj.hydrophoneDepth = hydroDepth;
            end
            
            % Deployement date 
            if nargin >= 4
                obj.deploymentDate = depDate;
            else
                obj.deploymentDate.startDate = '2022-01-01 12:00:00';
                obj.deploymentDate.stopDate = '2022-01-01 12:00:00';
            end
        end
    end         
end  