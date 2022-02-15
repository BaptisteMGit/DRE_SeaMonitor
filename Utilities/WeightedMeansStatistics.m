function [muhat, sigmahat] = WeightedMeansStatistics(mu,sigma)

sigmahat2 = 1 ./ sum(1 ./ sigma.^2); 
muhat = sigmahat2 * sum(mu ./ sigma.^2);
sigmahat = sqrt(sigmahat2);

end

