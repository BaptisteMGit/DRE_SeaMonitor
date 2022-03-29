function addDetectionRange(obj, nameProfile)
    cd(obj.rootOutputFiles)

    varSpl = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};
    [obj.spl, obj.zt, obj.rt] = computeSPL(varSpl{:});
    
    computeArgin = {'SPL', obj.spl, 'Depth', obj.zt, 'Range', obj.rt, 'NL', obj.noiseEnvironment.noiseLevel,...
        'DT', obj.detector.detectionThreshold, 'zTarget', obj.marineMammal.livingDepth, 'deltaZ', obj.marineMammal.deltaLivingDepth};
    detectionRange = computeDetectionRange_old(computeArgin{:});

    i = find(~obj.listDetectionRange, 1, 'first');
    obj.listDetectionRange(i) = detectionRange;
    obj.writeDRtoLogFile(obj.listAz(i), detectionRange)

    cd(obj.rootApp)
end
