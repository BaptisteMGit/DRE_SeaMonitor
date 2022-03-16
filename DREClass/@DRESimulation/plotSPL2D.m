function plotSPL2D(obj, varargin)
    if ~obj.TLDataIsGridded
        if numel(varargin) > 1
            promptMsg = 'Gridding TL data';
            fprintf(promptMsg)
            UIFigure = varargin{2};
            d = uiprogressdlg(UIFigure,'Title','Please Wait',...
                    'Message','Gridding TL data ...', ...
                    'Indeterminate','on');
            obj.gridTLData;
            close(d)
            linePts = repelem('.', 53 - numel(promptMsg));
            fprintf(' %s DONE\n', linePts);
        else 
            obj.gridTLData;
        end
    end

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
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'dk')
    % Legend
    legend({'', '', 'Mooring'})
    % Title 
    title('Sound Pressure Level Map', obj.mooring.mooringName)
end