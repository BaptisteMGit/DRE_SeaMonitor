classdef Whistle < Signal
    properties 
        whistlePara % TODO: add parameters specific to whistle 
    end

    methods
        function obj = Whistle(cFreq, sEnergy, sLength, dIndex, sLevel, wPara)
            obj = obj@Signal(cFreq, sEnergy, sLength, dIndex, sLevel)
            obj.whistlePara = wPara;
        end
    end
end