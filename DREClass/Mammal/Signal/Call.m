classdef Call < Signal
    properties 
        callPara % TODO: add parameters specific to calls
    end

    methods
        function obj = Call(cFreq, sLevel, callPara)
            obj = obj@Signal('Call', cFreq, sLevel)
            if nargin >= 3; obj.callPara = callPara;end
        end
    end
end