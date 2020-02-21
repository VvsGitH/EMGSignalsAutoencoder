%% AutoEncoder neural network Method
% EMG recostruction by neural network
% FORCE estimation with linear synergy based model Hae

function AEsim = meth3_AE(EMG, FORCE, maxEMG, indVect, maxEpochs)

TI = indVect(1); VI = indVect(2);
END = length(EMG);
[EMG_Train, ~, EMG_Test] = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[FORCE_Train, ~, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

%% TRAINING/SIMULATION LOOP
MSE_emg_tr  = zeros(10,1); MSE_frc_tr  = zeros(10,1);
RMSE_emg_tr = zeros(10,1); RMSE_frc_tr = zeros(10,1);
R2_emg_tr   = zeros(10,1); R2_frc_tr   = zeros(10,1);
MSE_emg_ts  = zeros(10,1); MSE_frc_ts  = zeros(10,1);
RMSE_emg_ts = zeros(10,1); RMSE_frc_ts = zeros(10,1);
R2_emg_ts   = zeros(10,1); R2_frc_ts   = zeros(10,1);
trainedNet  = cell(10,1); 
convMatrix  = cell(10,1);

parfor h = 1:10
    
    net = netAutoEncoder(h, EMG, maxEpochs, indVect);
    
    %% TRAINING
    fprintf('       S%d: Training\n',h);
    [trNet, ~] = train(net,EMG,EMG,'useParallel','no');
    trainedNet{h,1} = trNet;
    
    %% SIMULATION
    fprintf('       S%d: Simulation\n',h);
    EMG_Recos_tr = trNet(EMG_Train,'useParallel','no'); % Recostruction of train EMG
    EMG_Recos_ts = trNet(EMG_Test,'useParallel','no');  % Recostruction of test EMG
    
    %% FORCE RECONSTRUCTION
    inputWeigths = cell2mat(trNet.IW);
    S_Train = poslin(inputWeigths*EMG_Train); % Train synergy activation matrix
    Hae = FORCE_Train*pinv(S_Train);          % Synergies to force conversion matrix (LQ)
    convMatrix{h,1} = Hae;
    FORCE_Recos_tr = Hae*S_Train;             % Recostruction of train forces
    S_Test = poslin(inputWeigths*EMG_Test);   % Test synergy activation matrix
    FORCE_Recos_ts = Hae*S_Test;              % Recostruction of train forces
    
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
AEsim.trainedNet     = trainedNet;
AEsim.convMatrix     = convMatrix;
AEsim.Train.MSE_emg  = MSE_emg_tr;
AEsim.Train.RMSE_emg = RMSE_emg_tr;
AEsim.Train.R2_emg   = R2_emg_tr;
AEsim.Train.MSE_frc  = MSE_frc_tr;
AEsim.Train.RMSE_frc = RMSE_frc_tr;
AEsim.Train.R2_frc   = R2_frc_tr;
AEsim.Test.MSE_emg   = MSE_emg_ts;
AEsim.Test.RMSE_emg  = RMSE_emg_ts;
AEsim.Test.R2_emg    = R2_emg_ts;
AEsim.Test.MSE_frc   = MSE_frc_ts;
AEsim.Test.RMSE_frc  = RMSE_frc_ts;
AEsim.Test.R2_frc    = R2_frc_ts;

end