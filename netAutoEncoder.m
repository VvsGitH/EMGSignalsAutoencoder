function net = netAutoEncoder(hiddenSize, inputData, maxEpochs, minMse, showWindow)

% Define topology
net = feedforwardnet(hiddenSize);
net.biasConnect = [0;1];    % Il layer d'uscita EMG ha un bias

% Set net functions
net.trainFcn = 'trainscg'; %'trainlm': Jacobian - not supported by GPU; % 'trainscg': Scalar Conjugate Gradient - better for GPU
net.performFcn = 'mse'; % Mean Square Error
net.divideFcn = 'dividetrain'; % Assegna tutti i valori al train
net.layers{1}.transferFcn = 'poslin'; %'elliotsig' = n / (1 + abs(n)) - better for GPU; 'tansig' = 2/(1+exp(-2*n))-1
net.layers{2}.transferFcn = 'purelin';

% Net configuration
net = configure(net,inputData, inputData);

% Set values for labels
net.name = 'Autoencoder';
net.layers{1}.name = 'Encoder';
net.layers{2}.name = 'Decoder';

% Training Parameters
net.trainParam.epochs = maxEpochs;
net.trainParam.min_grad = 0;
net.trainParam.goal = minMse;
net.trainParam.showWindow = showWindow;

end