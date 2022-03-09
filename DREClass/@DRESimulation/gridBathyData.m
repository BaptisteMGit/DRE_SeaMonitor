function gridBathyData(obj) 
% Grid bathy data 
    E = obj.dataBathy(:,1); N = obj.dataBathy(:,2); U = obj.dataBathy(:,3);
    pts = 1E+3;
    xGrid = linspace(min(E), max(E), pts);
    yGrid = linspace(min(N), max(N), pts);
    [obj.Xgrid, obj.Ygrid] = meshgrid(xGrid, yGrid);
    obj.Zgrid = griddata(E, N, U, obj.Xgrid, obj.Ygrid);
    obj.bathyDataIsGridded = 1;
end