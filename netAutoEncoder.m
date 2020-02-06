function net = netAutoEncoder(hiddenSize, inputData, maxEpochs, indVect)

% Topology
net = feedforwardnet(hiddenSize);
net.biasConnect    = [0;1];    % Il layer d'uscita EMG ha un bias

% Labels and net names
net.name           = 'Autoencoder';
net.layers{1}.name = 'Encoder';
net.layers{2}.name = 'Decoder';

% Layers transfer functions
net.layers{1}.transferFcn       = 'poslin';
net.layers{2}.transferFcn       = 'purelin';

% Divide function
if nargin == 3
    net.divideFcn               = 'dividetrain';  % Assegna tutti i valori al train
else
    net.divideFcn               = 'divideind';    % 'dividetrain': Assegna tutti i valori al train
    net.divideParam.trainInd    = 1:indVect(1)-1;
    net.divideParam.testInd     = indVect(1):indVect(2)-1;
    net.divideParam.valInd      = indVect(2):indVect(3);
end

% Perform Settings
net.performFcn                  = 'mse';    % Mean Square Error
net.performParam.regularization = 0;        % Minimize only error
net.performParam.normalization  = 'none';   % Take the error as it is

% Training Settings
net.trainFcn                    = 'traingda';     %'traingda': Gradient Descent with adaptive learning rate 
net.trainParam.epochs           = maxEpochs;
net.trainParam.min_grad         = 0;
net.trainParam.goal             = 1e-04;
net.trainParam.max_fail         = 100;
net.trainParam.showWindow       = 1;

% Configuring net for data dimensions
net = configure(net,inputData, inputData);

end