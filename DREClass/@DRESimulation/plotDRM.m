function plotDRM(obj, varargin) 
% Detection range map 
    if nargin > 1 && strcmp(varargin(1), 'app')
        figure('visible','off');
    end

    % Bathy colored background
    obj.plotBathyPColor()
    % Detection range line 
    obj.plotDetectionRangeContour('--r', 2.5) 
    % Legend
    legend({'', '', 'Mooring', 'Detection range'})
    % Title 
    title('Detection Range Map', obj.mooring.mooringName)

    if nargin > 1 && strcmp(varargin(1), 'app')
        saveas(gcf, fullfile(obj.rootOutputFigures, 'DetectionRangeMap.png'))
        close(gcf)
    end
end