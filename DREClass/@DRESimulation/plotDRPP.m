function plotDRPP(obj, varargin)
% Detection range polarplot 
    if nargin > 1 && strcmp(varargin(1), 'app')
        figure('visible','off');
    end

    Rmax = max(obj.listDetectionRange);
    polarplot(obj.listAz * pi/180, obj.listDetectionRange, 'r--o', 'LineWidth', 1.5)
    ax = gca;
    ax.RLim = [0, Rmax+50];
    % Legend
    legend({'Detection range'})
    % Title
    title('Detection Range Polarplot', obj.mooring.mooringName)

    if nargin > 1 && strcmp(varargin(1), 'app')
        saveas(gcf, fullfile(obj.rootOutputFigures, 'DetectionRangePolarplot.png'))
        close(gcf)
    end
end