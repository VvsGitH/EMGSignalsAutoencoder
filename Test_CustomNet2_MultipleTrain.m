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
FORCE_Train = abs(FORCE_Train);
FORCE_Train = normalize(FORCE_Train,2,'range');
EMG_Test = TestDataSet{trSogg,1}.emg;
FORCE_Test = TestDataSet{trSogg,1}.force;
FORCE_Test = abs(FORCE_Test);
FORCE_Test = normalize(FORCE_Test,2,'range');

%% TRAINING/SIMULATION LOOP
MSE_emg = zeros(1,10); MSE_frc = zeros(1,10);
RMSE_emg = zeros(1,10); RMSE_frc = zeros(1,10);
R2_emg = zeros(1,10); R2_frc = zeros(1,10);
trainedNet = cell(1,10); trainingReport = cell(1,10);    
    
parfor h = 1:10
    fprintf('      H = %d\n',h);    
    %% CONFIG NET
    fprintf('Configuring Net...\n');
    net = network;
    % Define topology
    net.numInputs = 1;
    net.numLayers = 3;
    net.biasConnect = [0;1;0];    % Il layer d'uscita EMG ha un bias
    net.inputConnect(1,1) = 1;
    net.layerConnect(2,1) = 1;
    net.layerConnect(3,1) = 1;
    net.outputConnect = [0,1,1];
    % Set up initialization options
    net.layers{1}.initFcn = 'initwb';
    net.layers{1}.size = h; % Numero di neuroni
    net.inputWeights{1,1}.initFcn = 'randsmall'; % Inizializzazione con piccoli valori casuali con segno
    net.biases{1}.initFcn = 'randsmall';
    net.layers{2}.initFcn = 'initwb';
    net.layerWeights{2,1}.initFcn = 'randsmall';
    net.biases{2}.initFcn = 'randsmall';
    net.initFcn = 'initlay'; % Chiama le funzioni di inizializzazione di ogni layer
    % Set net functions
    net.layers{1}.transferFcn = 'poslin';
    net.layers{2}.transferFcn = 'purelin';
    net.layers{3}.transferFcn = 'purelin';
    net.divideFcn = 'dividetrain'; %Assegna tutti i valori al train
    net.performFcn = 'mse'; % Imposta l'indice di performance come mse      %'msesparse'; % sse
    net.trainFcn = 'trainscg';  % Scalar Conjugate Gradient                  % trainbr, trainscg, traingdm, traingdx
    % Configuring net for input and output dimensions
    net = configure(net,'inputs',EMG_Train,1);
    net = configure(net,'outputs',EMG_Train,1);
    net = configure(net,'outputs',FORCE_Train,2);
    % Set values for labels
    net.name = 'Autoencoder';
    net.layers{1}.name = 'Encoder';
    net.layers{2}.name = 'Decoder1';
    net.layers{3}.name = 'Decoder2';
    
    %% TRAINING
    fprintf('Training...\n');
    net.trainParam.epochs = 1000;
    net.trainParam.min_grad = 0;
    net.trainParam.goal = 1e-05;
    net.trainParam.showWindow = 1;
    [trNet, tr] = train(net,EMG_Train,[EMG_Train; FORCE_Train],'useParallel','yes');
    trainedNet{1,h} = trNet;
    trainingReport{1,h} = tr;
    
    %% SIMULATION
    fprintf('Simulation...\n');
    XRecos = trNet(EMG_Test,'useParallel','yes');
    
    %% PERFORMANCE
    % Performance for the reconstruction of EMG signal
    fprintf('EMG: Calculating performance indexes...\n')
    mse_emg = perform(trNet,EMG_Test, XRecos(1:10,:));
    rmse_emg = sqrt(mse_emg);
    fprintf('   The mse is: %d\n   The RMSE is: %d\n',mse_emg,rmse_emg);
    r2_emg = r_squared(EMG_Test, XRecos(1:10,:));
    fprintf('   The R2 is: %d\n', r2_emg);
    
    % Performance for the reconstruction of Forces
    fprintf('FORCE: Calculating performance indexes...\n')
    mse_frc = perform(trNet,FORCE_Test, XRecos(11:16,:));
    rmse_frc = sqrt(mse_frc);
    fprintf('   The mse is: %d\n   The RMSE is: %d\n',mse_frc,rmse_frc);
    r2_frc = r_squared(FORCE_Test, XRecos(11:16,:));
    fprintf('   The R2 is: %d\n', r2_frc);
    
    % Inserting into vectors
    MSE_emg(1,h) = mse_emg;
    MSE_frc(1,h) = mse_frc;
    RMSE_emg(1,h) = rmse_emg;
    RMSE_frc(1,h) = rmse_frc;
    R2_emg(1,h) = r2_emg;
    R2_frc(1,h) = r2_frc;
    
end
%% SAVING
fprintf('Saving...\n');
DAEsim.subject = trSogg;
DAEsim.trainedNet(trSogg,:) = trainedNet;
DAEsim.trainingReport(trSogg,:) = trainingReport;
DAEsim.MSE_emg(trSogg,:) = MSE_emg;
DAEsim.MSE_frc(trSogg,:) = MSE_frc;
DAEsim.RMSE_emg(trSogg,:) = RMSE_emg;
DAEsim.RMSE_frc(trSogg,:) = RMSE_frc;
DAEsim.R2_emg(trSogg,:) = R2_emg;
DAEsim.R2_frc(trSogg,:) = R2_frc;
filename = ['DAEsim_sbj', num2str(trSogg), '_allSizes.mat'];
save(filename,'DAEsim');

%% PLOTTING
% fprintf('Plotting...\n')
% h = 1:10;
% subplot(2,3,1)
% plot(h,DAESim.MSE_emg(trSogg,:)), title('EMG MSE');
% subplot(2,3,2)
% plot(h,DAESim.RMSE_emg(trSogg,:)), title('EMG RMSE');
% subplot(2,3,3)
% plot(h,DAESim.R2_emg(trSogg,:)), title('EMG R2');
% subplot(2,3,4)
% plot(h,DAESim.MSE_frc(trSogg,:)), title('FORCE MSE');
% subplot(2,3,5)
% plot(h,DAESim.RMSE_frc(trSogg,:)), title('FORCE RMSE');
% subplot(2,3,6)
% plot(h,DAESim.R2_frc(trSogg,:)), title('FORCE R2');


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