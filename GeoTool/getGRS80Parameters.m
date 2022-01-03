function [a, e2, b, ep2, f, k0, omega_eura] = getGRS80Parameters()
%% Function getGRS80Parameters
% global variables : parameters for ellipsoid GRS80
a = 6378137;
e2 = 0.006694380022;
b = sqrt(a^2 * (1 - e2));
ep2 = (a^2 - b^2) / (b^2);
f = (a - b) / a;
k0 = 0.9996;
omega_eura = [-0.085, -0.531, 0.770];  % en mas/an (1 miliarcseconde = 1e-3" = 1e-3/3600 °)
end