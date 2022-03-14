function plotTL1D(obj, nameProfile)
    cd(obj.rootOutputFiles)
    % TL
    plotshd( sprintf('%s.shd', nameProfile) );
    a = colorbar;
    a.Label.String = 'Transmission Loss (dB ref 1\muPa)';
    hold on
    % Bathy
    plotbty( nameProfile );
    hold on
    % Source point 
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')

    % Title
    title('Transmission Loss', nameProfile)

    cd(obj.rootApp)
end