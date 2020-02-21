%% Non-Negative Matrix Factorization Method
% Synergies based EMG factorization
% Force recostruction with linear synergy based model Hc

function NNMFsim = meth2_NNMF(EMG, FORCE, maxEMG, indVect)

%% DATASET DIVISION
TI  = indVect(1); 
VI  = indVect(2);
END = length(EMG);
[EMG_Train, ~, EMG_Test]     = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[FORCE_Train, ~, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

%% TRAINING/SIMULATION LOOP
MSE_emg_tr  = zeros(10,1); MSE_frc_tr  = zeros(10,1);
RMSE_emg_tr = zeros(10,1); RMSE_frc_tr = zeros(10,1);
R2_emg_tr   = zeros(10,1); R2_frc_tr   = zeros(10,1);
MSE_emg_ts  = zeros(10,1); MSE_frc_ts  = zeros(10,1);
RMSE_emg_ts = zeros(10,1); RMSE_frc_ts = zeros(10,1);
R2_emg_ts   = zeros(10,1); R2_frc_ts   = zeros(10,1);
synMatrix   = cell(10,1);  convMatrix  = cell(10,1);

parfor h = 1:10
    %% TRAINING
    fprintf('       S%d: Training\n',h);
    options=statset('nnmf');
    [W, C_tr] = nnmf(EMG_Train, h, 'algorithm', 'mult','replicates',5,'options',options);
    synMatrix{h,1} = W;
    
    %% SIMULATION
    fprintf('       S%d: Simulation\n',h);
    EMG_Recos_tr = W*C_tr;   % Reconstruction of train EMG
    C_ts = pinv(W)*EMG_Test; % Test synergies activation matrix (LQ)
    EMG_Recos_ts = W*C_ts;   % Recostruction of test EMG
    
    %% FORCE RECONSTRUCTION
    % Hc model
    H = FORCE_Train*pinv(C_tr); % Synergies to force conversion matrix (LQ)
    convMatrix{h,1} = H;
    FORCE_Recos_tr = H*C_tr;    % Reconstruction of train forces
    FORCE_Recos_ts = H*C_ts;    % Reconstruction of test forces

    %% PERFORMANCE
    % Performance for the reconstruction of EMG signal
    EMG_Train_den    = dataDenormalize(EMG_Train,0,1,maxEMG);
    EMG_Test_den     = dataDenormalize(EMG_Test,0,1,maxEMG);
	EMG_Recos_tr_den = dataDenormalize(EMG_Recos_tr,0,1,maxEMG);
    EMG_Recos_ts_den = dataDenormalize(EMG_Recos_ts,0,1,maxEMG);
    [mse_emg_tr, rmse_emg_tr, r2_emg_tr] = dataPerformance(EMG_Train_den, EMG_Recos_tr_den);
    [mse_emg_ts, rmse_emg_ts, r2_emg_ts] = dataPerformance(EMG_Test_den, EMG_Recos_ts_den);
    
    % Performance for the reconstruction of Forces
    [mse_frc_tr, rmse_frc_tr, r2_frc_tr] = dataPerformance(FORCE_Train, FORCE_Recos_tr);
    [mse_frc_ts, rmse_frc_ts, r2_frc_ts] = dataPerformance(FORCE_Test, FORCE_Recos_ts);
    
    % Inserting into vectors
    MSE_emg_tr(h,1)  = mse_emg_tr;
    MSE_frc_tr(h,1)  = mse_frc_tr;
    RMSE_emg_tr(h,1) = rmse_emg_tr;
    RMSE_frc_tr(h,1) = rmse_frc_tr;
    R2_emg_tr(h,1)   = r2_emg_tr;
    R2_frc_tr(h,1)   = r2_frc_tr;
    MSE_emg_ts(h,1)  = mse_emg_ts;
    MSE_frc_ts(h,1)  = mse_frc_ts;
    RMSE_emg_ts(h,1) = rmse_emg_ts;
    RMSE_frc_ts(h,1) = rmse_frc_ts;
    R2_emg_ts(h,1)   = r2_emg_ts;
    R2_frc_ts(h,1)   = r2_frc_ts;

end

%% SAVING
NNMFsim.synMatrix      = synMatrix;
NNMFsim.convMatrix     = convMatrix;
NNMFsim.Train.MSE_emg  = MSE_emg_tr;
NNMFsim.Train.RMSE_emg = RMSE_emg_tr;
NNMFsim.Train.R2_emg   = R2_emg_tr;
NNMFsim.Train.MSE_frc  = MSE_frc_tr;
NNMFsim.Train.RMSE_frc = RMSE_frc_tr;
NNMFsim.Train.R2_frc   = R2_frc_tr;
NNMFsim.Test.MSE_emg   = MSE_emg_ts;
NNMFsim.Test.RMSE_emg  = RMSE_emg_ts;
NNMFsim.Test.R2_emg    = R2_emg_ts;
NNMFsim.Test.MSE_frc   = MSE_frc_ts;
NNMFsim.Test.RMSE_frc  = RMSE_frc_ts;
NNMFsim.Test.R2_frc    = R2_frc_ts;

end