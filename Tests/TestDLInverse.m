close all
clear
% Test the inverse formula 
dtheta = 0.01;
theta = dtheta:dtheta:pi/2;


DI = 23.5; % Directivity index of Porpoise (PAMofC (p89)) [dB]
ka = 10^(DI/20);

%% Broadband
C1 = 47; % dB
C2 = 0.218*ka;

cx = C2*sin(theta);
DL = C1 * cx.^2 ./ (1 + cx + cx.^2);

% % Circular piston model
% figure
% plot(theta*180/pi, DL, 'LineWidth', 1)
% xlabel('Off-axis angle [°]')
% ylabel('Off-axis attenuation [dB]')
% title('DL', sprintf('DI = %.0f dB', DI))
% set(gca, 'YDir', 'reverse')
% xlim([-90, 90])
% 
% 
% DLinv = asin( -1/(2*C2) * DL./(DL - C1) .* (1 + sqrt(1 - 4*(DL-C1)./DL )) );
% 
% % DLinv = asin(-1/(2*C2) * (DL ./ (DL - C1)) .* sqrt(1 - 4.*(DL - C1)./DL - 1));
% hold on 
% plot(theta*180/pi, DLinv*180/pi, 'LineWidth', 1)
% 
% figure
% plot(theta, DLinv, 'LineWidth', 1)
% hold on 
% plot(theta, theta, '--r', 'LineWidth', 1)
% 
% figure
% plot(theta*180/pi, abs(theta - DLinv)*180/pi)

%% Narrowband 
[DLinv, DLmax] = deriveNarrowbandDLinv(ka);
% figure
% plot(theta, DLinv(theta), 'LineWidth', 1)
% hold on 
% plot(theta, theta, '--r', 'LineWidth', 1)   