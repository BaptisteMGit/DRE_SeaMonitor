function plotBathy2D(obj)
    obj.plotBathyPColor()
    legend({'', '', 'Mooring'})
    setBathyColormap(obj.Zgrid)
end