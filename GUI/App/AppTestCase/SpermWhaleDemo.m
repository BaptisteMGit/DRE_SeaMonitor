classdef SpermWhaleDemo < DRESimulation
    % Sperm whale demo for illustration purposes

    properties
    end
    
    methods
        function obj = SpermWhaleDemo
            %% Bathymetry 
            source = 'GEBCO2021'; % Automatic query of bathy data from GEBCO global grid            
            obj.bathyEnvironment = BathyEnvironment(source);

            %% Mooring 
            mooringPos.lat = 54;
            mooringPos.lon = -14;
                       
            % Temporary before Copernicus reply 
            deploymentDate.startDate = '2022-03-01'; % 26/04/2012 07:23 
            deploymentDate.stopDate = '2022-04-01'; % 04/05/2012 16:57

            mooringName = 'SpermWhale_ShelfEdge';
            hydroDepth = -12; % Negative hydroDepth = depth reference to the seafloor 
            
            obj.mooring = Mooring(mooringPos, mooringName, hydroDepth, deploymentDate);
            
            %% Marine mammal 
            obj.marineMammal = SpermWhale;

            %% Off-axis 
            % Directional transducer 
            obj.offAxisDistribution = 'Uniformly distributed on a sphere';
            obj.offAxisAttenuation = 'Narrowband';

            %% Simulation parameters 
            obj.bellhopEnvironment = BellhopEnvironment;
            obj.bellhopEnvironment.drSimu = 0.001;
            obj.bellhopEnvironment.dzSimu = 0.1;
            obj.bellhopEnvironment.beam.Nbeams = 201;
            
            %% Detector     
            obj.detector = CPOD();
            
            %% noiseLevel 
            noiseLevel = 75; 
            obj.noiseEnvironment = NoiseEnvironment('Input value', noiseLevel);

            obj.listAz = 0.1:5:360.1;
            obj.detector.detectionThreshold = 114 - 3;
          
            obj.seabedEnvironment = SeabedEnvironment('Mud and sandy mud');

        end

        
    end
end

