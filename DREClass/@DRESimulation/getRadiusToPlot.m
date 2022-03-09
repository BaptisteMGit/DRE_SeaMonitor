function radiusToPlot = getRadiusToPlot(obj) 
% Get radius for auto scale 
    threshold = 0.01;
    [~, colR] = find(obj.listDetectionFunction >= threshold, 1, 'last');
    radiusToPlot = obj.rt(colR);
    radiusToPlot = ceil(radiusToPlot/100) * 100; % Round to the superior hundred
end
