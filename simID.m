function [d] = simID(n, obs, adi, cv2, level)
% n: number of demand streams to create
% obs: number of time periods to simulate
% adi: average demand interval
% cv2: coefficient of variation squared
% level: average of nonzero demand 
%
% d: 'n' x 'obs' matrix with the specified demand streams
%
% If 'level' empty, defaults to sample from Uniform(10,100). 
% 
% MATLAB implementation of simID() from 'tsintermittent' package for R
% https://www.rdocumentation.org/packages/tsintermittent/versions/1.9/topics/simID
% https://CRAN.R-project.org/package=tsintermittent
%
% This simulator assumes that non-zero demand arrivals follow a bernoulli distribution 
% and the non-zero demands a negative binomial distribution. 
% Petropoulos F., Makridakis S., Assimakopoulos V. & Nikolopoulos K. (2014) 
% "'Horses for Courses' in demand forecasting", 
% European Journal of Operational Research, Vol. 237, No. 1, pp. 152-163

% Input Error Checking ****************************************************
narginchk(3,5)
if isempty(level), level = 10 + 90*rand(); end
if cv2<=0, error('cv2 must be positive'), end
if n<0 || obs<0 || adi < 0, error('n, obs, and adi must be positive'), end
if adi < 1, error('adi must be greater than 1'), end
% End (Input Error Checking) **********************************************

m = level - 1;
if ( cv2 ~= 0)
    p = (m / ( cv2 * ( (m+1)^2) ) ); % calculates the p for negative binomial function
    r = m * p / (1 - p); % calculates the r for the negative binomial function
    d = binornd(1, 1 / adi, n, obs) .* (nbinrnd(r, p, n, obs) + 1);
else
    d = binornd(1, 1/adi, n, obs) .* repmat(m + 1, n, obs);
end

end

