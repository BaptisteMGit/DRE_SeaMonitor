function plotDetectionFunction(obj, nameProfile) 

    nameProfileParts = split(nameProfile,"-");
    theta_str = nameProfileParts(end);
    theta = str2double(theta_str);
    epsilon = 0.01;
    idx = find(abs(theta - obj.listAz) < epsilon);

    detectionFunction = obj.listDetectionFunction(idx, :);
    detectionRange = obj.listDetectionRange(idx);

    plot(obj.rt, detectionFunction)
    hold on 
    
    % Threshold lines 
    yline(str2double(obj.detectionRangeThreshold(1:end-1))/100, '--r', 'LineWidth', 1, 'Label', sprintf('%s EDR threshold', obj.detectionRangeThreshold))
    hold on 
%     yline(str2double(obj.maximumDetectionRangeThreshold(1:end-1))/100, '--k', 'LineWidth', 1, 'Label', sprintf('%s  MDR threshold', obj.maximumDetectionRangeThreshold))
%     hold on

    % Detection range 
    xline(detectionRange, '--r', 'LineWidth', 1, ...
        'Label', sprintf('%s EDR = %dm', obj.detectionRangeThreshold, round(detectionRange, 0)),...
        'LabelOrientation', 'aligned', 'LabelVerticalAlignment', 'top')
%     xline(obj.maxDR, '--k', 'LineWidth', 1, ...
%         'Label', sprintf('%s MDR = %dm', obj.maximumDetectionRangeThreshold, round(obj.maxDR, 0)),...
%         'LabelOrientation', 'aligned', 'LabelVerticalAlignment', 'top')
    
    % Labels 
    title({sprintf('Detection function - %s', nameProfile)})
    xlabel('Range [m]')
    ylabel('Detection probability')

%     cd(obj.rootOutputFigures)
%     saveas(gcf, sprintf('%s_DetectionFunction.png', nameProfile));
%     cd(obj.rootApp)
end
