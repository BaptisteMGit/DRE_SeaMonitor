function [muGD, sigmaGD] = GraybillDealEstimator(mu, sigma, n)
%GRAYBILLDEALESTIMATOR Graybill-Deal estimator 
%   mu = vector of estimated means mu_i
%   sigma = vector of estimated std sigma_i 
%   n = vector of number of samples used for estimation_i 
%   Ref: Weighted means statistics in interlaboratory studies. Andrew L Rukhin

F = @(c, z) hypergeom([1 2], c, z);
% a = F(2, 1-4)

omegaGD = sigma.^(-2) ./ sum(sigma.^(-2));

muGD = sum(omegaGD .* mu);
varGD = 1 / sum(sigma.^(-2)) .* sum( omegaGD .* F( (n+1)./2, 1-omegaGD ) );
sigmaGD = sqrt(varGD);

end

