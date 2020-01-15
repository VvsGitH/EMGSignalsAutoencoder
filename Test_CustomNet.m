close all
clc
clearvars

%% SETTING UP
fprintf('Loading Data...\n');
load TrainDataSet
trSogg = 10;

X = TrainDataSet{trSogg,1}.emg;
clearvars -except X trSogg

% % Generating data for the Composite Multicore training
% pool = gcp;
% Xc = Composite();
% L = size(X,2)/pool.NumWorkers;
% Xc{1} = X(1:L);
% for i = 1:pool.NumWorkers-1
%     Xc{i+1} = X(L*i+1:L*i+L);
% end
% clearvars -except X Xc nsogg

% % Generating GPU arrays for the GPU training
% Xg = nndata2gpu(X);
% clearvars -except X Xg

% % Generatig mini-batches for GPU
% nBatch = 3;
% L = size(X,2)/nBatch;
% mini_Xg = cell(1,nBatch);
% mini_Xg{1} = nndata2gpu(X(1:L));
% for i = 1:nBatch-1
%     mini_Xg{i+1} = nndata2gpu(X(L*i+1:L*i+L));
% end
% clearvars -except X mini_Xg nBatch

%% CUSTOM NET
fprintf('Generating Net...\n');
rng('default')
hiddenSize = 5;
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
net.trainParam.epochs = 500;
net.trainParam.min_grad = 1e-04;
net = configure(net,X,X); % Configure net for the standard Dataset
% net = configure(net,Xc{1},Xc{1}); % Configure net for the Composite DataSet
view(net)

%% TRAINING
fprintf('Training...\n');

[trNet, tr] = train(net,X,X); 

% % Train Net with Multicore - CRASH
% net = train(net,X,X,'useParallel','yes');

% Train net with Composite Data with Multicore
% [trNet, tr] = train(net,Xc,Xc); 

% % Train Net with the GPU - OUT OF MEMORY
% net = train(net,Xg,Xg,'showResources','yes');

% % Train Net with GPU in mini batches -  CODE NOT WORKING
% net.trainParam.epochs = 1;
% for i = 1:100
%     for j = 1:nBatch
%         net = train(net, mini_Xg{j}, mini_Xg{j});
%     end
% end 

% save('CustomAutoencoder7n.mat','trNet','tr');

%% SIMULATION
fprintf('Training Complete\nSimulation...\n');
load TestDataSet
tsSogg = trSogg;
T = TestDataSet{tsSogg,1}.emg;
XRecos = trNet(T);
clearvars -except X T XRecos net trNet tr

%% PERFORMANCE
fprintf('Calculating performance indexes...\n')
e = gsubtract(T, XRecos);
mse = perform(trNet,T, XRecos);
RMSE = sqrt(mse);
fprintf('The mse is: %d\nThe RMSE is: %d\n',mse,RMSE);
R2 = r_squared(T, XRecos);
fprintf('The R2 is: %d\n', R2);

% Saving
performance.mse_emg = mse;
performance.RMSE_emg = RMSE;
performance.R2_emg = R2;
% save('Autoenc_7n.mat','trNet','performance');

%% PLOTTING
fprintf('Plotting the comparison...\n');
t1 = 1:1:size(T,2);
t2 = 1:1:size(XRecos,2);
for i = 1:10
    subplot(4,3,i)
    plot(t1,T(i,:),'b');
    hold on
    plot(t2,XRecos(i,:),'r');
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
 