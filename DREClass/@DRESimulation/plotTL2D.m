function plotTL2D(obj, varargin)
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

    % Plot TL 
    pcolor(obj.Xgrid, obj.Ygrid, obj.TLgrid);
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
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'dk')
    % Legend
    legend({'', '', 'Mooring'})
    % Title 
    title('Transmission Loss Map', obj.mooring.mooringName)
end