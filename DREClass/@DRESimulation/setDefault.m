 function setDefault(obj)
    obj.bathyEnvironment = BathyEnvironment;
    obj.mooring = Mooring;
    obj.marineMammal = Porpoise;
    obj.detector = CPOD; 
    obj.noiseEnvironment = NoiseEnvironment;
    obj.seabedEnvironment = SeabedEnvironment;
    obj.bellhopEnvironment = BellhopEnvironment;
    obj.listAz = 0.1:10:360.1;
    obj.implementedDetectors = {'CPOD', 'FPOD', 'SoundTrap'};
    obj.implementedSources = {'Common dolphin', 'Bottlenose dolphin', 'Porpoise'};
    obj.implementedSediments = {'Boulders and bedrock', 'Coarse sediment', 'Mixed sediment', 'Muddy sand and sand', 'Mud and sandy mud'};
end