function plotSE1D(obj, nameProfile)
    cd(obj.rootOutputFiles)
    % SE
    varSpl = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};
    [obj.spl, ~, ~] = computeSPL(varSpl{:});

    SEArgin = {'SPL', obj.spl, 'Depth', obj.zt, 'Range', obj.rt, 'NL', obj.noiseEnvironment.noiseLevel,...
        'DT', obj.detector.detectionThreshold, 'zTarget', obj.marineMammal.livingDepth, 'deltaZ', obj.marineMammal.deltaLivingDepth};
    plotSE(SEArgin{:});
    title(sprintf('Signal excess - %s', nameProfile), 'SE = SNR - DT')    
    % Bathy
    plotbty(nameProfile);
    hold on
    % Source point
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')
    cd(obj.rootApp)
end