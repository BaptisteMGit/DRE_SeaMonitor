function plotBathy2D(obj)
    obj.plotBathyPColor()
    legend({'', '', 'Mooring'})
    setBathyColormap(obj.Zgrid)
    % Title 
    title('Bathymetry Map', obj.mooring.mooringName)
end