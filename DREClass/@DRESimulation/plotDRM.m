function plotDRM(obj, varargin) 
% Detection range map 
    if nargin > 1 && strcmp(varargin(1), 'app')
        figure('visible','off');
    end
    
    if ~obj.bathyDataIsGridded
        if numel(varargin) > 1
            promptMsg = 'Gridding detection probability data';
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

    % Bathy colored background
    obj.plotBathyPColor()
    % Detection range line 
    obj.plotDetectionRangeContour('--r', 2.5) 
    % Legend
    legend({'', '', 'Mooring', 'Detection range'})
    % Title 
    title('Detection Range Map', obj.mooring.mooringName)

    if nargin > 1 && strcmp(varargin(1), 'app')
        saveas(gcf, fullfile(obj.rootOutputFigures, 'DetectionRangeMap.png'))
        close(gcf)
    end
end