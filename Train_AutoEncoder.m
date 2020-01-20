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
FORCE_Train = TrainDataSet{trSogg,1}.force;
EMG_Test = TestDataSet{trSogg,1}.emg;
FORCE_Test = TestDataSet{trSogg,1}.force;

%% TRAINING/SIMULATION LOOP
MSE_emg = zeros(1,10); MSE_frc = zeros(1,10);
RMSE_emg = zeros(1,10); RMSE_frc = zeros(1,10);
R2_emg = zeros(1,10); R2_frc = zeros(1,10);
trainedNet = cell(1,10); trainingReport = cell(1,10);
emgToForceMatrix = cell(1,10);

parfor h = 1:10
    
    fprintf('H%d: Generating Net...\n',h);
    net = netAutoEncoder(h, EMG_Train, 1000, 1e-05, 0);
    
    %% TRAINING
    fprintf('H%d: Training...\n',h);
    [trNet, tr] = train(net,EMG_Train,EMG_Train,'useParallel','no');
    trainedNet{1,h} = trNet;
    trainingReport{1,h} = tr;
    
    %% SIMULATION
    fprintf('H%d: Simulation...\n',h);
    EMG_Recos = trNet(EMG_Test,'useParallel','no');
    
    %% FORCE RECONSTRUCTION
    fprintf('H%d: Force Reconstruction...\n',h);
    inputWeigths = cell2mat(trNet.IW);
    S_Train = elliotsig(inputWeigths*EMG_Train);
    Hae = FORCE_Train*pinv(S_Train);
    emgToForceMatrix{1,h} = Hae;
    S_Test = elliotsig(inputWeigths*EMG_Test);
    FORCE_Recos = Hae*S_Test;
    
    %% PERFORMANCE
    % Performance for the reconstruction of EMG signal
    fprintf('H%d_EMG: Calculating performance indexes...\n',h)
    [mse_emg, rmse_emg, r2_emg] = netPerformance(EMG_Test, EMG_Recos);
    fprintf('   The mse is: %d\n   The RMSE is: %d\n   The R2 is: %d\n',...
        mse_emg,rmse_emg,r2_emg);
    
    % Performance for the reconstruction of Forces
    fprintf('H%d_FORCE: Calculating performance indexes...\n',h)
    [mse_frc, rmse_frc, r2_frc] = netPerformance(FORCE_Test, FORCE_Recos);
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
AEsim.subject = trSogg;
AEsim.trainedNet(trSogg,:) = trainedNet;
AEsim.trainingReport(trSogg,:) = trainingReport;
AEsim.emgToForceMatrix(trSogg,:) = emgToForceMatrix;
AEsim.MSE_emg(trSogg,:) = MSE_emg;
AEsim.MSE_frc(trSogg,:) = MSE_frc;
AEsim.RMSE_emg(trSogg,:) = RMSE_emg;
AEsim.RMSE_frc(trSogg,:) = RMSE_frc;
AEsim.R2_emg(trSogg,:) = R2_emg;
AEsim.R2_frc(trSogg,:) = R2_frc;

if (input('Save the file? [Y,N]\n','s') == 'Y')
    fprintf('Saving...\n');
    filename = ['AEsim_sbj', num2str(trSogg), '_allSizes.mat'];
    save(filename,'AEsim');
end

%% PLOTTING
fprintf('Plotting Performance Indexes...\n')
h = 1:10;
figure(1);
    subplot(2,3,1)
    plot(h,AEsim.MSE_emg(AEsim.subject,:)), title('EMG MSE');
    subplot(2,3,2)
    plot(h,AEsim.RMSE_emg(AEsim.subject,:)), title('EMG RMSE');
    subplot(2,3,3)
    plot(h,AEsim.R2_emg(AEsim.subject,:)), title('EMG R2');
    subplot(2,3,4)
    plot(h,AEsim.MSE_frc(AEsim.subject,:)), title('FORCE MSE');
    subplot(2,3,5)
    plot(h,AEsim.RMSE_frc(AEsim.subject,:)), title('FORCE RMSE');
    subplot(2,3,6)
    plot(h,AEsim.R2_frc(AEsim.subject,:)), title('FORCE R2');    

fprintf('Plotting Signals...\n')
t1 = 1:1:size(EMG_Test,2);
for h = 1:10
    % Calculating EMG_Recos and plotting EMG signals
    EMG_Recos = AEsim.trainedNet{AEsim.subject,h}(EMG_Test,'useParallel','yes');
    t2 = 1:1:size(EMG_Recos,2);
    figure(2*h)
    for i = 1:10
        subplot(2,5,i)
        plot(t1,EMG_Test(i,:),'b');
        hold on
        plot(t2,EMG_Recos(i,:),'r');
    end
    sgtitle(['H' num2str(h) ': EMG'])
    
    % Estimating FORCE_Recos and plotting FORCE signals
    inputWeigths = cell2mat(AEsim.trainedNet{AEsim.subject,h}.IW);
    S_Test = elliotsig(inputWeigths*EMG_Test);
    FORCE_Recos = AEsim.emgToForceMatrix{trSogg,h}*S_Test;
    figure(2*h+1)
    for i = 1:6
        subplot(2,3,i)
        plot(t1,FORCE_Test(i,:),'b');
        hold on
        plot(t2,FORCE_Recos(i,:),'r');
    end
    sgtitle(['H' num2str(h) ': FORCE'])
end   

