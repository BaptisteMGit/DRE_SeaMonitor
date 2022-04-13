classdef OceanEnvironement < handle 

    properties 
        temperatureC
        salinity 
        pH 
        depth
    end 

    properties (Hidden)
        dBox 
        connectionFailed = 0;

        % TODO: check these values -> ocean mean values 
        defaultTemperatureC = 10;
        defaultSalinity = 35;
        defaultpH = 8;
    end

    %% Constructor 
    methods
        function obj = OceanEnvironement(mooring, rootSaveInput, bBox, tBox, dBox) % Mooring is passed to the OceanEnvironment class to compute the paremeters for the given mooring site 
            obj.dBox = dBox;
            try 
                [T, S, D] = getTS(mooring, rootSaveInput, bBox, tBox, dBox);
                sz = size(D);
                obj.temperatureC = reshape(T, sz);
                obj.salinity = reshape(S, sz);
                obj.depth = D;
    
                pH = getPH(mooring, rootSaveInput, bBox, tBox, dBox);
                pH = repelem(pH, numel(D));
                pH = reshape(pH, sz);
                obj.pH = pH;

                % Fix for NaN values 
                % Temperature 
                idxNaN = isnan(obj.temperatureC);
                lastNotNaN = find(~idxNaN, 1, 'last');
                obj.temperatureC(idxNaN) = obj.temperatureC(lastNotNaN);
                % Salinity 
                idxNaN = isnan(obj.salinity);
                lastNotNaN = find(~idxNaN, 1, 'last');
                obj.salinity(idxNaN) = obj.salinity(lastNotNaN);
                % pH 
                idxNaN = isnan(obj.pH);
                lastNotNaN = find(~idxNaN, 1, 'last');
                obj.pH(idxNaN) = obj.pH(lastNotNaN);
                
            catch 
                obj.connectionFailed = 1;
            end 
        end

        function setOfflineDefaultConfig(obj)
            % Properties used when using the app offline 
            % Set depth vector
            dz  = 5; 
            obj.depth = obj.dBox.min:dz:obj.dBox.max;
            obj.depth = obj.depth';
            n = numel(obj.depth);
            sz = size(obj.depth);
            
            obj.temperatureC = repelem(obj.defaultTemperatureC, n);
            obj.temperatureC = reshape(obj.temperatureC, sz);
            obj.salinity = repelem(obj.defaultSalinity, n);
            obj.salinity = reshape(obj.salinity, sz);
            obj.pH = repelem(obj.defaultpH, n);
            obj.pH = reshape(obj.pH, sz);
        end

    end

end 