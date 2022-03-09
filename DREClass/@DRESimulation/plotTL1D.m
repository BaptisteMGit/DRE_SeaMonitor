function plotTL1D(obj, nameProfile)
    cd(obj.rootOutputFiles)
    % TL
    plotshd( sprintf('%s.shd', nameProfile) );
    a = colorbar;
    a.Label.String = 'Transmission Loss (dB ref 1\muPa)';
    % Bathy
    plotbty( nameProfile );
    % Source point 
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')
    cd(obj.rootApp)
end