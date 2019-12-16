load DataSet2
clearvars -except EMG
clc

X = EMG(1:5);

%% AUTOENCODER
rng('default')
hiddenSize = 7; maxEpochs = 1000;
autoenc = trainAutoencoder(EMG,hiddenSize,'MaxEpochs',maxEpochs,...
                           'EncoderTransferFunction','logsig',...   %Sigmoide
                           'DecoderTransferFunction','purelin',...  %Lineare
                           'LossFunction','msesparse',...           %Mean Square Error
                           'TrainingAlgorithm','trainscg',...       %Scaled Conjugate Gradient
                           'ScaleData',false,...
                           'UseGPU',true);         
view(autoenc)

%% EVALUATION
XRecostructed = predict(autoenc,EMG);
weights = encode(autoenc,EMG);
mseError = mse(EMG-XRecostructed)

% PLOTTING
% t = 1:1:194419;
% plot(t,X(1,:),'b',t,XRecostructed(1,:),'r');

