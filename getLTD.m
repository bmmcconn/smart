function [LTD,P] = getLTD(X,LT,k)
%getLTD Estimate Lead Time Demand (LTD) for Intermittent Demand
%   Detailed explanation goes here
% X:  Historical demand vector (positive integers) over demand periods
% n:  Number of periods to forecast (forecast horizon)
% LT: Lead Time in number of periods 
% k:  Number of samples for Lead Time Demand distribution 
%     default = 1000
%
% LTD: 'k' x 1 matrix with the estimated Lead Time Demand distribution
%
% If 'k' empty, defaults to 1000 
% 
% MATLAB implementation of 
% Willemain, T.R., Smart, C.N., and Schwarz, H.F. 2004. A New Approach to 
% Forecasting Intermittent Demand for Service Parts Inventories, 
% International Journal of Forecasting, Vol 20, No 3, 375--387,
% DOI: 10.1016/S0169-2070(03)00013-X

% Input Error Checking ****************************************************
narginchk(2,3)
if isempty(k), k = 40; end
if LT<1 || k<1, error('LT and k must be greater than or equal to 1'), end
if ~isint(k), error('k must be integer'), end
if ~isint(LT), error('LT must be integer'), end
if sum(X<0)>0 % there is negative demand
    disp('*****Converting negative demand values to 0')
    X(X<0) = 0;
end
if sum(~isint(X))>0 % there is non-integer demand
    disp('*****Rounding noninteger demand to nearest integer')
    X(~isint(X)) = max(round(X(~isint(X)),0),0);
end
% End (Input Error Checking) **********************************************
X = X(:);
[u,~,n] = unique(X > 0);
NumU = length(u);     % Number of Unique Observations
Counts = accumarray([n(1:end-1),n(2:end)],1,[NumU,NumU]);
P = Counts./sum(Counts,2);

FDMD = zeros(k,LT);
for ii = 1:k
    if X(end)==0
        FutDmdBin = randsample(2,LT,true,P(1,:))-1;
    else % X(end)> 1
        FutDmdBin = randsample(2,LT,true,P(2,:))-1;
    end

    NumToReplace = sum(FutDmdBin);
    FutureDmd = FutDmdBin;
    Xstar = randsample(X(X>0),NumToReplace);
    Jit = 1 + round(Xstar + randn(size(Xstar)).*sqrt(Xstar),0);
    if sum(Jit==0) > 0
        Jit(Jit==0) = Xstar(Jit==0);
    end
    FutureDmd(FutDmdBin==1) = Jit;
    FDMD(ii,:) = FutureDmd(:).';
end

LTD = sum(FDMD,2);
end

