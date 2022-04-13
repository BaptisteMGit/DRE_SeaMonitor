classdef Call < Signal
    properties 
        callPara % TODO: add parameters specific to calls
    end

    methods
        function obj = Call(cFreq, bWidth, dur, sLevel, ssLevel, dirIndex, callPara)
            obj = obj@Signal('Call', cFreq, bWidth, dur, sLevel, ssLevel, dirIndex)
            if nargin >= 7; obj.callPara = callPara;end
        end
    end
end