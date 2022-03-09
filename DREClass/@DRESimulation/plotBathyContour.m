function plotBathyContour(obj) 
% Plot bathy contour lines 
    if ~obj.bathyDataIsGridded; obj.gridBathyData; end
    contour(obj.Xgrid, obj.Ygrid, obj.Zgrid, 'k', 'ShowText','on', 'LabelSpacing', 1000)
end