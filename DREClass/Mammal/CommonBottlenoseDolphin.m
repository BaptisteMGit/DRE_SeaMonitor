classdef CommonBottlenoseDolphin < MarineMammal
    properties
    end

    properties 
    end

    methods
        function obj = CommonBottlenoseDolphin()
            obj.sourceLevel = 213; % dB for clicks, Passive Acoustic Monitoring of Cetaceans (Walter M. X. Zimmer)
            obj.rMax = 1500; % TODO: check literature (rMax is inherited from MarineMammal)
        end 
    end 
end 