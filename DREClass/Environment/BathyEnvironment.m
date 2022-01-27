classdef BathyEnvironment < handle
    properties
        source % 'GEBCO2021' for auto loaded bathy data from GEBCO global model and 'Userfile' for personal bathy data set 
        rootBathy % Path to bathyFile
        bathyFile % Filename of the bathymetric file (coordinates are expected to be geodetic coordinates in the WGS84 CRS) 
        inputCRS                  % CRS of the input bathyFile 
        bathyFileType             % File type ('CSV', 'NETCDF')
        drBathy                      % Horizontal resolution for bathymetric profile 
    end

    properties (Hidden)
        % Max and min values for drBathy 
        % TODO: ajust these values to avoid problems 
        drBathyMax = 500;
        drBathyMin = 1;
        
        inputCRSDefault ='WGS84';
        bathyFileTypeDefault = 'NETCDF'; 
        drBathyDefault = 100;
    end

    methods
        function obj = BathyEnvironment(source, root, file, crs, type, dr)
            if nargin >= 1
                obj.source = source;
            else
                obj.source = 'GEBCO2021'; % Default configuration if the object is instanciated without any input property 
            end 

            switch obj.source
                % If automatic process is selected properties are
                % automaticaly defined
                case 'GEBCO2021'
                    obj.setDefaultAuto;

                % If the user whants to use is own file all properties
                % should be properly defined 
                case 'Userfile'
                    % rootBathy 
                    obj.rootBathy = root;
                    % bathyFile 
                    obj.bathyFile = file;
                    % inputCRS
                    obj.inputCRS = crs;
                    % fileType
                    obj.bathyFileType = type;
                    % drBathy
                    obj.drBathy = dr;                                    
            end
        end
    end
    
    methods 

        function setDefaultAuto(obj)
            obj.rootBathy = '';
            obj.bathyFile = '';
            obj.inputCRS = obj.inputCRSDefault;
            obj.bathyFileType = obj.bathyFileTypeDefault;
            obj.drBathy = obj.drBathyDefault;
        end

        function [bool, msg] = checkParametersValidity(obj)
            bool = 1;
            msg = {};
            switch obj.source
                case 'GEBCO2021'
                    % Nothing to do, parameters are allready set to default
                    % values 
                case 'Userfile'
                    if (obj.drBathy > obj.drBathyMax) || (obj.drBathy < obj.drBathyMin)
                        bool = 0;
                        msg{end+1} = sprintf('Bathymetry resolution must be in the range [%d, %d]m.\nResolution has been set to default value 100m', obj.drBathyMin, obj.drBathyMax);
                        obj.drBathy = obj.drBathyDefault;
                    end
            end
        end
    end 

    methods 
        function set.source(obj, src) 
            assert(strcmp(src, 'GEBCO2021') | strcmp(src, 'Userfile'), "Wrong source used, source must be one of the following: 'GEBCO2021', 'Userfile'")
            obj.source = src;
            if strcmp(src, 'GEBCO2021'); obj.setDefaultAuto; end
        end
    end 

end

