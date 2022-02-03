classdef Whistle < Signal
    properties 
        whistlePara % TODO: add parameters specific to whistle 
    end

    methods
        function obj = Whistle(cFreq, sLevel, ssLevel, wPara)
            obj = obj@Signal('Whistle', cFreq, sLevel, ssLevel)
            if nargin >= 3; obj.whistlePara = wPara;end
        end
    end
end