close all
clc
clearvars
rng('default')
pool = gcp;

%% SETTING UP
fprintf('Loading Data...\n');
load Data_TrainDataset
load Data_TestDataset

% Select Subject
trSogg = input('Input Subject Number: ');
EMG_Train = TrainDataSet{trSogg,1}.emg;
FORCE_Train = TrainDataSet{trSogg,1}.cutforce;
MAX = TrainDataSet{trSogg,1}.maxForce;
FORCE_Train_den = dataDenormalize(FORCE_Train,0,2,MAX);
EMG_Test = TestDataSet{trSogg,1}.emg;
FORCE_Test = TestDataSet{trSogg,1}.cutforce;
MAX = TestDataSet{trSogg,1}.maxForce;
FORCE_Test_den = dataDenormalize(FORCE_Test,0,2,MAX);

%% TRAINING/SIMULATION LOOP
MSE_emg = zeros(1,10); MSE_frc = zeros(1,10);
RMSE_emg = zeros(1,10); RMSE_frc = zeros(1,10);
R2_emg = zeros(1,10); R2_frc = zeros(1,10);
trainedNet = cell(1,10); trainingReport = cell(1,10);    
    
parfor h = 1:10
    
    fprintf('H%d: Generating Net...\n',h);
    net = netDoubleAutoEncoder(h, EMG_Train, FORCE_Train, 5000, 1e-05, 0);
    
    %% TRAINING
    fprintf('H%d: Training...\n',h);
    [trNet, tr] = train(net,EMG_Train,[EMG_Train; FORCE_Train],'useParallel','no');
    trainedNet{1,h} = trNet;
    trainingReport{1,h} = tr;
    
    %% SIMULATION
    fprintf('H%d: Simulation...\n',h);
    XRecos = trNet(EMG_Test,'useParallel','no');
    
    %% PERFORMANCE
    % Performance for the reconstruction of EMG signal
    fprintf('H%d_EMG: Calculating performance indexes...\n',h)
    [mse_emg, rmse_emg, r2_emg] = netPerformance(EMG_Test, XRecos(1:10,:));
    fprintf('   The mse is: %d\n   The RMSE is: %d\n   The R2 is: %d\n',...
        mse_emg,rmse_emg,r2_emg);
    
    % Performance for the reconstruction of Forces
    fprintf('H%d_FORCE: Calculating performance indexes...\n',h)
    [mse_frc, rmse_frc, r2_frc] = netPerformance(FORCE_Test, XRecos(11:16,:));
    fprintf('   The mse is: %d\n   The RMSE is: %d\n   The R2 is: %d\n',...
        mse_frc,rmse_frc,r2_frc);
    
    % Inserting into vectors
    MSE_emg(1,h) = mse_emg;
    MSE_frc(1,h) = mse_frc;
    RMSE_emg(1,h) = rmse_emg;
    RMSE_frc(1,h) = rmse_frc;
    R2_emg(1,h) = r2_emg;
    R2_frc(1,h) = r2_frc;
    
end

%% SAVING
fprintf('Generating Structure...\n');
DAEsim.subject = trSogg;
DAEsim.trainedNet = trainedNet';
DAEsim.trainingReport = trainingReport';
DAEsim.MSE_emg = MSE_emg';
DAEsim.MSE_frc = MSE_frc';
DAEsim.RMSE_emg = RMSE_emg';
DAEsim.RMSE_frc = RMSE_frc';
DAEsim.R2_emg = R2_emg';
DAEsim.R2_frc = R2_frc';

if (input('Save the file? [Y,N]\n','s') == 'Y')
    fprintf('Saving...\n');
    filename = ['DAEsim_sbj', num2str(trSogg), '_allSizes.mat'];
    save(filename,'DAEsim');
end

%% PLOTTING
fprintf('Plotting Performance Indexes...\n')
h = 1:10;
figure(1);
    subplot(2,3,1)
    plot(h,DAEsim.MSE_emg), title('EMG MSE');
    subplot(2,3,2)
    plot(h,DAEsim.RMSE_emg), title('EMG RMSE');
    subplot(2,3,3)
    plot(h,DAEsim.R2_emg), title('EMG R2');
    subplot(2,3,4)
    plot(h,DAEsim.MSE_frc), title('FORCE MSE');
    subplot(2,3,5)
    plot(h,DAEsim.RMSE_frc), title('FORCE RMSE');
    subplot(2,3,6)
    plot(h,DAEsim.R2_frc), title('FORCE R2');    

fprintf('Plotting Signals...\n')
t1 = 1:1:size(EMG_Test,2);
for h = 1:10
    % Calculating XRecos and plotting EMG signals
    XRecos = DAEsim.trainedNet{h}(EMG_Test,'useParallel','yes');
    t2 = 1:1:size(XRecos,2);
    figure(2*h)
    for i = 1:10
        subplot(2,5,i)
        plot(t1,EMG_Test(i,:),'b');
        hold on
        plot(t2,XRecos(i,:),'r');
    end
    sgtitle(['H' num2str(h) ': EMG'])
    
    % Plotting FORCE signals
    figure(2*h+1)
    for i = 1:6
        subplot(2,3,i)
        plot(t1,FORCE_Test(i,:),'b');
        hold on
        plot(t2,XRecos(i+10,:),'r');
    end
    sgtitle(['H' num2str(h) ': FORCE'])
end 

