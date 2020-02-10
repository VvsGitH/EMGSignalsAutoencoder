
%% AUTOENCODER
rng('default')
hiddenSize = 7; maxEpochs = 1000;
autoenc = trainAutoencoder(X,hiddenSize,'MaxEpochs',maxEpochs,...
                           'EncoderTransferFunction','logsig',...   %Sigmoide
                           'DecoderTransferFunction','purelin',...  %Lineare
                           'LossFunction','msesparse',...           %Mean Square Error
                           'TrainingAlgorithm','trainscg',...       %Scaled Conjugate Gradient
                           'ScaleData',false,...
                           'UseGPU',true);         
view(autoenc)

%% EVALUATION
XRecostructed = predict(autoenc,X);
weights = encode(autoenc,X);
mseError = mse(EMG-XRecostructed)

