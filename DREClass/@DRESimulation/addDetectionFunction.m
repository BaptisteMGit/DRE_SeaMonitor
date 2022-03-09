function addDetectionFunction(obj, nameProfile)
    cd(obj.rootOutputFiles)

    % Quick fix for CPODs detector (TODO: reshape the behavior of the
    % app) done on 16/02/2022
    if isa(obj.detector , 'CPOD')
        NL = 0; % Noise level have no impact on detection for CPOD
    else
        NL = obj.noiseEnvironment.noiseLevel;
    end

    detFunVar = {'filename',  sprintf('%s.shd', nameProfile),...
        'SL', obj.marineMammal.signal.sourceLevel,...
        'sigmaSL', obj.marineMammal.signal.sigmaSourceLevel,...
        'DT', obj.detector.detectionThreshold,...
        'NL', NL,... 
        'zTarget', obj.marineMammal.livingDepth,...
        'deltaZ', obj.marineMammal.deltaLivingDepth, ...
        'DRThreshold', obj.detectionRangeThreshold, ...
        'offAxisDistribution', obj.offAxisDistribution, ...
        'offAxisAttenuation', obj.offAxisAttenuation, ...
        'sigmaH', obj.sigmaH, ...
        'DI', obj.marineMammal.signal.directivityIndex};

    [detectionFunction, detectionRange] = computeDetectionFunction(detFunVar{:});
%             obj.plotDetectionFunction(nameProfile, detectionFunction, detectionRange)

    i = find(~obj.listDetectionRange, 1, 'first');
    % Detection function            
    obj.listDetectionFunction(i, :) = detectionFunction;
    
    % Detection range 
    obj.listDetectionRange(i) = detectionRange;
    obj.writeDRtoLogFile(obj.listAz(i), detectionRange)

    cd(obj.rootApp)
end