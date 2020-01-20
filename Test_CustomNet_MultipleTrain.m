close all
clc
clearvars
rng('default')
pool = gcp;

%% SETTING UP
fprintf('Loading Data...\n');
load TrainDataSet
load TestDataSet
trSogg = 1;
EMG_Train = TrainDataSet{trSogg,1}.emg;
FORCE_Train = TrainDataSet{trSogg,1}.force;
EMG_Test = TestDataSet{trSogg,1}.emg;
FORCE_Test = TestDataSet{trSogg,1}.force;

%% TRAINING/SIMULATION LOOP
MSE_emg = zeros(1,10); MSE_frc = zeros(1,10);
RMSE_emg = zeros(1,10); RMSE_frc = zeros(1,10);
R2_emg = zeros(1,10); R2_frc = zeros(1,10);
trainedNet = cell(1,10); trainingReport = cell(1,10);
emgToForceMatrix = cell(1,10);
emgPlot = cell(1,10); frcPlot = cell(1,10);

parfor h = 1:4
    %% CONFIG NET
    fprintf('H=%d - Generating Net...\n',h);
    net = feedforwardnet(h);
    net.name = 'Autoencoder';
    net.layers{1}.name = 'Encoder';
    net.layers{2}.name = 'Decoder';
    net.biasConnect = [0;1];    % Il layer d'uscita EMG ha un bias
    net.trainFcn = 'trainscg'; %'trainlm': Jacobian - not supported by GPU; % 'trainscg': Scalar Conjugate Gradient - better for GPU
    net.performFcn = 'mse'; % Mean Square Error
    net.divideFcn = 'dividetrain'; % Assegna tutti i valori al train
    net.layers{1}.transferFcn = 'poslin'; %'elliotsig' = n / (1 + abs(n)) - better for GPU; 'tansig' = 2/(1+exp(-2*n))-1
    net.layers{2}.transferFcn = 'purelin';
    net = configure(net,EMG_Train,EMG_Train); % Configure net for the standard Dataset
    
    %% TRAINING
    fprintf('H=%d - Training...\n',h);
    net.trainParam.epochs = 100;
    net.trainParam.min_grad = 0;
    net.trainParam.goal = 1e-05;
    net.trainParam.showWindow=0;
    [trNet, tr] = train(net,EMG_Train,EMG_Train,'useParallel','no');
    trainedNet{1,h} = trNet;
    trainingReport{1,h} = tr;
    
    %% SIMULATION
    fprintf('H=%d - Simulation...\n',h);
    EMG_Recos = trNet(EMG_Test,'useParallel','no');
    
    %% FORCE RECONSTRUCTION
    fprintf('H=%d - Force Reconstruction...\n',h);
    inputWeigths = cell2mat(trNet.IW);
    S_Train = elliotsig(inputWeigths*EMG_Train);
    Hae = FORCE_Train*pinv(S_Train);
    emgToForceMatrix{1,h} = Hae;
    S_Test = elliotsig(inputWeigths*EMG_Test);
    FORCE_Recos = Hae*S_Test;
    
    %% PERFORMANCE
    % Performance for the reconstruction of EMG signal
    fprintf('H=%d - EMG: Calculating performance indexes...\n',h)
    mse_emg = perform(trNet,EMG_Test, EMG_Recos);
    rmse_emg = sqrt(mse_emg);
    fprintf('   The mse is: %d\n   The RMSE is: %d\n',mse_emg,rmse_emg);
    r2_emg = r_squared(EMG_Test, EMG_Recos);
    fprintf('   The R2 is: %d\n', r2_emg);
    
    % Performance for the reconstruction of Forces
    fprintf('H=%d - FORCE: Calculating performance indexes...\n',h)
    e = gsubtract(FORCE_Test, FORCE_Recos);
    mse_frc = mean(e.^2,'all');
    rmse_frc = sqrt(mse_frc);
    fprintf('   The mse is: %d\n   The RMSE is: %d\n',mse_frc,rmse_frc);
    r2_frc = r_squared(FORCE_Test, FORCE_Recos);
    fprintf('   The R2 is: %d\n', r2_frc);
    
    % Inserting into vectors
    MSE_emg(1,h) = mse_emg;
    MSE_frc(1,h) = mse_frc;
    RMSE_emg(1,h) = rmse_emg;
    RMSE_frc(1,h) = rmse_frc;
    R2_emg(1,h) = r2_emg;
    R2_frc(1,h) = r2_frc;
    
    %% PLOTTING SIGNALS
    fprintf('H=%d - Plotting Signals...\n',h)
    t1 = 1:1:size(EMG_Test,2);
    t2 = 1:1:size(EMG_Recos,2);
    emgPlot{1,h} = figure('visible','off');
    for i = 1:10
        subplot(4,3,i)
        plot(t1,EMG_Test(i,:),'b');
        hold on
        plot(t2,EMG_Recos(i,:),'r');
    end
    frcPlot{1,h} = figure('visible','off');
    for i = 1:6
        subplot(2,3,i)
        plot(t1,FORCE_Test(i,:),'b');
        hold on
        plot(t2,FORCE_Recos(i,:),'r');
    end
end

%% SAVING
fprintf('Saving...\n');
AEsim.subject = trSogg;
AEsim.trainedNet(trSogg,:) = trainedNet;
AEsim.trainingReport(trSogg,:) = trainingReport;
AEsim.emgToForceMatrix(trSogg,:) = emgToForceMatrix;
AEsim.emgPlot(trSogg,:) = emgPlot;
AEsim.frcPlot(trSogg,:) = frcPlot;
AEsim.MSE_emg(trSogg,:) = MSE_emg;
AEsim.MSE_frc(trSogg,:) = MSE_frc;
AEsim.RMSE_emg(trSogg,:) = RMSE_emg;
AEsim.RMSE_frc(trSogg,:) = RMSE_frc;
AEsim.R2_emg(trSogg,:) = R2_emg;
AEsim.R2_frc(trSogg,:) = R2_frc;
filename = ['AEsim_sbj', num2str(trSogg), '_allSizes.mat'];
%save(filename,'AEsim');

%% PLOTTING
fprintf('Plotting Performance Indexes...\n')
h = 1:10;
perfPlot = figure('visible','on');
    subplot(2,3,1)
    plot(h,AEsim.MSE_emg(AEsim.subject,:)), title('EMG MSE');
    subplot(2,3,2)
    plot(h,AEsim.RMSE_emg(AEsim.subject,:)), title('EMG RMSE');
    subplot(2,3,3)
    plot(h,AEsim.R2_emg(AEsim.subject,:)), title('EMG R2');
    subplot(2,3,4)
    plot(h,AEsim.MSE_frc(AEsim.subject,:)), title('FORCE MSE');
    subplot(2,3,5)
    plot(h,AEsim.RMSE_frc(AEsim.subject,:)), title('FORCE RMSE');
    subplot(2,3,6)
    plot(h,AEsim.R2_frc(AEsim.subject,:)), title('FORCE R2');    

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