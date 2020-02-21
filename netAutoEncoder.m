%% Generation and configuration of a custom AutoEncoder
% hiddenSize: number of neurons in the hidden layer
% inputData: input data of the autoencoder (EMG signals)
% maxEpochs: maximum number of epochs
% indVect: (optional) three elements array containing the starting index of
%          the test set, the starting index of the validation set and the
%          dimension of inputData

function net = netAutoEncoder(hiddenSize, inputData, maxEpochs, indVect)

% Topology
net = feedforwardnet(hiddenSize);
net.biasConnect    = [0;1];    % Only output layer has a bias

% Labels and net names
net.name           = 'Autoencoder';
net.layers{1}.name = 'Encoder';
net.layers{2}.name = 'Decoder';

% Layers transfer functions
net.layers{1}.transferFcn       = 'poslin';
net.layers{2}.transferFcn       = 'purelin';

% Divide function
if nargin == 3
    net.divideFcn               = 'dividetrain';  % All dataset assigned to train
else
    net.divideFcn               = 'divideind';    % Dataset divided into train, test and validation
    net.divideParam.trainInd    = 1:indVect(1)-1;
    net.divideParam.testInd     = indVect(1):indVect(2)-1;
    net.divideParam.valInd      = indVect(2):length(inputData);
end

% Perform Settings
net.performFcn                  = 'mse';      % Mean Square Error
net.performParam.regularization = 0;          % Minimize only error
net.performParam.normalization  = 'none';     % Take the error as it is

% Training Settings
net.trainFcn                    = 'traingdx'; % Gradient descent w/momentum & adaptive lr backpropagation (gradient derivative method)
% net.trainFcn                  = 'trainlm';  % Levenberg-Marquardt backpropagation (Jacobian derivative method)
net.trainParam.epochs           = maxEpochs;
net.trainParam.min_grad         = 0;
net.trainParam.goal             = 1e-04;
net.trainParam.max_fail         = 100;
net.trainParam.showWindow       = 1;

% Configuring net for data dimensions
net = configure(net,inputData, inputData);

end