function knots = findDLKnots(ka)
%% Find directional loss knots 
% Find zeros of J1 function 
% First-order Bessel function of the first kind 
J1 = @(x) besselj(1, x);

lb = 0;             % Set a lower bound for the function.
ub = 1.1*pi/2;          % Set an upper bound for the function.
x = NaN*ones(100, 1);             % Initializes x.
starting_points=linspace(lb, ub, 100);

for i=1:100
        % Look for the zeros in the function's current window.
        x(i) = fzero(@(x) J1(ka*sin(x)), starting_points(i));
end

knots = x(diff(x)>1e-12);
knots = knots(2:end); % Get rid of the first 0 (corresponding to on-axis)

% figure
% dth = 0.01;
% thetadeg = 0:dth:90;
% theta = thetadeg * pi/180;
% plot(thetadeg, J1(ka*sin(theta)), 'LineWidth', 1.5)
% yline(0, 'k')
% x_unique_deg = knots*180/pi;
% for i = 1:numel(knots)
%     xline(x_unique_deg(i), '--k', 'LineWidth', 1, 'Label', sprintf('%.1f°', x_unique_deg(i)))
% end
% 
% legend({'J1(ka*sin(\theta))', '', '','', 'Zeros of the function'}, 'Location', 'southeast')
% xlabel('\theta [°]')
% ylabel('J1(ka*sin(\theta))')

end

