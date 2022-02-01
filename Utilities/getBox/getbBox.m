function bBox = getbBox(lonMin, lonMax, latMin, latMax)
    bBox.lon.min = lonMin; 
    bBox.lon.max = lonMax;
    bBox.lat.min = latMin;
    bBox.lat.max = latMax;
end