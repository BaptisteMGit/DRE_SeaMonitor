function plotDRM(obj) 
% Detection range map 
    % Bathy colored background
    obj.plotBathyPColor()
    % Detection range line 
    obj.plotDetectionRangeContour('--r', 2.5) 
    % Legend
    legend({'', '', 'Mooring', 'Detection range'})
end