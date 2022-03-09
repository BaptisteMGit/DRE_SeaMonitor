function plotTL2D(obj)
    if ~obj.TLDataIsGridded; obj.gridTLData; end
    % Plot TL 
    h = pcolor(obj.Xgrid, obj.Ygrid, obj.TLgrid);
    shading interp
    colormap(flipud(jet))
    a = colorbar;
    a.Label.String = 'Transmission Loss [dB ref 1\muPa]';
    caxis([obj.tlmin, obj.tlmax])
    hold on 
    % Add bathy contour 
    obj.plotBathyContour()
    hold on
    % Add mooring position 
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')
    % Legend
    legend({'', '', 'Mooring'})
end