%% Compare the two methods that can be consider to derive distance 
% Lets consider a mooring point with the following coordinates (testcase 1)
mooringPos.lat = 52.225;
mooringPos.lon = -4.370;
mooringPos.hgt = 54.180; % Ellipsoidal heigth 

% For a set of points (lon, lat) we derive the distance from the mooring
% point using the two methods
dLat = 0.001; % Lat resolution 
dLon = 0.001; % Lon resolution
wBox = 0.1; % Box With 
listLat = mooringPos.lat:dLat:mooringPos.lat + wBox;
listLon = mooringPos.lon:dLon:mooringPos.lon + wBox;

listSphere = [];
listPlan = []; 

% for lat2 = listLat
%     for lon2 = listLon
%         dS = dSphere(mooringPos.lon, mooringPos.lat, lon2, lat2);
%         listSphere = [listSphere dS];
%         dP = dPlan(mooringPos.lon, mooringPos.lat, lon2, lat2, mooringPos.hgt);
%         listPlan = [listPlan, dP];
%     end
% end 
%  
for i = 1:numel(listLat)
    lat2 = listLat(i);
    lon2 = listLon(i);
    dS = dSphere(mooringPos.lon, mooringPos.lat, lon2, lat2);
    listSphere = [listSphere dS];
    dP = dPlan(mooringPos.lon, mooringPos.lat, lon2, lat2, mooringPos.hgt);
    listPlan = [listPlan, dP];
end 

%% Plot results 
close all 
    
figure 
x = min(listSphere):0.01:max(listSphere)+100;
plot(x, x, '-r', 'LineWidth', 2) % ref line 
hold on
scatter(listSphere, listPlan, 12, 'ok')
xlabel('Spherical distance [m]')
ylabel('Plan distance [m]')
title('Distance comparison')

% Error 
err = listSphere - listPlan;
figure 
plot(listSphere, err, '-k', 'LineWidth', 1)
xlabel('Spherical distance [m]')
ylabel('Error [m]')
title('Distance error')
% 10m threshold 
idx1Meter = find(abs(err) <= 10, 1, "last");
x1Meter = listSphere(idx1Meter);
hold on 
xline(x1Meter, '--r', sprintf('d = %.0fm', x1Meter), 'LineWidth', 1, 'LabelOrientation','horizontal')
yline(-10, '--r', '10m error', 'LineWidth', 1)

% Relative error 
% 0 for i = 1 
relErr = abs(listSphere(2:end) - listPlan(2:end)) ./ listSphere(2:end) * 100;
figure 
plot(listSphere(2:end), relErr, '-k', 'LineWidth', 1)
xlabel('Spherical distance [m]')
ylabel('Relative error [%]')
title('Distance error')

if max(listSphere) > 100000 
    % 1% threshold 
    idx1Percent = find(relErr <= 1, 1, "last");
    x1Percent = listSphere(idx1Percent);
    hold on 
    xline(x1Percent, '--r', sprintf('d = %.0fm', x1Percent), 'LineWidth', 1, 'LabelOrientation','horizontal')
    yline(1, '--r', '1% error', 'LineWidth', 1)
end

function d = dSphere(lon1, lat1, lon2, lat2)
    R = 6371 * 1e3; % mean radius of the earth
    [lon1, lat1] = convert_rad(lon1, lat1);
    [lon2, lat2] = convert_rad(lon2, lat2);
    
    % spherical law of cosines
    d = acos( sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2 - lon1) ) * R; 
end

function d = dPlan(lon1, lat1, lon2, lat2, hgt)
    [E, N, ~] = geod2enu(lon1, lat1, hgt, lon2, lat2, hgt);
    d = sqrt(E^2 + N^2);
end