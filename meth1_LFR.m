%% Linear Force Reconstruction Method
% Linear Estimation of FORCE signals from EMG signals

function LFRsim = meth1_LFR(EMG, FORCE, indVect)

%% DATASET DIVISION
TI  = indVect(1); 
VI  = indVect(2);
END = length(EMG);
[EMG_Train, ~, EMG_Test]     = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[FORCE_Train, ~, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

%% CALCULATION OF H MATRIX
% GRAM-SCHMIDT ORTOGONALIZATION ALOGORITH WITH COLUMN PIVOTING
H = FORCE_Train/EMG_Train;

%% FORCE RECONSTRUCTION
FORCE_Recos_tr = H*EMG_Train;
FORCE_Recos_ts = H*EMG_Test;

%% PERFORMANCE
[mse_tr, rmse_tr, r2_tr] = dataPerformance(FORCE_Train, FORCE_Recos_tr);
[mse_ts, rmse_ts, r2_ts] = dataPerformance(FORCE_Test, FORCE_Recos_ts);

%% SAVING
LFRsim.convMatrix     = H;
LFRsim.Train.MSE_emg  = 0;
LFRsim.Train.RMSE_emg = 0;
LFRsim.Train.R2_emg   = 1;
LFRsim.Train.MSE_frc  = mse_tr;
LFRsim.Train.RMSE_frc = rmse_tr;
LFRsim.Train.R2_frc   = r2_tr;
LFRsim.Test.MSE_emg   = 0;
LFRsim.Test.RMSE_emg  = 0;
LFRsim.Test.R2_emg    = 1;
LFRsim.Test.MSE_frc   = mse_ts;
LFRsim.Test.RMSE_frc  = rmse_ts;
LFRsim.Test.R2_frc    = r2_ts;

end