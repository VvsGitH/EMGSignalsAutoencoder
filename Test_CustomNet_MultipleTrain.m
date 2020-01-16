close all
clc
clearvars

%% SETTING UP
fprintf('Loading Data...\n');

load TrainDataSet
trSogg = 10;
X = TrainDataSet{trSogg,1}.emg;

load TestDataSet
tsSogg = trSogg;
T = TestDataSet{tsSogg,1}.emg;

%% TRAINING/SIMULATION LOOP

MSE = zeros(10,1); RMSE = zeros(10,1); R2 = zeros(10,2); 
trainedNet = cell(10,1); trainingReport = cell(10,1);
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
net.trainParam.min_grad = 1e-07;
net.trainParam.goal = 1e-05;
net = configure(net,X,X); % Configure net for the standard Dataset

%% TRAINING
fprintf('Training...\n');
[trNet, tr] = train(net,X,X); 

%% SIMULATION
fprintf('Simulation...\n');
XRecos = trNet(T);

%% PERFORMANCE 
%%%%%%%%% AGGIUNGERE STIMA DELLA FORZA!!! %%%%%%%%%%%
fprintf('Calculating performance indexes...\n')
mse = perform(trNet,T, XRecos);
rmse = sqrt(mse);
fprintf('  The mse is: %d\n  The RMSE is: %d\n',mse,rmse);
r2 = r_squared(T, XRecos);
fprintf('  The R2 is: %d\n', r2);

% Inserting into vectors
trainedNet{h,1} = trNet;
trainingReport{h,1} = tr;
MSE(h) = mse;
RMSE(h) = rmse;
R2(h) = r2;

clear mse rmse r2 XRecos net

end

%% SAVING
fprintf('Saving...\n');
filename = ['AESim_sbj', num2str(trSogg), '_allSizes.mat'];
save(filename,'MSE', 'RMSE', 'R2', 'trainedNet', 'trainingReport');

%% PLOTTING
fprintf('Plotting...')
s = 1:10;
subplot(3,1,1)
plot(s,MSE), title('MSE');
subplot(3,1,2)
plot(s,RMSE), title('RMSE');
subplot(3,1,3)
plot(s,R2), title('R2');


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