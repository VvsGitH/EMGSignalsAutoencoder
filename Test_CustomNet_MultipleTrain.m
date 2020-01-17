close all
clc
clearvars

%% SETTING UP
fprintf('Loading Data...\n');

load TrainDataSet
load TestDataSet

%% TRAINING/SIMULATION LOOP
AEsim.MSE_emg = zeros(40,10); AEsim.MSE_frc = zeros(40,10);
AEsim.RMSE_emg = zeros(40,10); AEsim.RMSE_frc = zeros(40,10);
AEsim.R2_emg = zeros(40,10); AEsim.R2_frc = zeros(40,10);
AEsim.trainedNet = cell(40,10); AEsim.trainingReport = cell(40,10);
AEsim.emgToForceMatrix = cell(40,10);

for trSogg = 1:40
    fprintf('      Subject = %d\n',trSogg);
    EMG_Train = TrainDataSet{trSogg,1}.emg;
    FORCE_Train = TrainDataSet{trSogg,1}.force;
    EMG_Test = TestDataSet{trSogg,1}.emg;
    FORCE_Test = TestDataSet{trSogg,1}.force;
    
    for h = 1:10
        fprintf('      H = %d\n',h);
        %% CUSTOM NET
        fprintf('Generating Net...\n');
        rng('default')
        hiddenSize = h;
        net = feedforwardnet(hiddenSize);
        net.name = 'Autoencoder';
        net.layers{1}.name = 'Encoder';
        net.layers{2}.name = 'Decoder';
        net.biasConnect = [0;1];    % Il layer d'uscita EMG ha un bias
        net.trainFcn = 'trainscg'; %'trainlm': Jacobian - not supported by GPU; % 'trainscg': Scalar Conjugate Gradient - better for GPU
        net.performFcn = 'mse'; % Mean Square Error
        net.divideFcn = 'dividetrain'; % Assegna tutti i valori al train
        net.layers{1}.transferFcn = 'elliotsig'; %'elliotsig' = n / (1 + abs(n)) - better for GPU; 'tansig' = 2/(1+exp(-2*n))-1
        net.layers{2}.transferFcn = 'purelin';
        net.trainParam.epochs = 1000;
        net.trainParam.min_grad = 0;
        net.trainParam.goal = 1e-05;
        net = configure(net,EMG_Train,EMG_Train); % Configure net for the standard Dataset
        
        %% TRAINING
        fprintf('Training...\n');
        [trNet, tr] = train(net,EMG_Train,EMG_Train);
        
        %% SIMULATION
        fprintf('Simulation...\n');
        EMG_Recos = trNet(EMG_Test);
        
        %% FORCE RECONSTRUCTION
        fprintf('Force Reconstruction...\n');
        inputWeigths = cell2mat(trNet.IW);
        S_Train = elliotsig(inputWeigths*EMG_Train);
        Hae = FORCE_Train*pinv(S_Train);
        
        S_Test = elliotsig(inputWeigths*EMG_Test);
        FORCE_Recos = Hae*S_Test;
        
        %% PERFORMANCE
        % Performance for the reconstruction of EMG signal
        fprintf('EMG: Calculating performance indexes...\n')
        mse_emg = perform(trNet,EMG_Test, EMG_Recos);
        rmse_emg = sqrt(mse_emg);
        fprintf('   The mse is: %d\n   The RMSE is: %d\n',mse_emg,rmse_emg);
        r2_emg = r_squared(EMG_Test, EMG_Recos);
        fprintf('   The R2 is: %d\n', r2_emg);
        
        % Performance for the reconstruction of Forces
        fprintf('FORCE: Calculating performance indexes...\n')
        e = gsubtract(FORCE_Test, FORCE_Recos);
        mse_frc = mean(e.^2,'all');
        rmse_frc = sqrt(mse_frc);
        fprintf('   The mse is: %d\n   The RMSE is: %d\n',mse_frc,rmse_frc);
        r2_frc = r_squared(FORCE_Test, FORCE_Recos);
        fprintf('   The R2 is: %d\n', r2_frc);
        
        % Inserting into vectors
        AESim.trainedNet{trSogg,h} = trNet;
        AESim.trainingReport{trSogg,h} = tr;
        AEsim.emgToForceMatrix{trSogg,h} = Hae;
        AESim.MSE_emg(trSogg,h) = mse_emg;
        AESim.MSE_frc(trSogg,h) = mse_frc;
        AESim.RMSE_emg(trSogg,h) = rmse_emg;
        AESim.RMSE_frc(trSogg,h) = rmse_frc;
        AESim.R2_emg(trSogg,h) = r2_emg;
        AESim.R2_frc(trSogg,h) = r2_frc;
        
        clear mse_emg mse_frc rmse_emg rmse_frc r2_emg r2_frc EMG_Recos FORCE_Recos net tr trNet Hae
        
    end
end
%% SAVING
fprintf('Saving...\n');
% Choose One
% filename = ['AESim_sbj', num2str(trSogg), '_allSizes.mat'];
filename = ['AESim_n', num2str(h), '_allSbjs.mat'];
save(filename,'AESim');

%% PLOTTING
% fprintf('Plotting...')
% s = 1:10;
% subplot(3,1,1)
% plot(s,MSE), title('MSE');
% subplot(3,1,2)
% plot(s,RMSE), title('RMSE');
% subplot(3,1,3)
% plot(s,R2), title('R2');


%% R2 FUNCTION
function [R2] = r_squared(targets, estimates)
    T = targets;
    Y = estimates;
    avgTargets = mean(T, 2);
    avgTargetsMatr = avgTargets .*ones(1,size(T,2));
    numerator = sum(sum((Y - T).^2));   %SSE
    denominator = sum(sum((T - avgTargetsMatr).^2));  %SST
    R2 = 1 - (numerator ./ denominator);
end