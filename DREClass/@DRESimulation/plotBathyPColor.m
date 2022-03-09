function plotBathyPColor(obj) % Plot bathy pcolor 
    if ~obj.bathyDataIsGridded; obj.gridBathyData; end

    % Pcolor
    pcolor(obj.Xgrid, obj.Ygrid, obj.Zgrid)
    shading flat
    hold on
    % Contour 
    obj.plotBathyContour()
    % Colormap
    setBathyColormap(obj.Zgrid)
    hold on 
    % Mooring point
    scatter(0, 0, 'filled', 'red') 

    title(obj.mooring.mooringName)
    xlabel('E [m]')
    ylabel('N [m]')
end
