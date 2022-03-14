classdef SeabedEnvironment < handle
    %SEABEDENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sedimentType = 'Mixed sediment';
        bottom
    end

    methods
        function obj = SeabedEnvironment(sedimentType)
            if nargin >= 1; obj.sedimentType = sedimentType; end
            obj.setBottom()
        end
    end
         
    methods 
        function setBottom(obj)
            % bottom properties with an adapted version of folk 7-class classification from
            % EMODNet
            % (https://www.emodnet-geology.eu/map-viewer/?p=seabed_substrate)
            % The values are taken from the paper 
            % T. Folegot (2017), Modeling Dredging Noise Offshore Dublin, Brief Technical Report, Quiet-Oceans,
            % QO.20170329.01.RAP.001.02A
            
            obj.bottom.ssc = 0.0; % Shear Sound Celerity in bottom half space -> neglected
            obj.bottom.swa = []; % Shear Wave Absorption in bottom half space -> neglected
            switch obj.sedimentType
                case 'Boulders and bedrock'
                    obj.bottom.c = 3820; % m/s
                    obj.bottom.rho = 2.5; % g/cm3
                    obj.bottom.cwa = 0.75; % dB/lambda
                case 'Coarse sediment'
                    obj.bottom.c = 2122; % m/s
                    obj.bottom.rho = 2.37; % g/cm3
                    obj.bottom.cwa = 0.88; % dB/lambda
                case 'Mixed sediment'
                    obj.bottom.c = 1855; % m/s
                    obj.bottom.rho = 2.03; % g/cm3
                    obj.bottom.cwa = 0.89; % dB/lambda
                case 'Muddy sand and sand'
                    obj.bottom.c = 1708; % m/s
                    obj.bottom.rho = 1.53; % g/cm3
                    obj.bottom.cwa = 0.91; % dB/lambda
                case 'Mud and sandy mud'
                    obj.bottom.c = 1517; % m/s
                    obj.bottom.rho = 1.16; % g/cm3
                    obj.bottom.cwa = 0.37; % dB/lambda
                case 'New custom sediment' % Default values for custom sediment 
                    obj.bottom.c =  1700; % m/s
                    obj.bottom.rho = 1.7; % g/cm3 (Mean value according to https://doi.org/10.1155/2014/823296)
                    obj.bottom.cwa =  0.8; % dB/lambda
                otherwise
                    return
            end
        end


        function [bool, msg] = checkParametersValidity(obj)
            bool = 1;
            msg = {};
            % Arbitrary celerity limits (To investigate)
            cMax = 10000; 
            cMin = 1000; 
            if obj.bottom.c < cMin || obj.bottom.c > cMax
                    bool = 0;
                    msg{end+1} = sprintf(['Invalid seabed sound celerity. Sound celerity must belong to the interval [%d, %d]m.s-1. ' ...
                        'Sound celerity has been set to 1700 m.s-1.'], cMin, cMax);
                    obj.bottom.c = 1700;
            end

            % Rho limits 
            % Ref: Assessment of Density Variations of Marine Sediments with Ocean and Sediment Depths
            % https://doi.org/10.1155/2014/823296
            rhoMax = 2.6; % g/cm3
            rhoMin = 0.9; % g/cm3
            if obj.bottom.rho < rhoMin || obj.bottom.rho > rhoMax
                    bool = 0;
                    msg{end+1} = sprintf(['Invalid seabed density. Density must belong to the interval [%.1f, %.1f]g/cm3. ' ...
                        'Density has been set to 1.7 g/cm3.'], rhoMin, rhoMax);
                    obj.bottom.rho = 1.7;
            end

            % Arbitrary cwa limits (To investigate)
            cwaMax = 2; 
            cwaMin = 0.1; 
            if obj.bottom.cwa < cwaMin || obj.bottom.cwa > cwaMax
                    bool = 0;
                    msg{end+1} = sprintf(['Invalid seabed sound celerity. Sound celerity must belong to the interval [%.1f, %.1f]dB/lambda. ' ...
                        'Sound celerity has been set to 1700 m.s-1.'], cwaMin, cwaMax);
                    obj.bottom.cwaMax = 0.8;
            end


        end
    end
end



