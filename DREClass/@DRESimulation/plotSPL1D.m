function plotSPL1D(obj, nameProfile)
    cd(obj.rootOutputFiles)
    % SPL
    varargin = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};            
    plotSPL(varargin{:});
    a = colorbar;
    a.Label.String = 'Sound Pressure Level (dB ref 1\muPa)';
    % Bathy
    plotbty( nameProfile );
    % Source point 
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')
    cd(obj.rootApp)
end