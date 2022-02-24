function tOut = secondToMinuteHour(tIn)
%SECONDTOMINUTEHOUR Summary of this function goes here
%   tIn: time in seconds 
%   tOut: struct with field min, hour, s
    
[hour, rHour] = qr(tIn, 3600);

[min, rmin] = qr(rHour, 60);

sec = rmin;

tOut = struct('hour', hour, 'min', min, 'sec', sec); 

% Derive quotient and remainder 
function [q, r] = qr(a, b)
    r = rem(a, b);
    q = (a-r) / b;
end

end

