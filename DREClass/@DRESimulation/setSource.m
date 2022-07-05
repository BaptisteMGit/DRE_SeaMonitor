function setSource(obj)
    % Position of the hydrophone in the water column 
%     if obj.mooring.hydrophoneDepth < 0  % If negative the position of the hydrophone if reference to the seafloor
%         F = scatteredInterpolant(obj.dataBathy(:, 1), obj.dataBathy(:, 2), obj.dataBathy(:, 3));
%         depthOnMooringPos = -F(0, 0); % Get depth on mooring position ("-" to get depth positive toward the bottom)
%         obj.receiverPos.s.z = depthOnMooringPos + obj.mooring.hydrophoneDepth; % TODO: check 
%     else
%         obj.receiverPos.s.z = obj.mooring.hydrophoneDepth; % TODO: check 
%     end
    obj.receiverPos.s.z = obj.hydroDepthRefToSurf;
end