function Xbar = GaussianWeightedMean(X, idxMu, nStd, varargin)
%GAUSSIANWHEIGHTEDMEAN Returns the gaussian weighted of the vector X
% centered on the index idxMu with and std of nStd
% X must be either a column vector or a 2D array. 
% In case X is a 2D array the mean is derived for each column of the array 

sz = size(X);
n = sz(1);
xw = 1:1:n; 
w = 1/(2*pi*nStd) * exp(-(xw'-idxMu).^2 / (2*nStd^2)); % Gaussian weigths

if nargin > 3
    validityDomain = varargin{1}; % Boolean map where X is valid
else
    validityDomain = ones(sz);
end

% figure
% plot(xw, w)
Xbar = ones([1, sz(2)]);
for i=1:sz(2)
    Xi = X(:, i); % Column nb i of X 
    validityDomain_i = validityDomain(:, i);
    w = w .* validityDomain_i;
    Xbar(i) = sum(w.*Xi) / sum(w);
end 

end

