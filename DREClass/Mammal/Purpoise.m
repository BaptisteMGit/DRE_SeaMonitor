classdef Purpoise < MarineMammal
    properties
    end

    methods
        function obj = Purpoise()
            obj.sourceLevel = 173; % dB for clicks, Passive Acoustic Monitoring of Cetaceans (Walter M. X. Zimmer)
            obj.rMax = 1500; % TODO: check literature
        end 
    end
end