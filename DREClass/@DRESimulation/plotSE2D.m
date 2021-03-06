function plotSE2D(obj, varargin)
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

    % Plot SE
    sl = obj.marineMammal.signal.sourceLevel;
    SPLgrid = sl - obj.TLgrid;
    
    nl = obj.noiseEnvironment.noiseLevel;
    SNRgrid = SPLgrid -  nl;

    dt = obj.detector.detectionThreshold;
    SEgrid = SNRgrid - dt; 
    
    pcolor(obj.Xgrid, obj.Ygrid, SEgrid);
    shading interp
    colormap(red2white)
    a = colorbar;
    a.Label.String = 'Signal excess [dB]';
    semin = -20;
    semax = 20;
    caxis([semin, semax])
    hold on 

    % Add bathy contour 
    obj.plotBathyContour()
    hold on

    % Add mooring position 
    scatter(0, obj.receiverPos.s.z, 50, 'filled', 'dk')
    
    % Legend
    legend({'', '', 'Mooring'})
    % Title 
    title('Signal Excess Map', obj.mooring.mooringName)
end