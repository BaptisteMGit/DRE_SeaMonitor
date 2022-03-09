function plotDPM(obj) 
% Detection probability map 
    % Detection probability    
    plotDetectionProbability2D(obj.listAz, obj.rt, obj.listDetectionFunction)
    hold on 
    % Bathy contour 
    obj.plotBathyContour()
    hold on 
    % Detection range 
    obj.plotDetectionRangeContour('r--o', 1) 
    setProbabilityColormap()
    hold off
    legend({'', 'Mooring', '', 'Detection range'})
    % auto scale
    r = obj.getRadiusToPlot(); 
    xlim([-r, r])
    ylim([-r, r])
end