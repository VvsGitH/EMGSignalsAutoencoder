function LFRsim = meth1_LFR(EMG, FORCE, indVect)

%% DATASET DIVISION
TI  = indVect(1); 
VI  = indVect(2);
END = length(EMG);
[EMG_Train, ~, EMG_Test]     = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[FORCE_Train, ~, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

%% GRAM-SCHMIDT ORTOGONALIZATION ALOGORITH WITH COLUMN PIVOTING
H = FORCE_Train/EMG_Train;

%% FORCE RECONSTRUCTION
FORCE_Recos_tr = H*EMG_Train;
FORCE_Recos_ts = H*EMG_Test;

%% PERFORMANCE
[mse_tr, rmse_tr, r2_tr] = dataPerformance(FORCE_Train, FORCE_Recos_tr);
[mse_ts, rmse_ts, r2_ts] = dataPerformance(FORCE_Test, FORCE_Recos_ts);

%% SAVING
LFRsim.convMatrix = H;
LFRsim.MSE_emg_tr     = 0;
LFRsim.MSE_emg_ts     = 0;
LFRsim.MSE_frc_tr     = mse_tr;
LFRsim.MSE_frc_ts     = mse_ts;
LFRsim.RMSE_emg_tr    = 0;
LFRsim.RMSE_emg_ts    = 0;
LFRsim.RMSE_frc_tr    = rmse_tr;
LFRsim.RMSE_frc_ts    = rmse_ts;
LFRsim.R2_emg_tr      = 1;
LFRsim.R2_emg_ts      = 1;
LFRsim.R2_frc_tr      = r2_tr;
LFRsim.R2_frc_ts      = r2_ts;

end

