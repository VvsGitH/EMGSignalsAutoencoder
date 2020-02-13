function NNMFsim = meth2_NNMF(EMG, FORCE, maxEMG, indVect)

%% DATASET DIVISION
TI  = indVect(1); 
VI  = indVect(2);
END = length(EMG);
[EMG_Train, ~, EMG_Test]     = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[FORCE_Train, ~, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

%%
MSE_emg_tr  = zeros(1,10); MSE_frc_tr  = zeros(1,10);
RMSE_emg_tr = zeros(1,10); RMSE_frc_tr = zeros(1,10);
R2_emg_tr   = zeros(1,10); R2_frc_tr   = zeros(1,10);
MSE_emg_ts  = zeros(1,10); MSE_frc_ts  = zeros(1,10);
RMSE_emg_ts = zeros(1,10); RMSE_frc_ts = zeros(1,10);
R2_emg_ts   = zeros(1,10); R2_frc_ts   = zeros(1,10);
synMatrix   = cell(1,10);  convMatrix  = cell(1,10);

for h = 1:10
    %% TRAINING
    fprintf('       H%d: Training\n',h);
    options=statset('nnmf');
    [ C_tr , W ] = nnmf(EMG_Train', h, 'algorithm', 'mult','replicates',5,'options',options);
    synMatrix{1,h} = W;
    
    %% SIMULATION
    fprintf('       H%d: Simulation\n',h);
    EMG_Recos_tr = C_tr*W;   
    C_ts = pinv(W)*EMG_Test;
    EMG_Recos_ts = C_ts*W;
    
    %% FORCE RECONSTRUCTION (TO DO: INCLUDERE SIMULAZIONE CON DATI DI TRAIN E TEST)
    H = FORCE_Train/C_tr;
    convMatrix{1,h} = H;
    FORCE_Recos_tr = H*FORCE_Train;
    FORCE_Recos_ts = H*FORCE_Test;

    %% PERFORMANCE
    [mse_emg_tr, rmse_emg_tr, r2_emg_tr] = dataPerformance(EMG_Train, EMG_Recos_tr);
    [mse_emg_ts, rmse_emg_ts, r2_emg_ts] = dataPerformance(EMG_Test, EMG_Recos_ts);
    [mse_frc_tr, rmse_frc_tr, r2_frc_tr] = dataPerformance(FORCE_Train, FORCE_Recos_tr);
    [mse_frc_ts, rmse_frc_ts, r2_frc_ts] = dataPerformance(FORCE_Test, FORCE_Recos_ts);
    
    % Inserting into vectors
    MSE_emg_tr(1,h) = mse_emg_tr;
    MSE_frc_tr(1,h) = mse_frc_tr;
    RMSE_emg_tr(1,h) = rmse_emg_tr;
    RMSE_frc_tr(1,h) = rmse_frc_tr;
    R2_emg_tr(1,h) = r2_emg_tr;
    R2_frc_tr(1,h) = r2_frc_tr;
    MSE_emg_ts(1,h) = mse_emg_ts;
    MSE_frc_ts(1,h) = mse_frc_ts;
    RMSE_emg_ts(1,h) = rmse_emg_ts;
    RMSE_frc_ts(1,h) = rmse_frc_ts;
    R2_emg_ts(1,h) = r2_emg_ts;
    R2_frc_ts(1,h) = r2_frc_ts;

end

%% SAVING
NNMFsim.synMatrix   = synMatrix;
NNMFsim.convMatrix  = convMatrix;
NNMFsim.MSE_emg_tr  = MSE_emg_tr;
NNMFsim.MSE_frc_tr  = MSE_frc_tr;
NNMFsim.RMSE_emg_tr = RMSE_emg_tr;
NNMFsim.RMSE_frc_tr = RMSE_frc_tr;
NNMFsim.R2_emg_tr   = R2_emg_tr;
NNMFsim.R2_frc_tr   = R2_frc_tr;
NNMFsim.MSE_emg_ts  = MSE_emg_ts;
NNMFsim.MSE_frc_ts  = MSE_frc_ts;
NNMFsim.RMSE_emg_ts = RMSE_emg_ts;
NNMFsim.RMSE_frc_ts = RMSE_frc_ts;
NNMFsim.R2_emg_ts   = R2_emg_ts;
NNMFsim.R2_frc_ts   = R2_frc_ts;

end