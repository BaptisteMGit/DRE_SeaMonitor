function setProbabilityColormap()
%SETPROBABILITYCOLORMAP Custom colormap for detection probability map 

cmap = [0.3333         0         0
        0.6667         0         0
        1.0000         0         0
        1.0000    0.3333         0
        1.0000    0.6667         0
        1.0000    1.0000         0
        1.0000    1.0000    0.2500
        1.0000    1.0000    0.5000
        1.0000    1.0000    0.7500
        1.0000    1.0000    1.0000];

cmap = flipud(cmap);
colormap(cmap)
c = colorbar;
c.Label.String = 'Probability';
caxis([0, 1]);

end

