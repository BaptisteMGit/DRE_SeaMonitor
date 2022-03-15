function P = getPowerSignal(x, Fs)
%GETPOWERSIGNAL 
Ts = 1/Fs;          % Sampling frequency
N = numel(x);          % Sample number 
tn = 0:Ts:(N-1)*Ts;         % Time vector 

P = Ts/(tn(end)-tn(1)) * sum(x.^2);
end

