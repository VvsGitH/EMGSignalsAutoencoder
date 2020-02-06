%% Denormalization by row of a matricial dataset
% Xnorm: dataset
% [a, b]: normalization extremes 
% MAX: array which contains the maximum values of each rows, before the
%      normalization.
% MIN: (optional) array which contains the minimum values of each rows, 
%      before the normalization.

function XRecos = dataDenormalize(Xnorm,a,b,MAX,MIN)

% Rows number
R = size(Xnorm,1);

% Set MIN = 0, if omitted
if nargin == 4
    MIN = zeros(R,1);
end

% Denormalization with the following inverse formula
%       Xrecos = (Xnorm-a)*(max-min)/(b-a) + min
XRecos = zeros(R, size(Xnorm,2));
for i = 1:R
    XRecos(i,:) = ((Xnorm(i,:)-a).*(MAX(i,1)-MIN(i,1)))./(b-a) + MIN(i,1);
end

end

