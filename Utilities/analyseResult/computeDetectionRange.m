function detectionRange = computeDetectionRange(g, rt, DRThreshold)
    threshold = str2double(DRThreshold(1:end-1)) / 100;
    y = threshold * ones(size(rt));
    idxSup = (g >= y);
    idxThreshold = find(idxSup, 1, 'last');
    if isempty(idxThreshold)
        detectionRange = 0;
    else
        detectionRange = rt(idxThreshold);
    end
end

