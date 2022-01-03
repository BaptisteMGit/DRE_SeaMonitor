function [x_utm, y_utm] = utm_geod2map(n, lon, lat)
%% Function utm_geod2map
%     Calcul les coordonnées X, Y en UTM correspondant aux coordonnées géographiques (lon, lat) pour la zone UTM numéro n
%     :param n: numéro de la zone UTM
%     :param lon: longitude géographique
%     :param lat: latitude géographique
%     :return: coordonnées UTM
%     """
    [a, e2, ~, ep2, ~, k0, ~] = getGRS80Parameters();
    b = beta(lat);
    [lon, lat] = convert_rad(lon, lat);
    X0 = 500000;

    Y0 = zeros(size(lat));
    idx_1 = lat > 0;
    Y0(idx_1) = 0;
    idx_2 = lat <= 0;
    Y0(idx_2) = 10000000;

    n1 = sqrt(1 + ep2 .* cos(lat).^4);
    v = sqrt(1 - e2 .* sin(lat));
    vp = sqrt(1 + ep2 .* cos(lat).^2);
    rho = a .* (1 - e2) ./ v.^3;
    N = a ./ v;
    lon0 = (6 .* (n - 31) + 3) .* (pi ./ 180);

    x_utm = X0 + k0 .* (sqrt(rho .* N) ./ 2) .* log((n1 + vp .* cos(lat) .* sin(n1 .* (lon - lon0))) ./ (n1 - vp .* cos(lat) .* sin(n1 .* (lon - lon0))));

    y_utm = Y0 + k0 .* b + k0 .* sqrt(rho .* N) .* (atan(tan(lat) ./ (vp .* cos(n1 .* (lon - lon0)))) - atan(tan(lat) ./ vp));

end  