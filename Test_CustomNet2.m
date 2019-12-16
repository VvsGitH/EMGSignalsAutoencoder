close all
clc
clearvars

%% SETTING UP
fprintf('Loading Data...\n');
load TrainDataSet
nsogg = 40;
X1 = EMG_train(1:12*nsogg);
X2 = FORCE_train(1:6*nsogg);

% Generating data for the Composite Multicore training
pool = gcp;
X1c = Composite(); X2c = Composite();
L = size(X1,2)/pool.NumWorkers;
M = size(X2,2)/pool.NumWorkers;
X1c{1} = X1(1:L); X2c{1} = X2(1:M);
for i = 1:pool.NumWorkers-1
    X1c{i+1} = X1(L*i+1:L*i+L);
    X2c{i+1} = X2(M*i+1:M*i+M);
end
clearvars -except X1 X2 X1c X2c

%% Network
net = network;

% Define topology
net.numInputs = 1;
net.numLayers = 3;
net.biasConnect = [0;0;1];    % Il terzo layer ha un bias % PERCHè???
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
net.layers{2}.transferFcn = 'purelin';
net.layers{3}.transferFcn = 'purelin';
net.divideFcn = 'dividetrain'; %Assegna tutti i valori al train
net.performFcn = 'mse'; % Imposta l'indice di performance come mse      %'msesparse'; % sse
net.trainFcn = 'trainscg';  % Scalar Conjugate Gradient                  % trainbr, trainscg, traingdm, traingdx
net.trainParam.epochs = 100;
%net.trainParam.mu_max = 1e50;
net.trainParam.min_grad = 1e-10;
net.trainParam.max_fail = 5;

% Configuring net for input and output dimensions
% net = configure(net,'inputs',X1,1);
% net = configure(net,'outputs',X1,1);
% net = configure(net,'outputs',X2,2);
net = configure(net,'inputs',X1c{1},1);
net = configure(net,'outputs',X1c{1},1);
net = configure(net,'outputs',X2c{1},2);

% Set values for labels
net.name = 'Autoencoder';
net.layers{1}.name = 'Encoder';
net.layers{2}.name = 'Decoder1';
net.layers{3}.name = 'Decoder2';

view(net)

%% TRAINING
fprintf('Training...\n');

% Train net with Composite Data with Multicore
net = train(net,X1c,[X1c X2c]); 

%% SIMULATION
fprintf('Training Complete\nSimulation...\n');
XRecos = net(X1);
disp(perform(net,XRecos,X1))