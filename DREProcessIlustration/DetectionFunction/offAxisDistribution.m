% Script to show off-axis distribution used to derive
% detection function. 
% Ref: Passive Acoustic Monitoring of Cetaceans by Walter M. X. Zimmer 
% Page: 263 -264



%% Detecting an arbitrary click
dth = 0.1;
thetadeg = 0:dth:180;
theta = thetadeg * pi/180;

figure
Woa = 1/2 * sin(theta);
plot(thetadeg, Woa)

figure 
polarplot(theta, Woa)

%% Detecting a near on-axis click
mu = [0 0];
sigmaHdeg = 20;
sigmaH = sigmaHdeg * pi/180; % Standard deviation of head moovements 

% The covariance matrix is diagonal because we asume that the animal is
% moving the head with no horizontal or vertical preference.
Sigma = sigmaH * eye(2); 

x1 = -3:0.1:3;
x2 = -3:0.1:3;
[X1,X2] = meshgrid(x1,x2);
X = [X1(:) X2(:)];

y = mvnpdf(X,mu,Sigma);
y = reshape(y,length(x2),length(x1));


figure
lgd = {};
surf(x1,x2,y)
lgd{end+1} = sprintf('Off-axis Raileigh distribution with \\sigma_H = %d°', sigmaHdeg);
caxis([min(y(:))-0.5*range(y(:)),max(y(:))])
axis([-3 3 -3 3 0 1])
xlabel('x')
ylabel('y')
zlabel('Probability Density')

hold on
plot3([0, 0], [0, 0], [0, 1], 'LineWidth', 2, 'Color', 'r');
lgd{end+1} = 'On-axis';

hold on 
xoffaxis = 0:0.01:1;
yoffaxis = 0.5 * xoffaxis;
zoffaxis = 2 * yoffaxis;

plot3(xoffaxis, yoffaxis, zoffaxis, 'LineWidth', 2, 'LineStyle','--')
lgd{end+1} = 'Off-axis';

legend(lgd)


%% Comparison of the two distributions

% Probability density function
dth = 0.1;
thetadeg = 0:dth:90;
theta = thetadeg * pi/180;

figure
lgd = {};
Woa_a = 1/2 * sin(theta);
plot(thetadeg, Woa_a, 'LineWidth', 1)
lgd{end + 1} = 'W_{OA_A}';

listSigmaHdeg = [1 5 10 30 50];
for sigmaHdeg = listSigmaHdeg
    sigmaH = sigmaHdeg * pi/180;
    Woa_h = (theta / sigmaH^2) .* exp(-1/2 * ( (theta / sigmaH).^2) );
    hold on 
    plot(thetadeg, Woa_h, 'LineWidth', 1)
    lgd{end+1} = sprintf('W_{OA_H}, \\sigma_H = %.1f °', sigmaHdeg);
end 
xlabel('Off-axis angle [°]')
ylabel('PDF')
legend(lgd)
title('Probability density function - Off-axis distribution')

% Cumulative distribution function
figure
lgd = {};
CDFoa_a = 1/2 * (1 - cos(theta));
plot(thetadeg, CDFoa_a, 'LineWidth', 1)
lgd{end + 1} = 'W_{OA_A}';

listSigmaHdeg = [1 5 10 30 50];
for sigmaHdeg = listSigmaHdeg
    sigmaH = sigmaHdeg * pi/180;
    CDFoa_h = 1 - exp(-1/2 * ( (theta / sigmaH).^2) );
    hold on 
    plot(thetadeg, CDFoa_h, 'LineWidth', 1)
    lgd{end+1} = sprintf('W_{OA_H}, \\sigma_H = %.1f °', sigmaHdeg);
end 

xlabel('Off-axis angle [°]')
ylabel('CDF')
legend(lgd)
title('Cumulative distribution function - Off-axis distribution')




