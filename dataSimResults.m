%% Determination of the avg and the std of the performance indexes between subjects
% The indexes are MSE, RMSE, R2
% The same indexes were calculated for emg and force, with test and train
% data.

function saveStr = dataSimResults(netSim, selSbj)

N = length(selSbj);

%% CALCULATION OF THE THE AVERAGE INDEXS
% AVG = SUM(Index)/N
avgMSE_emg_tr  = zeros(10,1); avgMSE_frc_tr  = zeros(10,1);
avgRMSE_emg_tr = zeros(10,1); avgRMSE_frc_tr = zeros(10,1);
avgR2_emg_tr   = zeros(10,1); avgR2_frc_tr   = zeros(10,1);
avgMSE_emg_ts  = zeros(10,1); avgMSE_frc_ts  = zeros(10,1);
avgRMSE_emg_ts = zeros(10,1); avgRMSE_frc_ts = zeros(10,1);
avgR2_emg_ts   = zeros(10,1); avgR2_frc_ts   = zeros(10,1);
% Calculating the sum
for trSogg = selSbj
    avgMSE_emg_tr  = avgMSE_emg_tr  + netSim{trSogg}.Train.MSE_emg;
    avgMSE_frc_tr  = avgMSE_frc_tr  + netSim{trSogg}.Train.MSE_frc;
    avgRMSE_emg_tr = avgRMSE_emg_tr + netSim{trSogg}.Train.RMSE_emg;
    avgRMSE_frc_tr = avgRMSE_frc_tr + netSim{trSogg}.Train.RMSE_frc;
    avgR2_emg_tr   = avgR2_emg_tr   + netSim{trSogg}.Train.R2_emg;
    avgR2_frc_tr   = avgR2_frc_tr   + netSim{trSogg}.Train.R2_frc;  
    avgMSE_emg_ts  = avgMSE_emg_ts  + netSim{trSogg}.Test.MSE_emg;
    avgMSE_frc_ts  = avgMSE_frc_ts  + netSim{trSogg}.Test.MSE_frc;
    avgRMSE_emg_ts = avgRMSE_emg_ts + netSim{trSogg}.Test.RMSE_emg;
    avgRMSE_frc_ts = avgRMSE_frc_ts + netSim{trSogg}.Test.RMSE_frc;
    avgR2_emg_ts   = avgR2_emg_ts   + netSim{trSogg}.Test.R2_emg;
    avgR2_frc_ts   = avgR2_frc_ts   + netSim{trSogg}.Test.R2_frc;
end
% Divinding the sum by the number of subjects
avgMSE_emg_tr  = avgMSE_emg_tr./N;
avgMSE_frc_tr  = avgMSE_frc_tr./N;
avgRMSE_emg_tr = avgRMSE_emg_tr./N;
avgRMSE_frc_tr = avgRMSE_frc_tr./N;
avgR2_emg_tr   = avgR2_emg_tr./N;
avgR2_frc_tr   = avgR2_frc_tr./N;
avgMSE_emg_ts  = avgMSE_emg_ts./N;
avgMSE_frc_ts  = avgMSE_frc_ts./N;
avgRMSE_emg_ts = avgRMSE_emg_ts./N;
avgRMSE_frc_ts = avgRMSE_frc_ts./N;
avgR2_emg_ts   = avgR2_emg_ts./N;
avgR2_frc_ts   = avgR2_frc_ts./N;

%% CALCULATION OF THE STANDARD DEVIATION OF THE INDEXES
% STD = SQRT[(index - AVG)^2/N-1] 
stdMSE_emg_tr  = zeros(10,1); stdMSE_frc_tr  = zeros(10,1);
stdRMSE_emg_tr = zeros(10,1); stdRMSE_frc_tr = zeros(10,1);
stdR2_emg_tr   = zeros(10,1); stdR2_frc_tr   = zeros(10,1);
stdMSE_emg_ts  = zeros(10,1); stdMSE_frc_ts  = zeros(10,1);
stdRMSE_emg_ts = zeros(10,1); stdRMSE_frc_ts = zeros(10,1);
stdR2_emg_ts   = zeros(10,1); stdR2_frc_ts   = zeros(10,1);
% Calculating the square sums
for trSogg = selSbj
    stdMSE_emg_tr  = stdMSE_emg_tr  + (netSim{trSogg}.Train.MSE_emg  - avgMSE_emg_tr).^2;
    stdMSE_frc_tr  = stdMSE_frc_tr  + (netSim{trSogg}.Train.MSE_frc  - avgMSE_frc_tr).^2;
    stdRMSE_emg_tr = stdRMSE_emg_tr + (netSim{trSogg}.Train.RMSE_emg - avgRMSE_emg_tr).^2;
    stdRMSE_frc_tr = stdRMSE_frc_tr + (netSim{trSogg}.Train.RMSE_frc - avgRMSE_frc_tr).^2;
    stdR2_emg_tr   = stdR2_emg_tr   + (netSim{trSogg}.Train.R2_emg   - avgR2_emg_tr).^2;
    stdR2_frc_tr   = stdR2_frc_tr   + (netSim{trSogg}.Train.R2_frc   - avgR2_frc_tr).^2;  
    stdMSE_emg_ts  = stdMSE_emg_ts  + (netSim{trSogg}.Test.MSE_emg   - avgMSE_emg_ts).^2;
    stdMSE_frc_ts  = stdMSE_frc_ts  + (netSim{trSogg}.Test.MSE_frc   - avgMSE_frc_ts).^2;
    stdRMSE_emg_ts = stdRMSE_emg_ts + (netSim{trSogg}.Test.RMSE_emg  - avgRMSE_emg_ts).^2;
    stdRMSE_frc_ts = stdRMSE_frc_ts + (netSim{trSogg}.Test.RMSE_frc  - avgRMSE_frc_ts).^2;
    stdR2_emg_ts   = stdR2_emg_ts   + (netSim{trSogg}.Test.R2_emg    - avgR2_emg_ts).^2;
    stdR2_frc_ts   = stdR2_frc_ts   + (netSim{trSogg}.Test.R2_frc    - avgR2_frc_ts).^2;
end
% Doing the square root of the square sum, divided by the number of subjects -1
stdMSE_emg_tr  = sqrt(stdMSE_emg_tr./(N-1));
stdMSE_frc_tr  = sqrt(stdMSE_frc_tr./(N-1));
stdRMSE_emg_tr = sqrt(stdRMSE_emg_tr./(N-1));
stdRMSE_frc_tr = sqrt(stdRMSE_frc_tr./(N-1));
stdR2_emg_tr   = sqrt(stdR2_emg_tr./(N-1));
stdR2_frc_tr   = sqrt(stdR2_frc_tr./(N-1));
stdMSE_emg_ts  = sqrt(stdMSE_emg_ts./(N-1));
stdMSE_frc_ts  = sqrt(stdMSE_frc_ts./(N-1));
stdRMSE_emg_ts = sqrt(stdRMSE_emg_ts./(N-1));
stdRMSE_frc_ts = sqrt(stdRMSE_frc_ts./(N-1));
stdR2_emg_ts   = sqrt(stdR2_emg_ts./(N-1));
stdR2_frc_ts   = sqrt(stdR2_frc_ts./(N-1));

%% SAVING INDEXES INTO A STRUCTURE
% Averages
saveStr.Train.avgMSE_emg  = avgMSE_emg_tr;
saveStr.Train.avgRMSE_emg = avgRMSE_emg_tr;
saveStr.Train.avgR2_emg   = avgR2_emg_tr;
saveStr.Train.avgMSE_frc  = avgMSE_frc_tr;
saveStr.Train.avgRMSE_frc = avgRMSE_frc_tr;
saveStr.Train.avgR2_frc   = avgR2_frc_tr;
saveStr.Test.avgMSE_emg   = avgMSE_emg_ts;
saveStr.Test.avgRMSE_emg  = avgRMSE_emg_ts;
saveStr.Test.avgR2_emg    = avgR2_emg_ts;
saveStr.Test.avgMSE_frc   = avgMSE_frc_ts;
saveStr.Test.avgRMSE_frc  = avgRMSE_frc_ts;
saveStr.Test.avgR2_frc    = avgR2_frc_ts;
% Standard Deviations
saveStr.Train.stdMSE_emg  = stdMSE_emg_tr;
saveStr.Train.stdRMSE_emg = stdRMSE_emg_tr;
saveStr.Train.stdR2_emg   = stdR2_emg_tr;
saveStr.Train.stdMSE_frc  = stdMSE_frc_tr;
saveStr.Train.stdRMSE_frc = stdRMSE_frc_tr;
saveStr.Train.stdR2_frc   = stdR2_frc_tr;
saveStr.Test.stdMSE_emg   = stdMSE_emg_ts;
saveStr.Test.stdRMSE_emg  = stdRMSE_emg_ts;
saveStr.Test.stdR2_emg    = stdR2_emg_ts;
saveStr.Test.stdMSE_frc   = stdMSE_frc_ts;
saveStr.Test.stdRMSE_frc  = stdRMSE_frc_ts;
saveStr.Test.stdR2_frc    = stdR2_frc_ts;

end