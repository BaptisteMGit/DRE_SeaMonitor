function setReceiverPos(obj, bathyProfile)
    % Receivers
    obj.receiverPos.r.range = 0:obj.bellhopEnvironment.drSimu:max(bathyProfile(:, 1)); % Receiver ranges (km)
    obj.receiverPos.r.z = 0:obj.bellhopEnvironment.dzSimu:max(bathyProfile(:, 2)); % Receiver depths (m)  
end
