function map = red2white()
%RED2WHITEMAP Summary of this function goes here
%   Detailed explanation goes here

% Red to White map 
c11 = 0:0.01:1;
c21 = 0:0.01:1;
c31 = repelem(1, numel(c11));
c12 = c31;
c22 = flip(c11);
c32 = flip(c21);

map = [c11' c21' c31'
       c12' c22' c32']; 
end

