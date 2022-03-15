clear 
close all 


Ttot = 150 * 1e-6;       % Integration time - typical signal duration 
Fs = 1000 * 1e3;         % Sampling period 
Ts = 1/Fs;              % Sampling frequency
tn = 0:Ts:Ttot;         % Time vector 
N = numel(tn);          % Sample number 
n = 0:1:N-1;              % Sample vector

RL = 50; % Received level in dB 
pref = 1e-6; % Ref pressure 1uPa 
p_peak = 10^(RL/20) * pref; % 0 to peak received pressure 

% Sinusoidal signal (pure tone)
f0 = 130 * 1e3; % Signal frequency
s = p_peak * sin(2*pi*f0*tn); 

% Gaussian window
sigma = 0.15;
w = exp(-1/2 * ((n - N/2)/(sigma*N/2)).^2); 

% Simulated signal 
sigNoise = 0.1;
noise = sigNoise*randn(size(tn));
simulated_s = s.*w;

% Plot 
figure
plot(tn, s)
ylabel(sprintf('p_s [\\muPa]'))
xlabel('t')
title('Sinusoidal pure tone - 130kHz')

figure
plot(tn, w)
ylabel('w')
xlabel('t')
title(sprintf('Gaussian window - \\sigma=%.1f', sigma))

figure
plot(tn, simulated_s)
ylabel(sprintf('p_{simulated} [\\muPa]'))
xlabel('t')
title('Simulated signal - 130kHz')

figure 
plot(tn, noise)
ylabel(sprintf('noise [\\muPa]'))
xlabel('t')
title(sprintf('Noise - \\sigma = %.1f', sigNoise))

% FFT 
L = 2^nextpow2(N);
x = simulated_s;

f = [0:L-1]*Fs/L-Fs/2;
% f = [0:L-1]*Fs/L;

% FFT 
Xf = fft(x, L);
Xf = fftshift(Xf); % Centered spectrum 
ModXf = abs(Xf);

figure
plot(f*1e-3, ModXf)
xlabel('Frequency [kHz]')
xline(130, '--r')

% Signal mean power in T 
Ps = Ts/(tn(end)-tn(1)) * sum(x.^2);
Ps_f = Ts/L * 1/(tn(end)-tn(1)) * sum(ModXf.^2);
% We can check that Plancherel-Parseval is respected ! 
fprintf('Ps (from time serie) = %.1f W\n', Ps)
fprintf('Ps (from FFT) = %.1f W\n', Ps_f)

% Noise mean power 
% Pnl = Ts/(tn(end)-tn(1)) * sum(noise.^2);
Pnl = getPowerSignal(noise, Fs);
fprintf('Pnl (from time serie) = %.1f W\n', Pnl)

Ps_dB = 10*log10(Ps);
SNR_1 = 10*log10(Ps/Pnl);
SNR_2 = snr(x, noise); 

% figure
% y = awgn(x, SNR_1, 'measured');
% plot(tn, y)


