function DAEsim = meth4_DAE(EMG, FORCE, maxEMG, maxForce, indVect, maxEpochs)

TI = indVect(1); VI = indVect(2);
END = length(EMG);
[~, ~, EMG_Test] = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[~, ~, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

%% TRAINING/SIMULATION LOOP
MSE_emg    = zeros(1,10); MSE_frc        = zeros(1,10);
RMSE_emg   = zeros(1,10); RMSE_frc       = zeros(1,10);
R2_emg     = zeros(1,10); R2_frc         = zeros(1,10);
trainedNet = cell(1,10);  trainingReport = cell(1,10);

parfor h = 1:10
    
    net = netDoubleAutoEncoder(h, EMG, FORCE, maxEpochs, indVect); % divideind
    
    %% TRAINING
    fprintf('       H%d: Training\n',h);
    [trNet, tr] = train(net,EMG,[EMG; FORCE],'useParallel','no');
    trainedNet{1,h} = trNet;
    trainingReport{1,h} = tr;
    
    %% SIMULATION (TO DO: INCLUDERE SIMULAZIONE CON DATI DI TRAIN E TEST)
    fprintf('       H%d: Simulation\n',h);
    XRecos = trNet(EMG_Test,'useParallel','no');
    EMG_Recos = XRecos(1:10,:);
    FORCE_Recos = XRecos(11:16,:);
    
    %% PERFORMANCE (TO DO: INCLUDERE SIMULAZIONE CON DATI DI TRAIN E TEST)
    % Different normalization for output balance
    [r_emg, r_frc] = netDAEoutputNorm(EMG, FORCE);
    
    % Performance for the reconstruction of EMG signal
    EMG_Test_den  = dataDenormalize(EMG_Test,0,r_emg,maxEMG);
	EMG_Recos_den = dataDenormalize(EMG_Recos,0,r_emg,maxEMG);
    [mse_emg, rmse_emg, r2_emg] = dataPerformance(EMG_Test_den, EMG_Recos_den);
     
    % Performance for the reconstruction of Forces
    FORCE_Test_den  = dataDenormalize(FORCE_Test,0,r_frc,maxForce);
    FORCE_Recos_den = dataDenormalize(FORCE_Recos,0,r_frc,maxForce);
    [mse_frc, rmse_frc, r2_frc] = dataPerformance(FORCE_Test_den, FORCE_Recos_den);
    
    % Inserting into vectors
    MSE_emg(1,h) = mse_emg;
    MSE_frc(1,h) = mse_frc;
    RMSE_emg(1,h) = rmse_emg;
    RMSE_frc(1,h) = rmse_frc;
    R2_emg(1,h) = r2_emg;
    R2_frc(1,h) = r2_frc;
    
end

%% SAVING
DAEsim.trainedNet = trainedNet';
DAEsim.trainingReport = trainingReport';
DAEsim.MSE_emg = MSE_emg';
DAEsim.MSE_frc = MSE_frc';
DAEsim.RMSE_emg = RMSE_emg';
DAEsim.RMSE_frc = RMSE_frc';
DAEsim.R2_emg = R2_emg';
DAEsim.R2_frc = R2_frc';

end