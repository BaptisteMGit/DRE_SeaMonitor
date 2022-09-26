classdef SSTC101 < DRESimulation
    %SS101 simulation object to be used for App test 
    %   Test case based on the propagation modelling ran by Sanctsound  
    %   https://sanctsound.portal.axds.co/#sanctsound/sanctuary/channel-islands/site/CI01/method_type/prop-model?grouping_tab=by_frequency

    %   Station : CI01
    %   Latitude : 34.0438°
    %   Longitude : -120.0811°
    %   Month : April
    %   Source level : 176 dB re 1uPa @ 1m
    %   Source depth : 19m (toward bottom)
    %   Source frequency : 12000 Hz
    %   Reported result depth : 17.5 m
    %   Wind induced sound level : 80 dB re 1uPa
    %   Reported listening range : 5371 m


    properties
      StationID = 'CI01';
      Latitude = 34.0438;
      Longitude = -120.0811;
      Month = '04';
      SourceLevel = 176; % dB re 1uPa @ 1m
      SourceDepth = 19 % m (toward bottom)
      SourceFrequency = 12000; % Hz
      ReportedResultDepth = 17.5; % m
      WindInducedSoundLevel = 80; % dB re 1uPa
      ReportedListeningRange = 5371; % m
    end
    
    methods
        function obj = SSTC101
            %% Bathymetry 
            source = 'GEBCO2021'; % Grid used by SanctSound            
            obj.bathyEnvironment = BathyEnvironment(source);

            %% Mooring 
            % Position in WGS84 crs 
            mooringPos.lat = obj.Latitude;
            mooringPos.lon = obj.Longitude;
 
            deploymentDate.startDate = sprintf('2021-%s-01', obj.Month); 
            deploymentDate.stopDate = sprintf('2021-%s-30', obj.Month); 

            mooringName = 'SSTC101';
            hydroDepth = obj.SourceDepth;
            
            obj.mooring = Mooring(mooringPos, mooringName, hydroDepth, deploymentDate);
            
            %% Marine mammal 
            source = Porpoise();
            source.centroidFrequency = obj.SourceFrequency; % frequency in Hz
%             source.rMax = round(obj.ReportedListeningRange * 2, -2); % Listening range * 1.2 rounded to -2 decimals 
            source.rMax = 30 * 10e3;
            source.livingDepth = obj.ReportedResultDepth; % Reported result depth
            source.deltaLivingDepth = 0.5;  % Arbitrary (to discuss)
            source.sourceLevel = obj.SourceLevel;       % 
%             source.sigmaSourceLevel = 2;    % 
            source.directivityIndex = 1;    % Transducer used is assumed to be omnidirectional 
            
            obj.marineMammal = source;
            obj.marineMammal.setSignal(); 
            
            %% Off-axis 
            % Omnidirectional transducer 
            obj.offAxisDistribution = 'Uniformly distributed on a sphere';
            obj.offAxisAttenuation = 'Broadband';

            %% Simulation parameters 
            obj.bellhopEnvironment = BellhopEnvironment;
            % Low quality conf
            obj.bellhopEnvironment.drSimu = 0.005;
            obj.bellhopEnvironment.dzSimu = 0.5;
            obj.bellhopEnvironment.beam.Nbeams = 101;
            obj.listAz = 0.1:36:360.1;
            
            % High quality config 
%             obj.bellhopEnvironment
%             obj.bellhopEnvironment.drSimu = 0.001;
%             obj.bellhopEnvironment.dzSimu = 0.1;
%             obj.bellhopEnvironment.beam.Nbeams = 1001;
%             obj.listAz = 0.1:5:360.1;
            
            %% Detector 
            obj.detector = CPOD();
            
            %% noiseLevel 
            noiseLevel = obj.WindInducedSoundLevel; 
            obj.noiseEnvironment = NoiseEnvironment('Input value', noiseLevel);

            obj.detector.detectionThreshold = 0; % Listening range is defined as the median distance over which predicted received levels were exceeding the wind-induced sound level

            obj.seabedEnvironment = SeabedEnvironment('Muddy sand and sand');

        end

        
    end
end



