function detectionRange = computeDetectionRange(varargin)
spl = getVararginValue(varargin, 'SPL', []);
zt = getVararginValue(varargin, 'Depth', []);
rt = getVararginValue(varargin, 'Range', []);
nl = getVararginValue(varargin, 'NL', 0);
dt = getVararginValue(varargin, 'DT', 0);
zTarget = getVararginValue(varargin, 'zTarget', []);
deltaZ = getVararginValue(varargin, 'deltaZ', 5);

%% Detection range: last point possible
% First method: get the last range for which spl(r) - nl >= dt 

if not (isempty(zTarget) && isempty(zt))
    izToKeep = (zt < zTarget + deltaZ) & (zt > zTarget - deltaZ);
    spl = spl(izToKeep, :);
end


% Median
spl_r = median(spl);

signal = spl_r -  nl;
idetected = signal > dt;
if ~isempty(idetected)
    detectedRange = rt(idetected);
    detectionRange = max(detectedRange);
else
    detectionRange = 0;
end
end