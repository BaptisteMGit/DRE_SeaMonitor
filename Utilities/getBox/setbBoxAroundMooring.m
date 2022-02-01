function bBox = setbBoxAroundMooring(mooringPos)
% SETBBOXAROUNDMOORING Get a squared boundary box centered on the
% mooring position given by the mooringPos property of the mooring object

boxWidth = 1; % Width in degree 
boxLength = 1; % Length in degree 

latMin = mooringPos.lat - boxLength;
latMax = mooringPos.lat + boxLength;
lonMin = mooringPos.lon - boxWidth;
lonMax = mooringPos.lon + boxWidth;

bBox = getbBox(lonMin, lonMax, latMin, latMax);

end