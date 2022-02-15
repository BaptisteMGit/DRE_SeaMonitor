dt = 0.001;
t = -20:dt:50;

%% Transient signal (click) 
ymod = sinc(t - 9.5);
y = 10*sin(t - 10 + pi).*ymod;

figure 
plot(t, y, 'linewidth', 1.5)
xline(0, 'k', 'lineWidth', 1.5)
yline(0, 'k', 'lineWidth', 1.5)
xlim([-10, 20])
ylim([min(y)-2, max(y)+2])
ylabel('p(t)')
xlabel('t')
yline([max(y), min(y)], '--r', 'linewidth', 1)

%% baseline to peak peak equivalent SPL (b-p peSPL) 
f_eq = 1000;
p_bp = max(abs(y));
A_bp = p_bp;
y_bp_equ = A_bp * sin(2*pi*0.2*t);

hold on 
plot(t, y_bp_equ,'-k', 'linewidth', 0.5)

p_rms_eq = max(y_bp_equ) / sqrt(2);
yline(p_rms_eq, '--k', 'LineWidth', 1, 'Label', 'p_{RMSeq-bp}')

xlim([-10, 50])
ylim([min(y_bp_equ)-2, max(y_bp_equ)+2])

%% peak to peak peak equivalent SPL (p-p peSPL) 
p_pp = abs(max(y) - min(y));
A_pp = p_pp/2;
y_pp_equ = A_pp * sin(2*pi*0.2*t);

hold on 
plot(t, y_pp_equ,'-m', 'linewidth', 0.5)

p_rms_eq = max(y_pp_equ) / sqrt(2);
yline(p_rms_eq, '-m', 'LineWidth', 1, 'Label', 'p_{RMSeq-pp}')

xlim([-10, 50])
% ylim([min(y_pp_equ)-2, max(y_pp_equ)+2])

legend({'Transient signal', '', '', '', '', 'Baseline to peak equivalent sinus 1kHz', '', 'Peak to peak equivalent sinus 1kHz'}, 'Location', 'southeast')
