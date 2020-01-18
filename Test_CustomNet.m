close all
clc
clearvars
rng('default')
pool = gcp;

%% SETTING UP
fprintf('Loading Data...\n');
load TrainDataSet
trSogg = 1;
EMG_Train = TrainDataSet{trSogg,1}.emg;
FORCE_Train = TrainDataSet{trSogg,1}.force;

load TestDataSet
tsSogg = trSogg;
EMG_Test = TestDataSet{tsSogg,1}.emg;
FORCE_Test = TestDataSet{tsSogg,1}.force;

%% CONFIGURING CUSTOM NET
fprintf('Generating Net...\n');
hiddenSize = 6;

% Define topology
net = feedforwardnet(hiddenSize);
net.biasConnect = [0;1];    % Il layer d'uscita EMG ha un bias

% Set net functions
net.trainFcn = 'trainscg'; %'trainlm': Jacobian - not supported by GPU; % 'trainscg': Scalar Conjugate Gradient - better for GPU
net.performFcn = 'mse'; % Mean Square Error
net.divideFcn = 'dividetrain'; % Assegna tutti i valori al train
net.layers{1}.transferFcn = 'elliotsig'; %'elliotsig' = n / (1 + abs(n)) - better for GPU; 'tansig' = 2/(1+exp(-2*n))-1
net.layers{2}.transferFcn = 'purelin';

% Configuring net for input and output dimensions
net = configure(net,EMG_Train,EMG_Train);

% Set values for labels
net.name = 'Autoencoder';
net.layers{1}.name = 'Encoder';
net.layers{2}.name = 'Decoder';

view(net)

%% TRAINING
fprintf('Training...\n');
net.trainParam.epochs = 10000;
net.trainParam.min_grad = 0;
net.trainParam.goal = 1e-05;
net.trainParam.showWindow = 1;
[trNet, tr] = train(net,EMG_Train,EMG_Train,'useParallel','yes'); 

%% SIMULATION
fprintf('Simulation...\n');
EMG_Recos = trNet(EMG_Test,'useParallel','yes');

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
MSE_emg = perform(trNet,EMG_Test, EMG_Recos);
RMSE_emg = sqrt(MSE_emg);
fprintf('   The mse is: %d\n   The RMSE is: %d\n',MSE_emg,RMSE_emg);
R2_emg = r_squared(EMG_Test, EMG_Recos);
fprintf('   The R2 is: %d\n', R2_emg);

% Performance for the reconstruction of Forces
fprintf('FORCE: Calculating performance indexes...\n')
e = gsubtract(FORCE_Test, FORCE_Recos);
MSE_frc = mean(e.^2,'all');
RMSE_frc = sqrt(MSE_frc);
fprintf('   The mse is: %d\n   The RMSE is: %d\n',MSE_frc,RMSE_frc);
R2_frc = r_squared(FORCE_Test, FORCE_Recos);
fprintf('   The R2 is: %d\n', R2_frc);

%% Saving
fprintf('Saving...\n');
AEsim.trainedNet = trNet;
AEsim.trainingReport = tr;
AEsim.emgToForceMatrix = Hae;
AEsim.MSE_emg = MSE_emg;
AEsim.MSE_frc = MSE_frc;
AEsim.RMSE_emg = RMSE_emg;
AEsim.RMSE_frc = RMSE_frc;
AEsim.R2_emg = R2_emg;
AEsim.R2_frc = R2_frc;
filename = ['AESim_sbj', num2str(trSogg), '_n', num2str(hiddenSize), '.mat'];
save(filename,'AEsim');

%% PLOTTING
fprintf('Plotting the comparison...\n');
t1 = 1:1:size(EMG_Test,2);
t2 = 1:1:size(EMG_Recos,2);
figure(1)
for i = 1:10
    subplot(4,3,i)
    plot(t1,EMG_Test(i,:),'b');
    hold on
    plot(t2,EMG_Recos(i,:),'r');
end
figure(2)
for i = 1:6
    subplot(2,3,i)
    plot(t1,FORCE_Test(i,:),'b');
    hold on
    plot(t2,FORCE_Recos(i,:),'r');
end


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
 