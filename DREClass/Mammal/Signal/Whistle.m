classdef Whistle < Signal
    properties 
        whistlePara % TODO: add parameters specific to whistle 
    end

    methods
        function obj = Whistle(cFreq, bWidth, dur, sLevel, ssLevel, dirIndex, wPara)
            obj = obj@Signal('Whistle', cFreq, bWidth, dur, sLevel, ssLevel, dirIndex)
            if nargin >= 7; obj.whistlePara = wPara;end
        end
    end
end