function plotDetectionFunction(obj, nameProfile) 

    nameProfileParts = split(nameProfile,"-");
    theta_str = nameProfileParts(end);
    theta = str2double(theta_str);
    idx = find(theta == obj.listAz); 

    detectionFunction = obj.listDetectionFunction(idx, :);
    detectionRange = obj.listDetectionRange(idx);

    plot(obj.rt, detectionFunction)
    hold on 
    
    % Threshold lines 
    yline(str2double(obj.detectionRangeThreshold(1:end-1))/100, '--r', 'LineWidth', 1, 'Label', sprintf('%s detection threshold', obj.detectionRangeThreshold))
    hold on 

    % Detection range 
    xline(detectionRange, '--g', 'LineWidth', 1, ...
        'Label', sprintf('%s detection range = %dm', obj.detectionRangeThreshold, round(detectionRange, 0)),...
        'LabelOrientation', 'horizontal', 'LabelVerticalAlignment', 'top')
    
    % Labels 
    title({sprintf('Detection function - %s', nameProfile)})
    xlabel('Range [m]')
    ylabel('Detection probability')

%     cd(obj.rootOutputFigures)
%     saveas(gcf, sprintf('%s_DetectionFunction.png', nameProfile));
%     cd(obj.rootApp)
end
