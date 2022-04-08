function [DLinv, DLmax] = deriveBroadbandDLinv(ka)
% Here we consider the broadband approximation given in the
% following paper 
% Ref: Passive Acoustic Monitoring of Cetaceans, Walter M. X. Zimmer,
% p260-267
% ka = 17.8; % 
% p99: Eq. 3.8 adapted considering DI = 20 log(ka) 
% NOTE: This approximation of DI is valid for narrowband signal with ka>>1
% yet we use it to derive ka fort all short pulses 

C1 = 47; % dB
C2 = 0.218*ka;
DLmax = C1 * C2^2 / (1 + C2 + C2^2);

% Inverse function of off-axis attenuation
% It is a piecewise-defined function 
DLinv = @(DL)...
    0 * (DL <= 0) + ... % DL = 0
    asin( -1/(2*C2) * DL/(DL - C1) * sqrt(1 - 4*(DL-C1)/DL) ) * (0 < DL & DL < DLmax) + ... % 0 < DL < DLmax
    pi * (DL >= DLmax); % DL >= DLmax
end

