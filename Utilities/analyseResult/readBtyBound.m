function btyBound = readBtyBound(filename, rt)
%GETBTYBOUND Summary of this function goes here
%   Detailed explanation goes here

delimiterIn = ' ';
headerlinesIn = 2;
A = importdata(filename, delimiterIn, headerlinesIn);

interpMethod = A.textdata(1);

switch interpMethod{1}
    case "'C'"
        interpMethod = 'linear';
    case "'L'"
        interpMethod = 'pchip';
end 

rBty = A.data(:, 1) * 1000;
zBty = A.data(:, 2);

btyBound.z = interp1(rBty, zBty, rt, interpMethod);
btyBound.r = rt;

end
