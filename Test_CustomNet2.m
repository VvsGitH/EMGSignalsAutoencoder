close all
clc
clearvars

%% SETTING UP
fprintf('Loading Data...\n');
load TrainDataSet
nsogg = 30;
X = EMG_train(1:12*nsogg);
X2 = FORCE_train(1:12*nsogg);
T = [X; X2];

% Generating data for the Composite Multicore training
pool = gcp;
Xc = Composite(); X2c = Composite(); Tc = Composite();
L = size(X,2)/pool.NumWorkers;
M = size(X2,2)/pool.NumWorkers; %NB: L must be equal to M
Xc{1} = X(1:L); X2c{1} = X2(1:M); Tc{1} = T(:,1:L);
for i = 1:pool.NumWorkers-1
    Xc{i+1} = X(L*i+1:L*i+L);
    X2c{i+1} = X2(M*i+1:M*i+M);
    Tc{i+1} = T(:,L*i+1:L*i+L); 
end
clearvars -except Xc X2c Tc

% Example Data
% t = 1:0.01:100;
% for c = 1:10
%     X{c} = sin(t) + 0.3*randn(1,length(t));
%     X2{c} = 5*sin(t)./t + 0.3*randn(1,length(t));
% end
% T = [X; X2];
% X_test = sin(t) + 0.4*randn(1,length(t));
% X2_test = 5*sin(t)./t + 0.4*randn(1,length(t));

%% Network
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
net.inputWeights{1,1}.initFcn = 'randsmall'; % Inizializzazione con piccoli valori casuali con segno
net.biases{1}.initFcn = 'randsmall';

net.layers{2}.initFcn = 'initwb';
net.layerWeights{2,1}.initFcn = 'randsmall';
net.biases{2}.initFcn = 'randsmall';

net.initFcn = 'initlay'; % Chiama le funzioni di inizializzazione di ogni layer

% Set parameters
net.layers{1}.size = 7; % Numero di neuroni
net.layers{1}.transferFcn = 'elliotsig';
net.layers{2}.transferFcn = 'poslin';
net.layers{3}.transferFcn = 'poslin';
net.divideFcn = 'dividetrain'; %Assegna tutti i valori al train
net.performFcn = 'mse'; % Imposta l'indice di performance come mse      %'msesparse'; % sse
net.trainFcn = 'trainscg';  % Scalar Conjugate Gradient                  % trainbr, trainscg, traingdm, traingdx
net.trainParam.epochs = 100;
%net.trainParam.mu_max = 1e50;
net.trainParam.min_grad = 1e-10;
net.trainParam.max_fail = 5;

% Configuring net for input and output dimensions
% net = configure(net,'inputs',X,1);
% net = configure(net,'outputs',X,1);
% net = configure(net,'outputs',X2,2);
% net = configure(net,'inputs',Xc{1},1);
% net = configure(net,'outputs',Xc{1},1);
% net = configure(net,'outputs',X2c{1},2);

% Set values for labels
net.name = 'Autoencoder';
net.layers{1}.name = 'Encoder';
net.layers{2}.name = 'Decoder1';
net.layers{3}.name = 'Decoder2';

view(net)

%% TRAINING
fprintf('Training...\n');

% Train net with Composite Data with Multicore
[trNet, tr] = train(net,Xc,Tc,'showResources','yes'); 

% Saving
% save('CustomNLDoubleAutoencoder7n.mat','trNet', 'tr');

%% SIMULATION
fprintf('Simulation...\n');
load TestDataSet
XRecos = trNet(EMG_test);

%% PERFORMANCE
fprintf('Calculating performance indexes...\n')
e_emg = gsubtract(EMG_test, XRecos(1,:));
mse_emg = perform(trNet,EMG_test, XRecos(1,:));
RMSE_emg = sqrt(mse_emg);
e_frc = gsubtract(FORCE_test, XRecos(2,:));
mse_frc = perform(trNet,FORCE_test, XRecos(2,:));
RMSE_frc = sqrt(mse_frc);
fprintf('The mse for EMG is: %d\nThe RMSE for EMG is: %d\n',mse_emg,RMSE_emg);
fprintf('The mse for FORCE is: %d\nThe RMSE for FORCE is: %d\n',mse_frc,RMSE_frc);
R2_emg = r_squared(EMG_test, XRecos(1,:));
R2_frc = r_squared(FORCE_test, XRecos(2,:));
fprintf('The R2 for EMG is: %d\n', R2_emg);
fprintf('The R2 for FORCE is: %d\n', R2_frc);

% Saving
performance.mse_emg = mse_emg;
performance.mse_frc = mse_frc;
performance.RMSE_emg = RMSE_emg;
performance.RMSE_frc = RMSE_frc;
performance.R2_emg = R2_emg;
performance.R2_frc = R2_frc;
save('AutoencDb_pos_7n.mat','trNet', 'tr','performance');

%% PLOTTING
% fprintf('Plotting the comparison for one movement...\n');
% t = 1:1:size(EMG_test{1},2);
% for j = 1:5
%     sogg = j;
%     mov = 1;
%     rip = 1;
%     position = (sogg-1)*12 + (mov-1)*3 + rip;
%     figure(j);
%     for i = 1:12
%         subplot(4,3,i)
%         plot(t,EMG_test{position}(i,:),'b');
%         hold on 
%         plot(t,XRecos{1,position}(i,:),'r');
%     end
% end

%% R2 FUNCTION
function [R2] = r_squared(targets, estimates)
    T = cell2mat(targets);
    Y = cell2mat(estimates);
    avgTargets = mean(T, 2);
    avgTargetsMatr = avgTargets .*ones(1,size(T,2));
    numerator = sum(sum((Y - T).^2));   %SSE
    denominator = sum(sum((T - avgTargetsMatr).^2));  %SST
    R2 = 1 - (numerator ./ denominator);
end