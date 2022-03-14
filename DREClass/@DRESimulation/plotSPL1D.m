function plotSPL1D(obj, nameProfile)
    cd(obj.rootOutputFiles)

    % SPL
    varargin = {'filename',  sprintf('%s.shd', nameProfile), 'SL', obj.marineMammal.signal.sourceLevel};            
    plotSPL(varargin{:});
    a = colorbar;
    a.Label.String = 'Sound Pressure Level (dB ref 1\muPa)';
    hold on 

    % Bathy
    plotbty( nameProfile );
    hold on

    % Source point 
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')

    % Title
    title('Sound Pressure Level', nameProfile)

    cd(obj.rootApp)
end