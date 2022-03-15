classdef devQuickConfig < DRESimulation
    %DEVQUICKCONFIG Dev config to realise quick test 
    %   Minimal parameters are set to minimize CPU time 
    
    methods
        function obj = devQuickConfig
            %% Bathymetry 
            source = 'GEBCO2021'; % Automatic query of bathy data from GEBCO global grid            
            obj.bathyEnvironment = BathyEnvironment(source);

            %% Mooring 
            % Position in WGS84 crs 
            mooringPos.lat = 52.22;
            mooringPos.lon = -4.37;
            
            % yyyy-mm-dd hh:mm:ss
            deploymentDate.startDate = '2022-02-01'; % 26/04/2012 05:17
            deploymentDate.stopDate = '2022-03-01'; % 04/05/2012 16:18
            
            mooringName = 'devQuickConfig';
            hydroDepth = -1.5; % Negative hydroDepth = depth reference to the seafloor 
            % -> hydrophone 1.5 meter over the seafloor 
            
            obj.mooring = Mooring(mooringPos, mooringName, hydroDepth, deploymentDate);
            
            %% Marine mammal 
            porpoise = Porpoise();
            porpoise.centroidFrequency = 130 * 1e3; % frequency in Hz
            porpoise.sourceLevel = 176; % Maximum source level used (artificial porpoise-like signals)
            porpoise.sigmaSourceLevel = 1; % We assumed the tranducer to be correctly calibrated and to show a little dispersion around the desired value.  
            porpoise.livingDepth = 2; % Depth of the emmiting transducer used 
            porpoise.deltaLivingDepth = 1; % Arbitrary (to discuss)
            porpoise.rMax = 700;
            porpoise.directivityIndex  = 1;  % Transducer used is assumed to be omnidirectional 
            
            obj.marineMammal = porpoise;
            obj.marineMammal.setSignal(); 
            
            %% Off-axis 
            % Omnidirectional transducer 
            obj.offAxisDistribution = 'Uniformly distributed on a sphere';
            obj.offAxisAttenuation = 'Broadband';

            %% Simulation parameters 
            obj.bellhopEnvironment = BellhopEnvironment;
            obj.bellhopEnvironment.drSimu = 0.001;
            obj.bellhopEnvironment.dzSimu = 0.1;
            obj.bellhopEnvironment.beam.Nbeams = 101; 
            
            %% Detector 
            obj.detector = CPOD();
            
            %% noiseLevel 
            noiseLevel = 75; 
            obj.noiseEnvironment = NoiseEnvironment('Input value', noiseLevel);

            obj.listAz = 0.1:72:360.1;
            obj.detector.detectionThreshold = 114.5 - 3; 
            obj.seabedEnvironment = SeabedEnvironment('Mud and sandy mud');

        end

        
    end
end


