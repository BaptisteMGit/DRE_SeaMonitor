function [spl, zt, rt] = computeSPL(varargin)

filename = getVararginValue(varargin, 'filename', '');
sl = getVararginValue(varargin, 'SL', 100); % Source level in decibel (dB) 

[tl, zt, rt] = computeTL(filename); % Transmission loss 

spl = sl - tl; % Sound pressure level 
end