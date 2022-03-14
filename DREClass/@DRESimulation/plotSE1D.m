function plotSE1D(obj, nameProfile)
    cd(obj.rootOutputFiles)
    % SE
    varargin = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};
    [spl, ~, ~] = computeSPL(varargin{:});

    varargin = {'SPL', spl, 'Depth', obj.zt, 'Range', obj.rt, ...
        'NL', obj.noiseEnvironment.noiseLevel, 'DT', obj.detector.detectionThreshold, ...
        'zTarget', obj.marineMammal.livingDepth, 'deltaZ', obj.marineMammal.deltaLivingDepth};
    plotSE(varargin{:})
    hold on
    
    % Bathy
    plotbty(nameProfile);
    hold on

    % Source point
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')

    % Title
    title('Signal Excess', nameProfile)

    cd(obj.rootApp)
end