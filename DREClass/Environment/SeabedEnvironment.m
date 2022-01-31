classdef SeabedEnvironment < handle
    %SEABEDENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sedimentType = 'Mixed sediment';
    end

    properties (Dependent)
        bottom
    end
    
    methods
        function obj = SeabedEnvironment(sedimentType)
            if nargin >= 1; obj.sedimentType = sedimentType; end
        end
    end
         
    methods 
        function bottom = get.bottom(obj)
            % bottom properties with an adapted version of folk 7-class classification from
            % EMODNet
            % (https://www.emodnet-geology.eu/map-viewer/?p=seabed_substrate)
            % The values are taken from the paper 
            % T. Folegot (2017), Modeling Dredging Noise Offshore Dublin, Brief Technical Report, Quiet-Oceans,
            % QO.20170329.01.RAP.001.02A
            
            bottom.ssc = 0.0; % Shear Sound Celerity in bottom half space -> neglected
            bottom.swa = []; % Shear Wave Absorption in bottom half space -> neglected
            switch obj.sedimentType
                case 'Boulders and bedrock'
                    bottom.c = 3820; % m/s
                    bottom.rho = 2.5; % g/cm3
                    bottom.cwa = 0.75; % dB/lambda
                case 'Coarse sediment'
                    bottom.c = 2122; % m/s
                    bottom.rho = 2.37; % g/cm3
                    bottom.cwa = 0.88; % dB/lambda
                case 'Mixed sediment'
                    bottom.c = 1855; % m/s
                    bottom.rho = 2.03; % g/cm3
                    bottom.cwa = 0.89; % dB/lambda
                case 'Muddy sand and sand'
                    bottom.c = 1708; % m/s
                    bottom.rho = 1.53; % g/cm3
                    bottom.cwa = 0.91; % dB/lambda
                case 'Mud and sandy mud'
                    bottom.c = 1517; % m/s
                    bottom.rho = 1.16; % g/cm3
                    bottom.cwa = 0.37; % dB/lambda
            end

        end
    end
end



