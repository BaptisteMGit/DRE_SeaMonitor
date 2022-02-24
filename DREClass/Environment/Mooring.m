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
        mooringPosDefault = struct('lon', -6.9, 'lat', 55.5); % SeaMonitor position 
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
                % Hgt is the ellipsoid height of the projection of the mooring point
                % at the surface of the ocean. Thus, as the ocean surface
                % match the geoid, the ellipsoid height given by h = H + N 
                % where N is the geoid height and H is the orthometric height 
                % Ellipsoid height can be reduced to h = N (H = 0).  
%                 [lon_wrapped, moorPos.lon] = wraplongitude(moorPos.lon,'deg','360'); % Wrap before calling the geoidheight function to avoir warning in the app
                warning off all
                obj.mooringPos.hgt = geoidheight(moorPos.lat, moorPos.lon);
                warning on all

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

            % Check lat 
            if obj.mooringPos.lat < -90 || obj.mooringPos.lat > 90
                bool = 0;
                msg{end+1} = ['Invalid latitude. ' ...
                    'Please enter a latitude between -90° and 90°.'];
            end

            % Check lat 
            if obj.mooringPos.lon < -180 || obj.mooringPos.lon > 180
                bool = 0;
                msg{end+1} = ['Invalid longitude. ' ...
                    'Please enter a longitude between -180° and 180°.'];
            end
            

        end
    end
end  