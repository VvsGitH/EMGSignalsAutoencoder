clearvars
clc

%% Dataset
% Sono 5000 immagini di numeri scritti a mano, da 1 a 10
[xTrainImages,tTrain] = digitTrainCellArrayData;
% xTrainImages contiene 5000 celle, in ognuna delle quali è presente
% un'immagine 28x28
% tTrain contiene 5000 label, che indicano a quale numero corrisponde ogni
% immagine

%% Display some of the training images
clf
for i = 1:20
    subplot(4,5,i);
    imshow(xTrainImages{i});
end

%% Autoencoder
rng('default')
hiddenSize = 100;
% autoenc = trainAutoencoder(xTrainImages,hiddenSize, ...
%     'MaxEpochs',400, ...
%     'L2WeightRegularization',0.004, ...
%     'SparsityRegularization',4, ...
%     'SparsityProportion',0.15, ...
%     'ScaleData', false);
autoenc = trainAutoencoder(xTrainImages,hiddenSize);
view(autoenc)
figure()
plotWeights(autoenc);
feat = encode(autoenc,xTrain);