classdef BathyEnvironment  
    properties
        source % 'GEBCO2021' for auto loaded bathy data from GEBCO global model and 'Userfile' for personal bathy data set 
        rootBathy % Path to bathyFile
        bathyFile % Filename of the bathymetric file (coordinates are expected to be geodetic coordinates in the WGS84 CRS) 
        inputCRS = 'WGS84';                 % CRS of the input bathyFile 
        bathyFileType = 'NETCDF';           % File type ('CSV', 'NETCDF')
        drBathy = 100;                      % Horizontal resolution for bathymetric profile 
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
                    obj.rootBathy = '';
                    obj.bathyFile = '';
                    obj.inputCRS = 'WGS84';
                    obj.bathyFileType = 'NETCDF';
                    obj.drBathy = 100;

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
end

