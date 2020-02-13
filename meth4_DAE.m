function DAEsim = meth4_DAE(EMG, FORCE, maxEMG, maxForce, indVect, maxEpochs)

TI = indVect(1); VI = indVect(2);
END = length(EMG);
[~, ~, EMG_Test] = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[~, ~, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

%% TRAINING/SIMULATION LOOP
MSE_emg_tr  = zeros(1,10); MSE_frc_tr     = zeros(1,10);
RMSE_emg_tr = zeros(1,10); RMSE_frc_tr    = zeros(1,10);
R2_emg_tr   = zeros(1,10); R2_frc_tr      = zeros(1,10);
MSE_emg_ts  = zeros(1,10); MSE_frc_ts     = zeros(1,10);
RMSE_emg_ts = zeros(1,10); RMSE_frc_ts    = zeros(1,10);
R2_emg_ts   = zeros(1,10); R2_frc_ts      = zeros(1,10);
trainedNet = cell(1,10);  trainingReport = cell(1,10);

parfor h = 1:10
    
    net = netDoubleAutoEncoder(h, EMG, FORCE, maxEpochs, indVect); % divideind
    
    %% TRAINING
    fprintf('       H%d: Training\n',h);
    [trNet, tr] = train(net,EMG,[EMG; FORCE],'useParallel','no');
    trainedNet{1,h} = trNet;
    trainingReport{1,h} = tr;
    
    %% SIMULATION
    fprintf('       H%d: Simulation\n',h);
    XRecos = trNet(EMG_Train,'useParallel','no');
    EMG_Recos_tr = XRecos(1:10,:);
    FORCE_Recos_tr = XRecos(11:16,:);
    XRecos = trNet(EMG_Test,'useParallel','no');
    EMG_Recos_ts = XRecos(1:10,:);
    FORCE_Recos_ts = XRecos(11:16,:);
    
    %% PERFORMANCE
    % Different normalization for output balance
    [r_emg, r_frc] = netDAEoutputNorm(EMG, FORCE);
    
    % Performance for the reconstruction of EMG signal
    EMG_Train_den    = dataDenormalize(EMG_Train,0,r_emg,maxEMG);
    EMG_Test_den     = dataDenormalize(EMG_Test,0,r_emg,maxEMG);
	EMG_Recos_tr_den = dataDenormalize(EMG_Recos_tr,0,r_emg,maxEMG);
    EMG_Recos_ts_den = dataDenormalize(EMG_Recos_ts,0,r_emg,maxEMG);
    [mse_emg_tr, rmse_emg_tr, r2_emg_tr] = dataPerformance(EMG_Train_den, EMG_Recos_tr_den);
    [mse_emg_ts, rmse_emg_ts, r2_emg_ts] = dataPerformance(EMG_Test_den, EMG_Recos_ts_den);
     
    % Performance for the reconstruction of Forces
    FORCE_Train_den = dataDenormalize(FORCE_Train,0,r_frc,maxForce);
    FORCE_Test_den  = dataDenormalize(FORCE_Test,0,r_frc,maxForce);
    FORCE_Recos_tr_den = dataDenormalize(FORCE_Recos_tr,0,r_frc,maxForce);
    FORCE_Recos_ts_den = dataDenormalize(FORCE_Recos_ts,0,r_frc,maxForce);
    [mse_frc_tr, rmse_frc_tr, r2_frc_tr] = dataPerformance(FORCE_Train_den, FORCE_Recos_tr_den);
    [mse_frc_ts, rmse_frc_ts, r2_frc_ts] = dataPerformance(FORCE_Test_den, FORCE_Recos_ts_den);
    
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
DAEsim.trainedNet = trainedNet;
DAEsim.trainingReport = trainingReport;
DAEsim.MSE_emg_tr = MSE_emg_tr;
DAEsim.MSE_frc_tr = MSE_frc_tr;
DAEsim.RMSE_emg_tr = RMSE_emg_tr;
DAEsim.RMSE_frc_tr = RMSE_frc_tr;
DAEsim.R2_emg_tr = R2_emg_tr;
DAEsim.R2_frc_tr = R2_frc_tr;
DAEsim.MSE_emg_ts = MSE_emg_ts;
DAEsim.MSE_frc_ts = MSE_frc_ts;
DAEsim.RMSE_emg_ts = RMSE_emg_ts;
DAEsim.RMSE_frc_ts = RMSE_frc_ts;
DAEsim.R2_emg_ts = R2_emg_ts;
DAEsim.R2_frc_ts = R2_frc_ts;

end

