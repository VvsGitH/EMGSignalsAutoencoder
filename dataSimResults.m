function saveStr = dataSimResults(netSim, selSbj)

N = length(selSbj);
avgMSE_emg_tr  = zeros(10,1); avgMSE_frc_tr  = zeros(10,1);
avgRMSE_emg_tr = zeros(10,1); avgRMSE_frc_tr = zeros(10,1);
avgR2_emg_tr   = zeros(10,1); avgR2_frc_tr   = zeros(10,1);
avgMSE_emg_ts  = zeros(10,1); avgMSE_frc_ts  = zeros(10,1);
avgRMSE_emg_ts = zeros(10,1); avgRMSE_frc_ts = zeros(10,1);
avgR2_emg_ts   = zeros(10,1); avgR2_frc_ts   = zeros(10,1);
for trSogg = selSbj
    avgMSE_emg_tr  = avgMSE_emg_tr  + netSim{trSogg}.MSE_emg_tr;
    avgMSE_frc_tr  = avgMSE_frc_tr  + netSim{trSogg}.MSE_frc_tr;
    avgRMSE_emg_tr = avgRMSE_emg_tr + netSim{trSogg}.RMSE_emg_tr;
    avgRMSE_frc_tr = avgRMSE_frc_tr + netSim{trSogg}.RMSE_frc_tr;
    avgR2_emg_tr   = avgR2_emg_tr   + netSim{trSogg}.R2_emg_tr;
    avgR2_frc_tr   = avgR2_frc_tr   + netSim{trSogg}.R2_frc_tr;  
    avgMSE_emg_ts  = avgMSE_emg_ts  + netSim{trSogg}.MSE_emg_ts;
    avgMSE_frc_ts  = avgMSE_frc_ts  + netSim{trSogg}.MSE_frc_ts;
    avgRMSE_emg_ts = avgRMSE_emg_ts + netSim{trSogg}.RMSE_emg_ts;
    avgRMSE_frc_ts = avgRMSE_frc_ts + netSim{trSogg}.RMSE_frc_ts;
    avgR2_emg_ts   = avgR2_emg_ts   + netSim{trSogg}.R2_emg_ts;
    avgR2_frc_ts   = avgR2_frc_ts   + netSim{trSogg}.R2_frc_ts;
end
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

stdMSE_emg_tr  = zeros(10,1); stdMSE_frc_tr  = zeros(10,1);
stdRMSE_emg_tr = zeros(10,1); stdRMSE_frc_tr = zeros(10,1);
stdR2_emg_tr   = zeros(10,1); stdR2_frc_tr   = zeros(10,1);
stdMSE_emg_ts  = zeros(10,1); stdMSE_frc_ts  = zeros(10,1);
stdRMSE_emg_ts = zeros(10,1); stdRMSE_frc_ts = zeros(10,1);
stdR2_emg_ts   = zeros(10,1); stdR2_frc_ts   = zeros(10,1);
for trSogg = selSbj
    stdMSE_emg_tr  = stdMSE_emg_tr  + (netSim{trSogg}.MSE_emg_tr  - avgMSE_emg_tr).^2;
    stdMSE_frc_tr  = stdMSE_frc_tr  + (netSim{trSogg}.MSE_frc_tr  - avgMSE_frc_tr).^2;
    stdRMSE_emg_tr = stdRMSE_emg_tr + (netSim{trSogg}.RMSE_emg_tr - avgRMSE_emg_tr).^2;
    stdRMSE_frc_tr = stdRMSE_frc_tr + (netSim{trSogg}.RMSE_frc_tr - avgRMSE_frc_tr).^2;
    stdR2_emg_tr   = stdR2_emg_tr   + (netSim{trSogg}.R2_emg_tr   - avgR2_emg_tr).^2;
    stdR2_frc_tr   = stdR2_frc_tr   + (netSim{trSogg}.R2_frc_tr   - avgR2_frc_tr).^2;  
    stdMSE_emg_ts  = stdMSE_emg_ts  + (netSim{trSogg}.MSE_emg_ts  - avgMSE_emg_ts).^2;
    stdMSE_frc_ts  = stdMSE_frc_ts  + (netSim{trSogg}.MSE_frc_ts  - avgMSE_frc_ts).^2;
    stdRMSE_emg_ts = stdRMSE_emg_ts + (netSim{trSogg}.RMSE_emg_ts - avgRMSE_emg_ts).^2;
    stdRMSE_frc_ts = stdRMSE_frc_ts + (netSim{trSogg}.RMSE_frc_ts - avgRMSE_frc_ts).^2;
    stdR2_emg_ts   = stdR2_emg_ts   + (netSim{trSogg}.R2_emg_ts   - avgR2_emg_ts).^2;
    stdR2_frc_ts   = stdR2_frc_ts   + (netSim{trSogg}.R2_frc_ts   - avgR2_frc_ts).^2;
end
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

saveStr.avgMSE_emg_tr  = avgMSE_emg_tr;
saveStr.avgMSE_frc_tr  = avgMSE_frc_tr;
saveStr.avgRMSE_emg_tr = avgRMSE_emg_tr;
saveStr.avgRMSE_frc_tr = avgRMSE_frc_tr;
saveStr.avgR2_emg_tr   = avgR2_emg_tr;
saveStr.avgR2_frc_tr   = avgR2_frc_tr;
saveStr.avgMSE_emg_ts  = avgMSE_emg_ts;
saveStr.avgMSE_frc_ts  = avgMSE_frc_ts;
saveStr.avgRMSE_emg_ts = avgRMSE_emg_ts;
saveStr.avgRMSE_frc_ts = avgRMSE_frc_ts;
saveStr.avgR2_emg_ts   = avgR2_emg_ts;
saveStr.avgR2_frc_ts   = avgR2_frc_ts;

saveStr.stdMSE_emg_tr  = stdMSE_emg_tr;
saveStr.stdMSE_frc_tr  = stdMSE_frc_tr;
saveStr.stdRMSE_emg_tr = stdRMSE_emg_tr;
saveStr.stdRMSE_frc_tr = stdRMSE_frc_tr;
saveStr.stdR2_emg_tr   = stdR2_emg_tr;
saveStr.stdR2_frc_tr   = stdR2_frc_tr;
saveStr.stdMSE_emg_ts  = stdMSE_emg_ts;
saveStr.stdMSE_frc_ts  = stdMSE_frc_ts;
saveStr.stdRMSE_emg_ts = stdRMSE_emg_ts;
saveStr.stdRMSE_frc_ts = stdRMSE_frc_ts;
saveStr.stdR2_emg_ts   = stdR2_emg_ts;
saveStr.stdR2_frc_ts   = stdR2_frc_ts;

end