classdef Mooring
    
    properties
        mooringName = 'DefaultMooringName';   % Name of the considered mooring
        mooringPos = [0, 0, 0];   % Position of the mooring [lon0, lat0, hgt0]
        hydrophoneDepth = 5; % Depth of the hydrophone (for source position)
        deploymentDate % yyyy-mm-dd hh:mm:ss
    end
    
    methods 
        function obj = Mooring(moorPos, moorName, hydroDepth, depDate)
            
            % mooringName 
            if nargin >= 1
                obj.mooringName = moorName;
            end

            % mooringPos
            if nargin >= 2
                obj.mooringPos = moorPos;
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