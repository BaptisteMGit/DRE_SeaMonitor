function plotDPM(obj, varargin) 
% Detection probability map 

    if nargin > 1 && strcmp(varargin(1), 'app')
        figure('visible','off');
    end
    
    % Detection probability   
    %     if ~obj.DPDataIsGridded; obj.gridDPData; end
    if ~obj.DPDataIsGridded
        if numel(varargin) > 1
            promptMsg = 'Gridding detection probability data';
            fprintf(promptMsg)
            UIFigure = varargin{2};
            d = uiprogressdlg(UIFigure,'Title','Please Wait',...
                    'Message','Gridding detection probability data ...', ...
                    'Indeterminate','on');
            obj.gridDPData;
            close(d)
            linePts = repelem('.', 53 - numel(promptMsg));
            fprintf(' %s DONE\n', linePts);
        else 
            obj.gridDPData;
        end
    end

    pcolor(obj.Xgrid, obj.Ygrid, obj.DPgrid);
    shading interp
    colormap(flipud(hot))
    c = colorbar;
    c.Label.String = 'Detection probability';
    caxis([0, 1])
    hold on 
    scatter(0, 0, 'filled', 'db') 
    hold on 
    % Bathy contour 
    obj.plotBathyContour()
    hold on 
    % Detection range 
    obj.plotDetectionRangeContour('--b', 2) 
    setProbabilityColormap()
    % auto scale
    r = obj.getRadiusToPlot(); 
    xlim([-r, r])
    ylim([-r, r])
    % Labels 
    % title('Detection probability')
    xlabel('E [m]')
    ylabel('N [m]')
    legend({'', 'Mooring', '', 'Detection range'})
    % Title 
    title('Detection Probability Map', obj.mooring.mooringName)

    hold off

    if nargin > 1 && strcmp(varargin(1), 'app')
        saveas(gcf, fullfile(obj.rootOutputFigures, 'DetectionProbabilityMap.png'))
        close(gcf)
    end
end