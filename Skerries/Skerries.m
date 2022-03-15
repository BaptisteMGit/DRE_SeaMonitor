classdef Skerries < DRESimulation
    %SKERRIES simulation object dedicated to skerries. 
    
    methods
        function obj = Skerries
            % New version 26/01/2022 -> auto loaded bathymetry 
            source = 'GEBCO2021'; % Automatic query of bathy data from GEBCO global grid            
            obj.bathyEnvironment = BathyEnvironment(source);

            %% Mooring 
            % Position in WGS84 crs 
            mooringPos.lat = 52.22;
            mooringPos.lon = -4.37;
            
            % yyyy-mm-dd hh:mm:ss
            deploymentDate.startDate = '2020-07-00'; % 26/04/2012 05:17
            deploymentDate.stopDate = '2012-05-00'; % 04/05/2012 16:18
            

            mooringName = 'TestCase1-ArtificialPorpoise';
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
            porpoise.rMax = 1500;
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
            
            %% Detector 
            obj.detector = CPOD();
            
            %% noiseLevel 
            % Noise level using Wenz model with windSpeed = 3.1; % Sea 
            % state = 2, w = 6knots = 3.1 m.s-1 in the frequency band of
            % interest: 1-Octave band centered on 130kHz  
            noiseLevel = 75; 
            obj.noiseEnvironment = NoiseEnvironment('Input value', noiseLevel);

            obj.listAz = 0.1:5:360.1;
            % According to Methodology and results of calibration of tonal 
            % click detectors for small odontocetes (C-PODs) the detection
            % threshold of C-PODS (derived from linear model) is (based on
            % the tests realised over 86 C-PODS) DT = 114.5 dB re 1uPa
            % peak-peak. As we are considering 0-peak pressures to derive
            % TL with BELLHOP model we need to consider 0-peak detection
            % threshold. To do so we assume that clicks are symetric
            % signals which implies that 0-peak pressure Pp is equal to 1/2
            % * peak-peak presurre Ppp i.e Ppp = 2Pp. Therefore,
            % considering the log10 one can deduce the following relations
            % between 0-peak detection threshold and peak-peak detection
            % threshold: DTpp = DTp + 3 (dB) 
            obj.detector.detectionThreshold = 114.5 - 3; 

            % From ref paper: "The average threshold level over the four positions was then used as the
            % calibration sensitivity, which varied from 111 dB to 119 dB re 1 μPa
            % peak-to-peak (pp) across the C-PODs used in the study."
            % This threshold is divided by to because SPL is derived from
            % BELLHOP output considering 0 to peak pressure. 
            

            obj.seabedEnvironment = SeabedEnvironment('Mud and sandy mud');

        end

        
    end
end


