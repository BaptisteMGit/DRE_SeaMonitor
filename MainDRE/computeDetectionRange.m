function detectionRange = computeDetectionRange(varargin)
spl = getVararginValue(varargin, 'SPL', []);
zt = getVararginValue(varargin, 'Depth', []);
rt = getVararginValue(varargin, 'Range', []);
nl = getVararginValue(varargin, 'NL', 0);
dt = getVararginValue(varargin, 'DT', 0);
zTarget = getVararginValue(varargin, 'zTarget', []);
deltaZ = getVararginValue(varargin, 'deltaZ', 5);

%% Select the zone of interest (depth interval around the living depth of the animal) 
% TODO: replace by probality law centered on the living depth 
if not (isempty(zTarget) && isempty(zt))
    izToKeep = (zt < zTarget + deltaZ) & (zt > zTarget - deltaZ);
    spl = spl(izToKeep, :);
end

% Median
spl_r = median(spl);
signal = spl_r -  nl;

%% Detection range: last point possible
% First method: get the last range for which spl(r) - nl > dt 

% idetected = signal > dt;
% if ~isempty(idetected)
%     detectedRange = rt(idetected);
%     detectionRange = max(detectedRange);
% else
%     detectionRange = 0;
% end

%% Second approach: first range with spl - nl < dt 
% Second method: get the first range for which spl(r) - nl < dt 
% Skip first meter to avoid artefacts close to the source
idxToKeep = rt > 10;
signal = signal(idxToKeep);
iundetected = signal < dt;
if ~isempty(iundetected)
    if isempty(find(iundetected, 1))
        detectionRange = max(rt);
    else
        undetectedRange = rt(iundetected);
        detectionRange = min(undetectedRange); % Add - drSimu ? ( should not really mater for the estimate precision required) 
    end
else
    detectionRange = 0;
end

end