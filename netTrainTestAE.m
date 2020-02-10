function AEsim = netTrainTestAE(EMG, FORCE, maxEMG, indVect, maxEpochs)

TI = indVect(1); VI = indVect(2);
END = length(EMG);
[EMG_Train, ~, EMG_Test] = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[FORCE_Train, ~, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

%% TRAINING/SIMULATION LOOP
MSE_emg = zeros(1,10); MSE_frc = zeros(1,10);
RMSE_emg = zeros(1,10); RMSE_frc = zeros(1,10);
R2_emg = zeros(1,10); R2_frc = zeros(1,10);
trainedNet = cell(1,10); trainingReport = cell(1,10);
emgToForceMatrix = cell(1,10);

parfor h = 1:10
    
    net = netAutoEncoder(h, EMG, maxEpochs, indVect); % divideind
    
    %% TRAINING
    fprintf('       H%d: Training\n',h);
    [trNet, tr] = train(net,EMG,EMG,'useParallel','no');
    trainedNet{1,h} = trNet;
    trainingReport{1,h} = tr;
    
    %% SIMULATION
    fprintf('       H%d: Simulation\n',h);
    EMG_Recos = trNet(EMG_Test,'useParallel','no');
    
    %% FORCE RECONSTRUCTION
    inputWeigths = cell2mat(trNet.IW);
    S_Train = poslin(inputWeigths*EMG_Train); % tf -> poslin
    Hae = FORCE_Train*pinv(S_Train);
    emgToForceMatrix{1,h} = Hae;
    S_Test = poslin(inputWeigths*EMG_Test); % tf -> poslin
    FORCE_Recos = Hae*S_Test;
    
    %% PERFORMANCE
    % Performance for the reconstruction of EMG signal
    EMG_Test_den  = dataDenormalize(EMG_Test,0,1,maxEMG);
	EMG_Recos_den = dataDenormalize(EMG_Recos,0,1,maxEMG);
    [mse_emg, rmse_emg, r2_emg] = dataPerformance(EMG_Test_den, EMG_Recos_den);
    
    % Performance for the reconstruction of Forces
    [mse_frc, rmse_frc, r2_frc] = dataPerformance(FORCE_Test, FORCE_Recos);
    
    % Inserting into vectors
    MSE_emg(1,h) = mse_emg;
    MSE_frc(1,h) = mse_frc;
    RMSE_emg(1,h) = rmse_emg;
    RMSE_frc(1,h) = rmse_frc;
    R2_emg(1,h) = r2_emg;
    R2_frc(1,h) = r2_frc;
    
end

%% SAVING
AEsim.trainedNet = trainedNet';
AEsim.trainingReport = trainingReport';
AEsim.emgToForceMatrix = emgToForceMatrix';
AEsim.MSE_emg = MSE_emg';
AEsim.MSE_frc = MSE_frc';
AEsim.RMSE_emg = RMSE_emg';
AEsim.RMSE_frc = RMSE_frc';
AEsim.R2_emg = R2_emg';
AEsim.R2_frc = R2_frc';

end