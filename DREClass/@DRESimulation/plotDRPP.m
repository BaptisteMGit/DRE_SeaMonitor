function plotDRPP(obj)
% Detection range polarplot 
    Rmax = max(obj.listDetectionRange);
    polarplot(obj.listAz * pi/180, obj.listDetectionRange, 'r--o', 'LineWidth', 1.5)
    ax = gca;
    ax.RLim = [0, Rmax+50];
    % Legend
    legend({'Detection range'})
    % Title
    title(obj.mooring.mooringName)
end