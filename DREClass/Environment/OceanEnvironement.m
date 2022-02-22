classdef OceanEnvironement < handle 

    properties 
        temperatureC
        salinity 
        pH 
        depth
    end 

    %% Constructor 
    methods
        function obj = OceanEnvironement(mooring, rootSaveInput, bBox, tBox, dBox) % Mooring is passed to the OceanEnvironment class to compute the paremeters for the given mooring site 

            [T, S, D] = getTS(mooring, rootSaveInput, bBox, tBox, dBox);
            obj.temperatureC = reshape(T, [numel(D), 1]);
            obj.salinity = reshape(S, [numel(D), 1]);
            obj.depth = D;

            pH = getPH(mooring, rootSaveInput, bBox, tBox, dBox);
            pH = repelem(pH, numel(D));
            pH = reshape(pH, [numel(D), 1]);
            obj.pH = pH;
        end
    end

end 