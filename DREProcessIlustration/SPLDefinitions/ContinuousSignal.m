dt = 0.001;
t = -20:dt:50;
ymod = cos(0.3*pi*1/30*(t -10));
A = 2.5;
phi0 = 20 * pi/180;
y = A*sin(t + phi0).*ymod;

figure 
plot(t, y, 'linewidth', 1)
xline(0, 'k', 'lineWidth', 1.5)
yline(0, 'k', 'lineWidth', 1.5)
xlim([-20, 37])
ylim([-4, 4])
ylabel('p(t)')
xlabel('t')
yline([2.5, -2.5], '--r', 'linewidth', 1)


p_rms = max(y) / sqrt(2);
yline(p_rms, '--k', 'LineWidth', 1, 'Label', 'p_{RMS}')