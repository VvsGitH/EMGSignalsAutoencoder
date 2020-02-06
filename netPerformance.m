%% MSE RMSE and R2 of two matricial datasets 
% MSE: mean square error
% RMSE: root mean square error
% R2: coefficient of determination

function [MSE, RMSE, R2] = netPerformance(targetData, estimateData)

% Calculating MSE
e = gsubtract(targetData, estimateData);
MSE = mean(e.^2,'all');

% Calculating RMSE
RMSE = sqrt(MSE);

% Calculating R2
% R2 = 1 - SSres/SStot
% SSres = sum[(est - targ)^2]      -> Residual sum of squares
% SStot = sum[(targ - targ_avg)^2] -> Total sum of squares
SSres = sum(sum((estimateData - targetData).^2));
avgTargets = mean(targetData, 2);
avgTargetsMatr = avgTargets .*ones(1,size(targetData,2));
SStot = sum(sum((targetData - avgTargetsMatr).^2));
R2 = 1 - (SSres ./ SStot);
end

