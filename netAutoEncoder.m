function net = netAutoEncoder(hiddenSize, inputData, maxEpochs, indVect)

% Define topology
net = feedforwardnet(hiddenSize);
net.biasConnect = [0;1];    % Il layer d'uscita EMG ha un bias

% Set values for labels
net.name = 'Autoencoder';
net.layers{1}.name = 'Encoder';
net.layers{2}.name = 'Decoder';

% Net data configuration
if nargin == 3
    net.divideFcn = 'dividetrain'; % Assegna tutti i valori al train
else
    net.divideFcn = 'divideind';  % 'dividetrain': Assegna tutti i valori al train
    net.divideParam.trainInd = 1:indVect(1)-1;
    net.divideParam.testInd  = indVect(1):indVect(2)-1;
    net.divideParam.valInd   = indVect(2):indVect(3);
end
net = configure(net,inputData, inputData);

% Set net functions
net.trainFcn = 'traingda'; %'traingda': Gradient Descent with adaptive learning rate %'trainlm': Jacobian derivatives - not supported by GPU; % 'trainscg': Scalar Conjugate Gradient - better for GPU
net.performFcn = 'mse'; % Mean Square Error
net.performParam.regularization = 0; % Minimize only error
net.performParam.normalization = 'none'; % Take the error as it is
net.layers{1}.transferFcn = 'poslin'; %'elliotsig' = n / (1 + abs(n)) - better for GPU; 'tansig' = 2/(1+exp(-2*n))-1
net.layers{2}.transferFcn = 'purelin';

% Training Parameters
net.trainParam.epochs     = maxEpochs;
net.trainParam.min_grad   = 1e-07;
net.trainParam.goal       = 1e-05;
net.trainParam.max_fail   = 50;
net.trainParam.showWindow = 1;

end