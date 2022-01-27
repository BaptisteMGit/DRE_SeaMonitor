classdef Mooring < handle
    
    properties
        mooringName  % Name of the considered mooring
%         mooringPos = [0, 0, 0];   % Position of the mooring [lon0, lat0, hgt0]
        mooringPos % Struct with fields lon, lat, hgt
        hydrophoneDepth % Depth of the hydrophone (for source position)
        deploymentDate % yyyy-mm-dd hh:mm:ss
    end

    properties (Hidden)
        mooringNameDefault ='SeaMonitor';
        mooringPosDefault = [-6.9, 55.5]; % SeaMonitor position 
        hydrophoneDepthDefault = -10;
        deploymentDateDefault = struct('startDate', '2021-01-01 12:00:00', 'stopDate', '2021-01-10 12:00:00');
    end

    methods 
        function obj = Mooring(moorPos, moorName, hydroDepth, depDate)

            obj.setDefault

            % mooringName 
            if nargin >= 1
                obj.mooringName = moorName;
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
            end
        end
    end    

    methods 

        function setDefault(obj)
            obj.mooringName = obj.mooringNameDefault;
            obj.mooringPos = obj.mooringPosDefault;
            obj.hydrophoneDepth = obj.hydrophoneDepthDefault;
            obj.deploymentDate = obj.deploymentDateDefault;
        end

        function [bool, msg] = checkParametersValidity(obj)
            bool = 1; 
            msg = {};

            d1 = obj.deploymentDate.startDate;
            d2 = obj.deploymentDate.stopDate;
            dStart = datetime(d1);
            dStop = datetime(d2);

            if dStop < dStart
                bool = 0;
                % Swaping dates 
                obj.deploymentDate.startDate = d2;
                obj.deploymentDate.stopDate = d1;
                msg{end+1} = sprintf('Invalid dates, equipment recovery occurs before deployement! Dates have been inverted to avoid further problems.\nStart: %s, Stop: %s', ...
                    obj.deploymentDate.startDate, obj.deploymentDate.stopDate);
            end
        end
    end
end  