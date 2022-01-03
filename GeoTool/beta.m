function b = beta(lat)
%% Function beta 
%     Longeur d'un arc méridien entre un point quelconque de latitude lat et l'équateur
%     On calcul ici une valeur approchée de beta ne comprenant que les 5 premiers termes
%     L'erreur est inférieure à 1mm
    [a, e2, ~, ~, ~, ~, ~] = getGRS80Parameters();
    lat = lat .* pi / 180;
    e = sqrt(e2);
    b_0 = 1 - 0.25 .* e^2 - (3 / 64) .* e^4 - (5 / 256) .* e^6 - (175 / 16384) .* e^8;
    b_1 = -(105 / 4096) .* e^8 - (45 / 1024) .* e^6 - (3 / 32) .* e^4 - (3 / 8) .* e^2;
    b_2 = (525 / 16384) .* e^8 + (45 / 1024) .* e^6 + (15 / 256) .* e^4;
    b_3 = -(175 / 12288) .* e^8 - (35 / 3072) .* e^6;
    b_4 = (315 / 131072) .* e^8;
    b = a .* (b_0 .* lat + b_1 .* sin(2 .* lat) + b_2 .* sin(4 .* lat) + b_3 .* sin(6 .* lat) + b_4 .* sin(8 .* lat));

end