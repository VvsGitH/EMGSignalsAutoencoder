% Load the sample data.
X = abalone_dataset;
% X is an 8-by-4177 matrix defining eight attributes for 4177 different abalone shells: sex (M, F, and I (for infant)), length, diameter, height, whole weight, shucked weight, viscera weight, shell weight. 
% Train a sparse autoencoder with hidden size 4, 400 maximum epochs, and linear transfer function for the decoder.
autoenc = trainAutoencoder(X,4,'MaxEpochs',400,...
'DecoderTransferFunction','purelin');
% Reconstruct the abalone shell ring data using the trained autoencoder.
XReconstructed = predict(autoenc,X);
% Compute the mean squared reconstruction error.
mseError = mse(X-XReconstructed)