function DAEsim = meth4_DAE(EMG, FORCE, maxEMG, maxForce, indVect, maxEpochs)

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
trainedNet = cell(1,10);  trainingReport = cell(1,10);

parfor h = 1:10
    
    net = netDoubleAutoEncoder(h, EMG, FORCE, maxEpochs, indVect); % divideind
    
    %% TRAINING
    fprintf('       S%d: Training\n',h);
    [trNet, tr] = train(net,EMG,[EMG; FORCE],'useParallel','no');
    trainedNet{h,1} = trNet;
    trainingReport{h,1} = tr;
    
    %% SIMULATION
    fprintf('       S%d: Simulation\n',h);
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
    FORCE_Train_den    = dataDenormalize(FORCE_Train,0,r_frc,maxForce);
    FORCE_Test_den     = dataDenormalize(FORCE_Test,0,r_frc,maxForce);
	FORCE_Recos_tr_den = dataDenormalize(FORCE_Recos_tr,0,r_frc,maxForce);
    FORCE_Recos_ts_den = dataDenormalize(FORCE_Recos_ts,0,r_frc,maxForce);
    [mse_frc_tr, rmse_frc_tr, r2_frc_tr] = dataPerformance(FORCE_Train_den, FORCE_Recos_tr_den);
    [mse_frc_ts, rmse_frc_ts, r2_frc_ts] = dataPerformance(FORCE_Test_den, FORCE_Recos_ts_den);
    
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
DAEsim.trainedNet     = trainedNet;
DAEsim.trainingReport = trainingReport;
DAEsim.Train.MSE_emg  = MSE_emg_tr;
DAEsim.Train.RMSE_emg = RMSE_emg_tr;
DAEsim.Train.R2_emg   = R2_emg_tr;
DAEsim.Train.MSE_frc  = MSE_frc_tr;
DAEsim.Train.RMSE_frc = RMSE_frc_tr;
DAEsim.Train.R2_frc   = R2_frc_tr;
DAEsim.Test.MSE_emg   = MSE_emg_ts;
DAEsim.Test.RMSE_emg  = RMSE_emg_ts;
DAEsim.Test.R2_emg    = R2_emg_ts;
DAEsim.Test.MSE_frc   = MSE_frc_ts;
DAEsim.Test.RMSE_frc  = RMSE_frc_ts;
DAEsim.Test.R2_frc    = R2_frc_ts;

end

