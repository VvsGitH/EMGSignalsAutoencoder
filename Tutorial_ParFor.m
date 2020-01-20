%% FOR VS PARFOR
clearvars
pool = gcp;
a = zeros(4,5);
fprintf('PARFOR TEST\n')
tic
for j = 1:5
    parfor i = 1:4
        %fprintf('working on %d\n',i)
        temp(i) = i;
        pause(1)
        %fprintf('%d is finished\n',i)
    end
    a(:,j) = temp;
end
toc
disp(a)

a = zeros(4,5);
fprintf('FOR TEST\n')
tic
for j = 1:5
    for i = 1:4
        %fprintf('working on %d\n',i)
        a(i,j) = i;
        pause(1)
        %fprintf('%d is finished\n',i)
    end
end
toc
disp(a)


%% NORMAL VS PARALLEL TRAINING 1000 EPOCHS
clearvars, clc
pool = gcp;
fprintf('Loading Data...\n');
load TrainDataSet
trSogg = 1; h = 1;
EMG_Train = TrainDataSet{trSogg,1}.emg;
fprintf('---- Single Core training: START ----\n');
tic
        % CUSTOM NET
        fprintf('Generating Net...\n');
        rng('default')
        hiddenSize = h;
        net = feedforwardnet(hiddenSize);
        net.name = 'Autoencoder';
        net.layers{1}.name = 'Encoder';
        net.layers{2}.name = 'Decoder';
        net.biasConnect = [0;1];    % Il layer d'uscita EMG ha un bias
        net.trainFcn = 'trainscg'; %'trainlm': Jacobian - not supported by GPU; % 'trainscg': Scalar Conjugate Gradient - better for GPU
        net.performFcn = 'mse'; % Mean Square Error
        net.divideFcn = 'dividetrain'; % Assegna tutti i valori al train
        net.layers{1}.transferFcn = 'elliotsig'; %'elliotsig' = n / (1 + abs(n)) - better for GPU; 'tansig' = 2/(1+exp(-2*n))-1
        net.layers{2}.transferFcn = 'purelin';
        net.trainParam.epochs = 1000;
        net.trainParam.min_grad = 0;
        net.trainParam.goal = 1e-05;
        net = configure(net,EMG_Train,EMG_Train); % Configure net for the standard Dataset
        % TRAINING
        fprintf('Training...\n');
        [trNet, tr] = train(net,EMG_Train,EMG_Train);        
toc % 82.98 seconds
fprintf('---- Multi Core training: START ----\n');
tic
        % CUSTOM NET
        fprintf('Generating Net...\n');
        rng('default')
        hiddenSize = h;
        net = feedforwardnet(hiddenSize);
        net.name = 'Autoencoder';
        net.layers{1}.name = 'Encoder';
        net.layers{2}.name = 'Decoder';
        net.biasConnect = [0;1];    % Il layer d'uscita EMG ha un bias
        net.trainFcn = 'trainscg'; %'trainlm': Jacobian - not supported by GPU; % 'trainscg': Scalar Conjugate Gradient - better for GPU
        net.performFcn = 'mse'; % Mean Square Error
        net.divideFcn = 'dividetrain'; % Assegna tutti i valori al train
        net.layers{1}.transferFcn = 'elliotsig'; %'elliotsig' = n / (1 + abs(n)) - better for GPU; 'tansig' = 2/(1+exp(-2*n))-1
        net.layers{2}.transferFcn = 'purelin';
        net.trainParam.epochs = 1000;
        net.trainParam.min_grad = 0;
        net.trainParam.goal = 1e-05;
        net = configure(net,EMG_Train,EMG_Train); % Configure net for the standard Dataset
        % TRAINING
        fprintf('Training...\n');
        [trNet, tr] = train(net,EMG_Train,EMG_Train,'useParallel','yes','showResources','yes');
toc % 47.57 seconds

%% FOR + PARALLEL TRAINING VS PARFOR + NORMAL TRAINING
clearvars, clc
pool = gcp;
fprintf('Loading Data...\n');
load TrainDataSet
trSogg = 1;
EMG_Train = TrainDataSet{trSogg,1}.emg;
NETS = cell(4);
fprintf('---- Parfore + SingleCore training: START ----\n');
tic
parfor h = 1:4
        fprintf('      H = %d\n',h);
        % CUSTOM NET
        fprintf('Generating Net...\n');
        rng('default')
        hiddenSize = h;
        net = feedforwardnet(hiddenSize);
        net.name = 'Autoencoder';
        net.layers{1}.name = 'Encoder';
        net.layers{2}.name = 'Decoder';
        net.biasConnect = [0;1];    % Il layer d'uscita EMG ha un bias
        net.trainFcn = 'trainscg'; %'trainlm': Jacobian - not supported by GPU; % 'trainscg': Scalar Conjugate Gradient - better for GPU
        net.performFcn = 'mse'; % Mean Square Error
        net.divideFcn = 'dividetrain'; % Assegna tutti i valori al train
        net.layers{1}.transferFcn = 'elliotsig'; %'elliotsig' = n / (1 + abs(n)) - better for GPU; 'tansig' = 2/(1+exp(-2*n))-1
        net.layers{2}.transferFcn = 'purelin';
        net.trainParam.epochs = 1000;
        net.trainParam.min_grad = 0;
        net.trainParam.goal = 1e-05;
        net = configure(net,EMG_Train,EMG_Train); % Configure net for the standard Dataset
        % TRAINING
        fprintf('Training...\n');
        net.trainParam.showWindow=0;
        [trNet, tr] = train(net,EMG_Train,EMG_Train,'useParallel','no');
        % SAVING
        NETS{h} = trNet;
end
toc %121 seconds
fprintf('---- For + MulticoreCore training: START ----\n');
tic
for h = 1:4
        fprintf('      H = %d\n',h);
        % CUSTOM NET
        fprintf('Generating Net...\n');
        rng('default')
        hiddenSize = h;
        net = feedforwardnet(hiddenSize);
        net.name = 'Autoencoder';
        net.layers{1}.name = 'Encoder';
        net.layers{2}.name = 'Decoder';
        net.biasConnect = [0;1];    % Il layer d'uscita EMG ha un bias
        net.trainFcn = 'trainscg'; %'trainlm': Jacobian - not supported by GPU; % 'trainscg': Scalar Conjugate Gradient - better for GPU
        net.performFcn = 'mse'; % Mean Square Error
        net.divideFcn = 'dividetrain'; % Assegna tutti i valori al train
        net.layers{1}.transferFcn = 'elliotsig'; %'elliotsig' = n / (1 + abs(n)) - better for GPU; 'tansig' = 2/(1+exp(-2*n))-1
        net.layers{2}.transferFcn = 'purelin';
        net.trainParam.epochs = 1000;
        net.trainParam.min_grad = 0;
        net.trainParam.goal = 1e-05;
        net = configure(net,EMG_Train,EMG_Train); % Configure net for the standard Dataset
        % TRAINING
        net.trainParam.showWindow=0;
        fprintf('Training...\n');
        [trNet, tr] = train(net,EMG_Train,EMG_Train,'useParallel','yes');
        % SAVING
        NETS{h} = trNet;
end
toc %151 seconds