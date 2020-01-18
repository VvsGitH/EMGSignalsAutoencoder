% Load the sample data.
[X,T] = maglev_dataset;

%% SingleCore CPU
net = feedforwardnet(10);
net = configure(net,X,T);
trNet = train(net,X,T);

%% MultiCore CPU
pool = gcp;
net = feedforwardnet(10);
net = configure(net,X,T);
trNet = train(net,X,T,'useParallel','yes');

%% MultiCore CPU with Manual Composite Data
pool = gcp;
% Generating data for the Composite Multicore training
Xc = Composite(); Tc = Composite();
L = size(X,2)/pool.NumWorkers;
Xc{1} = X(1:L); Tc{1} = T(1:L);
for i = 1:pool.NumWorkers-1
    Xc{i+1} = X(L*i+1:L*i+L);
    Tc{i+1} = T(L*i+1:L*i+L);
end
% Configuring and training net with the composite data
net = feedforwardnet(10);
net = configure(net,Xc{1},Tc{1});
trNet = train(net,Xc,Tc);

%% GPU 
pool = gcp;
net = feedforwardnet(10);
net = configure(net,X,T);
trNet = train(net,X,T,'useGPU','yes');

%% GPU with Manual GPU Arrays
pool = gcp;
% Generating GPU arrays for the GPU training
Xg = nndata2gpu(X);
Tg = nndata2gpu(T);
% Configuring and training the net
net = feedforwardnet(10);
net = configure(net,Xg,Tg);
trNet = train(net,Xg,Tg,'showResources','yes');

%% GPU with mini-batches [NOT WORKING]
pool = gcp;
% Generatig mini-batches for GPU
nBatch = 3;
L = size(X,2)/nBatch;
mini_Xg = cell(1,nBatch); mini_Tg = cell(1,nBatch);
mini_Xg{1} = nndata2gpu(X(1:L)); mini_Tg{1} = nndata2gpu(T(1:L));
for i = 1:nBatch-1
    mini_Xg{i+1} = nndata2gpu(X(L*i+1:L*i+L));
    mini_Tg{i+1} = nndata2gpu(T(L*i+1:L*i+L));
end
% Configuring net
net = feedforwardnet(10);
net = configure(net,mini_Xg{1},mini_Tg{1});
% Training net
net.trainParam.epochs = 1;
for i = 1:100
    for j = 1:nBatch
        net = train(net, mini_Xg{j}, mini_Tg{j});
    end
end 