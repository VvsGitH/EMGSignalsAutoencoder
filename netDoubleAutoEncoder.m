%% Generation and configuration of a custom NN for EMG and FORCE reconstruction
% hiddenSize: number of neurons in the hidden layer
% inputData: input and first output data of the NN (EMG signals)
% outputData: second output of the NN (FORCE signals)
% maxEpochs: maximum number of epochs
% indVect: (optional) three elements array containing the starting index of
%          the test set, the starting index of the validation set and the
%          dimension of inputData

function net = netDoubleAutoEncoder(hiddenSize, inputData, outputData, maxEpochs, indVect)

net = network;

% Topology
net.numInputs         = 1;
net.numLayers         = 3;
net.biasConnect       = [0;1;0];    % Only EMG output layer has a bias
net.inputConnect(1,1) = 1;
net.layerConnect(2,1) = 1;
net.layerConnect(3,1) = 1;
net.outputConnect     = [0,1,1];

% Labels and net names
net.name              = 'Autoencoder';
net.layers{1}.name    = 'Encoder';
net.layers{2}.name    = 'Decoder1';
net.layers{3}.name    = 'Decoder2';

% Initialization settings
net.layers{1}.size              = hiddenSize; 
net.layers{1}.initFcn           = 'initwb';
net.inputWeights{1,1}.initFcn   = 'randsmall';  % Initialization with small random values
net.biases{1}.initFcn           = 'randsmall';
net.layers{2}.initFcn           = 'initwb';
net.layerWeights{2,1}.initFcn   = 'randsmall';
net.biases{2}.initFcn           = 'randsmall';
net.initFcn                     = 'initlay';    % Call layer specific initialization functions

% Layers transfer functions
net.layers{1}.transferFcn       = 'poslin';
net.layers{2}.transferFcn       = 'purelin';
net.layers{3}.transferFcn       = 'purelin';

% Divide function
if nargin == 4
    net.divideFcn               = 'dividetrain';   % All dataset assigned to train
else
    net.divideFcn               = 'divideind';     % Dataset divided into train, test and validation
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

% Configuring net for input and output dimensions
net = configure(net,'inputs',inputData,1);
net = configure(net,'outputs',inputData,1);
net = configure(net,'outputs',outputData,2);

end