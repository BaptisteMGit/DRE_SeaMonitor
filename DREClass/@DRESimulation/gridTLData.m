function gridTLData(obj) 
% Grid TL data 
    if ~obj.bathyDataIsGridded; obj.gridBathyData; end
    cd(obj.rootOutputFiles) 

    ntheta = numel(obj.listAz);
    nrt = numel(obj.rt);
    
    E = ones([ntheta*nrt, 1]);
    N = ones([ntheta*nrt, 1]);
    TL = ones([ntheta*nrt, 1]);
    
    
    for i = 1:ntheta
        theta_i = obj.listAz(i);
        nameProfile = sprintf('%s-%2.1f', obj.mooring.mooringName, theta_i);
        filename = sprintf('%s.shd', nameProfile);
        [tl_i, ~, ~] = computeTL(filename); % Transmission loss
%         E_i = obj.rt * cos(theta_i*pi/180);
%         N_i = obj.rt * sin(theta_i*pi/180);
%         TL_i = tl_i;
%         max(tl_i)
        [E_i, N_i, TL_i] = pol2cart(theta_i*pi/180, obj.rt, tl_i);
        
        % Median TL
        TL_i = median(TL_i);
        E(1 + (i-1)*nrt:i*nrt) = E_i;
        N(1 + (i-1)*nrt:i*nrt) = N_i;
        TL(1 + (i-1)*nrt:i*nrt) = TL_i;
    end

    tlmed = median(TL);
    tlstd = std(TL(TL < 200)); % Avoid extrem values (= value in the ground) 
    tlmax = tlmed + 0.75 * tlstd;       % max for colorbar
    tlmax = 10 * round( tlmax / 10 );   % make sure the limits are round numbers
    tlmin = tlmax - 50;                 % min for colorbar
    
    obj.tlmin = tlmin;
    obj.tlmax = tlmax;

    obj.TLgrid = griddata(E, N, TL, obj.Xgrid, obj.Ygrid, 'nearest');
    obj.TLDataIsGridded = 1;
    cd(obj.rootApp)
end