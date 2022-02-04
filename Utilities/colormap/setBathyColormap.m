function setBathyColormap(z)
%SETBATHYCOLORMAP set the colormap of the bathymetry map 
%   z = depths positive upward 
%   depth distribution is used to define the scale of the colobar 

zMax = round(max(z, [], 'all'), -1);
zMin = round(min(z, [], 'all'), -1);

deltaZdata = zMax - zMin;
deltaZcolorbar = 10; % Desired width of z intervals for colorbar 
nColors = round(deltaZdata/deltaZcolorbar, 0);
cmap = zeros([nColors, 3]);

landColor =  [248 218 163]/255;
nLand = ceil(max(z, [], 'all')/deltaZcolorbar);

cmap(1:nLand-1, :) = repmat(landColor, nLand-1, 1); % Uniform land because this is not of interest here 
cmap(nLand, :) = [1 1 1]; % White 

k = nColors - (nLand) + 1;
for i = nLand+1:nColors
    cmap(i, :) = [max(0, 1-4/k), max(0, 1-2/k), 1]; 
    k = k - 1;
end

colormap(flipud(cmap));
c = colorbar;
c.Label.String = 'Elevation (m)';
caxis([zMin, zMax]);

end



