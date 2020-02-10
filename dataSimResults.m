function [avgMSE_emg,  avgMSE_frc,  ...
          avgRMSE_emg, avgRMSE_frc, ...
          avgR2_emg,   avgR2_frc,   ...
          stdMSE_emg,  stdMSE_frc,  ...
          stdRMSE_emg, stdRMSE_frc, ...
          stdR2_emg,   stdR2_frc] = dataSimResults(netSim, selSbj)

N = length(selSbj);
avgMSE_emg  = zeros(10,1); avgMSE_frc  = zeros(10,1);
avgRMSE_emg = zeros(10,1); avgRMSE_frc = zeros(10,1);
avgR2_emg   = zeros(10,1); avgR2_frc   = zeros(10,1);
for trSogg = selSbj
    avgMSE_emg  = avgMSE_emg  + netSim{trSogg}.MSE_emg;
    avgMSE_frc  = avgMSE_frc  + netSim{trSogg}.MSE_frc;
    avgRMSE_emg = avgRMSE_emg + netSim{trSogg}.RMSE_emg;
    avgRMSE_frc = avgRMSE_frc + netSim{trSogg}.RMSE_frc;
    avgR2_emg   = avgR2_emg   + netSim{trSogg}.R2_emg;
    avgR2_frc   = avgR2_frc   + netSim{trSogg}.R2_frc;  
end
avgMSE_emg  = avgMSE_emg./N;
avgMSE_frc  = avgMSE_frc./N;
avgRMSE_emg = avgRMSE_emg./N;
avgRMSE_frc = avgRMSE_frc./N;
avgR2_emg   = avgR2_emg./N;
avgR2_frc   = avgR2_frc./N;

stdMSE_emg  = zeros(10,1); stdMSE_frc  = zeros(10,1);
stdRMSE_emg = zeros(10,1); stdRMSE_frc = zeros(10,1);
stdR2_emg   = zeros(10,1); stdR2_frc   = zeros(10,1);
for trSogg = selSbj
    stdMSE_emg  = stdMSE_emg  + (netSim{trSogg}.MSE_emg  - avgMSE_emg).^2;
    stdMSE_frc  = stdMSE_frc  + (netSim{trSogg}.MSE_frc  - avgMSE_frc).^2;
    stdRMSE_emg = stdRMSE_emg + (netSim{trSogg}.RMSE_emg - avgRMSE_emg).^2;
    stdRMSE_frc = stdRMSE_frc + (netSim{trSogg}.RMSE_frc - avgRMSE_frc).^2;
    stdR2_emg   = stdR2_emg   + (netSim{trSogg}.R2_emg   - avgR2_emg).^2;
    stdR2_frc   = stdR2_frc   + (netSim{trSogg}.R2_frc   - avgR2_frc).^2;  
end
stdMSE_emg  = sqrt(stdMSE_emg./(N-1));
stdMSE_frc  = sqrt(stdMSE_frc./(N-1));
stdRMSE_emg = sqrt(stdRMSE_emg./(N-1));
stdRMSE_frc = sqrt(stdRMSE_frc./(N-1));
stdR2_emg   = sqrt(stdR2_emg./(N-1));
stdR2_frc   = sqrt(stdR2_frc./(N-1));

end