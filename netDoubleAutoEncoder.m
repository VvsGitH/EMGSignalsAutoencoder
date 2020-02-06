function net = netDoubleAutoEncoder(hiddenSize, inputData, outputData, maxEpochs, indVect)

net = network;

% Topology
net.numInputs         = 1;
net.numLayers         = 3;
net.biasConnect       = [0;1;0];    % Il layer d'uscita EMG ha un bias
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
net.layers{1}.size              = hiddenSize;   % Numero di neuroni
net.layers{1}.initFcn           = 'initwb';
net.inputWeights{1,1}.initFcn   = 'randsmall';  % Inizializzazione con piccoli valori casuali con segno
net.biases{1}.initFcn           = 'randsmall';
net.layers{2}.initFcn           = 'initwb';
net.layerWeights{2,1}.initFcn   = 'randsmall';
net.biases{2}.initFcn           = 'randsmall';
net.initFcn                     = 'initlay';    % Chiama le funzioni di inizializzazione di ogni layer

% Layers transfer functions
net.layers{1}.transferFcn       = 'poslin';
net.layers{2}.transferFcn       = 'purelin';
net.layers{3}.transferFcn       = 'poslin';

% Divide function
if nargin == 4
    net.divideFcn               = 'dividetrain';   % Assegna tutti i valori al train
else
    net.divideFcn               = 'divideind';     % 'dividetrain': Assegna tutti i valori al train
    net.divideParam.trainInd    = 1:indVect(1)-1;
    net.divideParam.testInd     = indVect(1):indVect(2)-1;
    net.divideParam.valInd      = indVect(2):indVect(3);
end

% Perform Settings
net.performFcn                  = 'mse';        % Imposta l'indice di performance come mse
net.performParam.regularization = 0;          % Minimize only error
net.performParam.normalization  = 'none';       % Take the error as it is

% Training Settings
net.trainFcn                    = 'traingda';   % Gradient Descent with adaptive learning rate
net.trainParam.epochs           = maxEpochs;
net.trainParam.min_grad         = 0;
net.trainParam.goal             = 1e-04;
net.trainParam.max_fail         = 300;
net.trainParam.showWindow       = 1;

% Configuring net for input and output dimensions
net = configure(net,'inputs',inputData,1);
net = configure(net,'outputs',inputData,1);
net = configure(net,'outputs',outputData,2);

end