function extractBathySquare_ENU(filename, dE, dN)
%% Function extractBathySquare_UTM
%     Extract a square zone centered on the mooring position using ENU frame
%     data: panda dataframe with shape (n, 3) [[x_UTM, y_UTM, z]]
%     xM: x coordinate of the mooring
%     yM: y coordinate of the mooring
%     dX: dimension on the x axis (= East) of the square zone
%     dY: dimension on the y axis (= North) of the square zone
%     data -> decimated data representing a square zone centered on the mooring
    root = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\ENU'; 
    data = readmatrix(sprintf('%s\\%s',root, filename), 'Delimiter',' ');
    E = data(:,1);
    N = data(:,2);
    U = data(:,3);
    
    idx = (E < 1/2*dE) & (E > -1/2*dE) & (N < 1/2*dN) & (N > -1/2*dE);
%     square_data = data(idx);
    E = E(idx);
    N = N(idx);
    U = U(idx);
    
    T = table(E, N, U);
    fileWithoutExtension = filename(1:end-4);
    rootSave = 'C:\Users\33686\Desktop\SeaMonitor\Detection range estimation\Bathymetry\ENU'; 
    if ~exist(rootSave, 'dir'); mkdir(rootSave);end

    fileENU = sprintf('%s\\%s_square.csv', rootSave, fileWithoutExtension);
    writetable(T, fileENU,'Delimiter',' ')  
end