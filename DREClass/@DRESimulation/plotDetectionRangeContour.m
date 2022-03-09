function plotDetectionRangeContour(obj, varargin)
% Plot detection range line 
    plotParameters = {'k', 2};
    plotParameters(1:nargin-1) = varargin;
    [xx, yy] = pol2cart(obj.listAz * pi/180, obj.listDetectionRange);
    plot(xx, yy, plotParameters{1}, 'LineWidth', plotParameters{2})
end 