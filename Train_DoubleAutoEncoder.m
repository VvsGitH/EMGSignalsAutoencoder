close all
clc
clearvars
rng('default')
pool = gcp;

%% SETTING UP
fprintf('Loading Data...\n');
load Data_FullDataset

% Select Subject
trSogg = input('Input Subject Number: ');

% Naming variable for a clean code
EMG   = DataSet{trSogg}.emg;
FORCE = DataSet{trSogg}.cutforce;
% FORCE_den = dataDenormalize(FORCE, 0, 2, DataSet{trSogg}.maxForce);

% Dividing train test and validation for simulation and force reconstruction
TI = DataSet{trSogg}.testIndex; VI = DataSet{trSogg}.validIndex; END = length(DataSet{trSogg}.emg);
[EMG_Train, EMG_Valid, EMG_Test]        = divideind(EMG, 1:TI-1, VI:END, TI:VI-1);
[FORCE_Train, FORCE_Valid, FORCE_Test]  = divideind(FORCE, 1:TI-1, VI:END, TI:VI-1);

% [Optional]: uncomment if you want to use divedetrain
% EMG         = EMG_Train;
% FORCE       = FORCE_Train;
% EMG_Test    = [EMG_Test, EMG_Valid];
% FORCE_Test  = [FORCE_Test, FORCE_Valid];

%% TRAINING/SIMULATION LOOP
MSE_emg    = zeros(1,10); MSE_frc        = zeros(1,10);
RMSE_emg   = zeros(1,10); RMSE_frc       = zeros(1,10);
R2_emg     = zeros(1,10); R2_frc         = zeros(1,10);
trainedNet = cell(1,10);  trainingReport = cell(1,10);

parfor h = 1:10
    
    fprintf('H%d: Generating Net...\n',h);
    % net = netDoubleAutoEncoder(h, EMG, FORCE, 10000);
    net = netDoubleAutoEncoder(h, EMG, FORCE, 10000, [TI, VI, END]);
    
    %% TRAINING
    fprintf('H%d: Training...\n',h);
    [trNet, tr] = train(net,EMG,[EMG; FORCE],'useParallel','no');
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

if (upper(input('Save the file? [Y,N]\n','s')) == 'Y')
    fprintf('Insert the filename: (press enter to use the default one)\n');
    filename = ['DAEsim_sbj', num2str(trSogg), '_allSizes'];
    filename = [filename, input(filename,'s'),'.mat'];
    fprintf('Saving...\n');
    save(filename,'DAEsim');
    fprintf('%s saved!\n',filename);
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

