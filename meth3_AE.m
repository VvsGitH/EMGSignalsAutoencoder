function AEsim = meth3_AE(EMG, FORCE, maxEMG, indVect, maxEpochs)

TI = indVect(1); VI = indVect(2);
END = length(EMG);
[EMG_Train, ~, EMG_Test] = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[FORCE_Train, ~, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

%% TRAINING/SIMULATION LOOP

MSE_emg_tr  = zeros(1,10); MSE_frc_tr     = zeros(1,10);
RMSE_emg_tr = zeros(1,10); RMSE_frc_tr    = zeros(1,10);
R2_emg_tr   = zeros(1,10); R2_frc_tr      = zeros(1,10);
MSE_emg_ts  = zeros(1,10); MSE_frc_ts     = zeros(1,10);
RMSE_emg_ts = zeros(1,10); RMSE_frc_ts    = zeros(1,10);
R2_emg_ts   = zeros(1,10); R2_frc_ts      = zeros(1,10);
trainedNet  = cell(1,10);  trainingReport = cell(1,10);
convMatrix  = cell(1,10);

parfor h = 1:10
    
    net = netAutoEncoder(h, EMG, maxEpochs, indVect); % divideind
    
    %% TRAINING
    fprintf('       H%d: Training\n',h);
    [trNet, tr] = train(net,EMG,EMG,'useParallel','no');
    trainedNet{1,h} = trNet;
    trainingReport{1,h} = tr;
    
    %% SIMULATION (TO DO: INCLUDERE SIMULAZIONE CON DATI DI TRAIN E TEST)
    fprintf('       H%d: Simulation\n',h);
    EMG_Recos_tr = trNet(EMG_Train,'useParallel','no');
    EMG_Recos_ts = trNet(EMG_Test,'useParallel','no');
    
    %% FORCE RECONSTRUCTION (TO DO: INCLUDERE SIMULAZIONE CON DATI DI TRAIN E TEST)
    inputWeigths = cell2mat(trNet.IW);
    S_Train = poslin(inputWeigths*EMG_Train); % tf -> poslin
    Hae = FORCE_Train/S_Train;
    FORCE_Recos_tr = Hae*S_Train;
    convMatrix{1,h} = Hae;
    S_Test = poslin(inputWeigths*EMG_Test); % tf -> poslin
    FORCE_Recos_ts = Hae*S_Test;
    
    %% PERFORMANCE (TO DO: INCLUDERE SIMULAZIONE CON DATI DI TRAIN E TEST)
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
AEsim.trainedNet = trainedNet;
AEsim.trainingReport = trainingReport;
AEsim.emgToForceMatrix = convMatrix;
AEsim.MSE_emg_tr = MSE_emg_tr;
AEsim.MSE_frc_tr = MSE_frc_tr;
AEsim.RMSE_emg_tr = RMSE_emg_tr;
AEsim.RMSE_frc_tr = RMSE_frc_tr;
AEsim.R2_emg_tr = R2_emg_tr;
AEsim.R2_frc_tr = R2_frc_tr;
AEsim.MSE_emg_ts = MSE_emg_ts;
AEsim.MSE_frc_ts = MSE_frc_ts;
AEsim.RMSE_emg_ts = RMSE_emg_ts;
AEsim.RMSE_frc_ts = RMSE_frc_ts;
AEsim.R2_emg_ts = R2_emg_ts;
AEsim.R2_frc_ts = R2_frc_ts;

end

