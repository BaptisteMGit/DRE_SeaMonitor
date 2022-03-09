function plotSPL2D(obj)
    if ~obj.TLDataIsGridded; obj.gridTLData; end
    % Plot SPL
    sl = obj.marineMammal.signal.sourceLevel;
    SPLgrid = sl - obj.TLgrid;
    pcolor(obj.Xgrid, obj.Ygrid, SPLgrid);
    shading interp
    colormap(jet)
    a = colorbar;
    a.Label.String = 'Sound Pressure Level [dB]';
    splmin = sl - obj.tlmax;
    splmax = sl - obj.tlmin;
    caxis([splmin, splmax])
    hold on 
    % Add bathy contour 
    obj.plotBathyContour()
    hold on
    % Add mooring position 
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'k')
    % Legend
    legend({'', '', 'Mooring'})
end