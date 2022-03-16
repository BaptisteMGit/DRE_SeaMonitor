function plotBathy2D(obj, varargin)
%     if ~obj.bathyDataIsGridded; obj.gridBathyData; end
    if ~obj.bathyDataIsGridded
        if numel(varargin) > 1
            promptMsg = 'Gridding bathymetry data';
            fprintf(promptMsg)
            UIFigure = varargin{2};
            d = uiprogressdlg(UIFigure,'Title','Please Wait',...
                    'Message','Gridding bathymetry data ...', ...
                    'Indeterminate','on');
            obj.gridBathyData;
            close(d)
            linePts = repelem('.', 53 - numel(promptMsg));
            fprintf(' %s DONE\n', linePts);
        else 
            obj.gridBathyData;
        end
    end

    obj.plotBathyPColor()
    legend({'', '', 'Mooring'})
    setBathyColormap(obj.Zgrid)
    % Title 
    title('Bathymetry Map', obj.mooring.mooringName)
end