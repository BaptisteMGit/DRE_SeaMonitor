classdef BathyEnvironment  
    properties
        rootBathy = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry';
        bathyFile = '2008 HI1240 Runabay Head to Tuns.csv'; % Bathymetric file in WGS84
        inputSRC = 'WGS84';                 % SRC of the input bathyFile 
        drBathy = 100;                      % Horizontal resolution for bathymetric profile 
    end
    methods
        function obj = BathyEnvironment(root, file, src, dr)
           % rootBathy 
            if nargin >= 1
                obj.rootBathy = root;

                % bathyFile
                if nargin >= 2
                    obj.bathyFile = file;
                    
                    % inputSRC
                    if nargin >= 3
                        obj.inputSRC = src;
                        
                        % drBathy
                        if nargin >= 4 
                            obj.drBathy = dr;
                        end
                    end
                end
            end
        end 
    end
end
