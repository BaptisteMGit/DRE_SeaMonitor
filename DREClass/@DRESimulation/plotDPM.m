function plotDPM(obj) 
% Detection probability map 
    % Detection probability   
    if ~obj.DPDataIsGridded; obj.gridDPData; end
    pcolor(obj.Xgrid, obj.Ygrid, obj.DPgrid);
    shading interp
    colormap(flipud(hot))
    c = colorbar;
    c.Label.String = 'Detection probability';
    caxis([0, 1])
    hold on 
    scatter(0, 0, 'filled', 'red') 
    hold on 
    % Bathy contour 
    obj.plotBathyContour()
    hold on 
    % Detection range 
    obj.plotDetectionRangeContour('--b', 2) 
    setProbabilityColormap()
    hold off
    % auto scale
    r = obj.getRadiusToPlot(); 
    xlim([-r, r])
    ylim([-r, r])
    % Labels 
    % title('Detection probability')
    xlabel('E [m]')
    ylabel('N [m]')
    legend({'', 'Mooring', '', 'Detection range'})

end