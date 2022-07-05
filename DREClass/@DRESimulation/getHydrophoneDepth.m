function hydrophoneDepth = getHydrophoneDepth(obj)
%GETHYDROPHONEDEPTH Summary of this function goes here
%   Detailed explanation goes here
    if obj.mooring.hydrophoneDepth < 0  % If negative the position of the hydrophone if reference to the seafloor
        F = scatteredInterpolant(obj.dataBathy(:, 1), obj.dataBathy(:, 2), obj.dataBathy(:, 3));
        depthOnMooringPos = -F(0, 0); % Get depth on mooring position ("-" to get depth positive toward the bottom)
        hydrophoneDepth = depthOnMooringPos + obj.mooring.hydrophoneDepth; % TODO: check 
    else
        hydrophoneDepth = obj.mooring.hydrophoneDepth; % TODO: check 
    end
end

