function [MSE, RMSE, R2] = netPerformance(targetData, estimateData)

% Calculating MSE
e = gsubtract(targetData, estimateData);
MSE = mean(e.^2,'all');

% Calculating RMSE
RMSE = sqrt(MSE);

% Calculating R2
avgTargets = mean(targetData, 2);
avgTargetsMatr = avgTargets .*ones(1,size(targetData,2));
numerator = sum(sum((estimateData - targetData).^2));   %SSE
denominator = sum(sum((targetData - avgTargetsMatr).^2));  %SST
R2 = 1 - (numerator ./ denominator);
end