classdef Call < Signal
    properties 
        callPara % TODO: add parameters specific to calls
    end

    methods
        function obj = Call(cFreq, sEnergy, sLength, dIndex, sLevel, cPara)
            obj = obj@Signal(cFreq, sEnergy, sLength, dIndex, sLevel)
            obj.callPara = cPara;
        end
    end
end