close all
clearvars
clc
rng('default')
pool = gcp;

%% SETTING UP
fprintf('##### LOADING DATA #####\n');
load Data_FullDataset

% Selecting Subjects
selSbj = 21;  % best five subjects
N = length(selSbj);

% Setting max training epochs
maxEpochs = input('Select max epochs number: ');

% DAE: different normalization for output balance
outSize = size(EMG,1)+size(FORCE,1);    % 14
emgRelSize = size(EMG,1)/outSize;       % 10/14
forceRelSize = size(FORCE,1)/outSize;   % 4/14
r_emg = 0.5/emgRelSize;
r_frc = 0.5/forceRelSize;

%% TRAINING SIMULATION LOOP
fprintf('##### TRAINING SIMULATION LOOP #####\n');
NNMFsims = cell(N,1); AEsims = cell(N,1); DAEsims = cell(N,1);
for trSogg = selSbj
    
    fprintf('Subject: %d\n', trSogg);
    
    EMG             = DataSet{trSogg}.emg;
    EMG1		    = normalize(EMG,2,'range',[0 1]);
    EMG2            = normalize(EMG,2,'range',[0 r_emg]);
    maxEmg		    = DataSet{trSogg}.maxEmg;
    
    FORCE1          = DataSet{trSogg}.force;
    FORCE2          = normalize(FORCE1,2,'range',[0 r_frc]);
    maxForce        = DataSet{trSogg}.maxForce;
    
    TI              = DataSet{trSogg}.testIndex; 
    VI              = DataSet{trSogg}.validIndex;
    
    fprintf('   NNMF simulations\n');
    AEsims{trSogg}  = nnmfTrainTest(EMG1, FORCE1, maxEmg, [TI, VI]);
    
    fprintf('   AE simulations\n');
    AEsims{trSogg}  = netTrainTestAE(EMG1, FORCE1, maxEmg, [TI, VI], maxEpochs);
    
    fprintf('   DAE simulations\n');
    DAEsims{trSogg} = netTrainTestDAE(EMG2, FORCE2, maxEmg, minForce, maxForce, [TI, VI], maxEpochs);
    
end

%% MEAN PERFORMANCE
fprintf('##### CALCULATING PERFORMANCES #####\n');
Results.AE.AEsims = AEsims;
[Results.AE.avgMSE_emg, Results.AE.avgMSE_frc,   ...
Results.AE.avgRMSE_emg, Results.AE.avgRMSE_frc,  ...
Results.AE.avgR2_emg,   Results.AE.avgR2_frc,    ...
Results.AE.stdMSE_emg,  Results.AE.stdMSE_frc,   ...
Results.AE.stdRMSE_emg, Results.AE.stdRMSE_frc,  ...
Results.AE.stdR2_emg,   Results.AE.stdR2_frc]  = dataSimResults(AEsims, selSbj);

Results.DAE.DAEsims = DAEsims;
[Results.DAE.avgMSE_emg, Results.DAE.avgMSE_frc,  ...
Results.DAE.avgRMSE_emg, Results.DAE.avgRMSE_frc, ...
Results.DAE.avgR2_emg,   Results.DAE.avgR2_frc,   ...
Results.DAE.stdMSE_emg,  Results.DAE.stdMSE_frc,  ...
Results.DAE.stdRMSE_emg, Results.DAE.stdRMSE_frc, ...
Results.DAE.stdR2_emg,   Results.DAE.stdR2_frc] = dataSimResults(DAEsims, selSbj);

%% SAVING
if (upper(input('Save the results? [Y,N]\n','s')) == 'Y')
    fprintf('Insert the filename: (press enter to use the default one)\n');
    filename = 'AE_DAE_sims';
    filename = [filename, input(filename,'s'),'.mat'];
    fprintf('Saving...\n');
    save(filename,'Results');
    fprintf('%s saved!\n',filename);
end

%% PLOTTING
h = 1:10;

fprintf('##### PLOTTING AE RESULTS #####\n');
figure(1);
    % MSE, RMSE and R2 barplots for EMG
    subplot(2,3,1)
    bar(h,Results.AE.avgMSE_emg), title('AE EMG MSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.AE.avgMSE_emg,Results.AE.stdMSE_emg,'ko');
    subplot(2,3,2)
    bar(h,Results.AE.avgRMSE_emg), title('AE EMG RMSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.AE.avgRMSE_emg,Results.AE.stdRMSE_emg,'ko');
    subplot(2,3,3)
    bar(h,Results.AE.avgR2_emg), title('AE EMG R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.AE.avgR2_emg,Results.AE.stdR2_emg,'ko');
    
    % MSE, RMSE and R2 barplots for FORCE
    subplot(2,3,4)
    bar(h,Results.AE.avgMSE_frc), title('AE FORCE MSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.AE.avgMSE_frc,Results.AE.stdMSE_frc,'ko');
    subplot(2,3,5)
    bar(h,Results.AE.avgRMSE_frc), title('AE FORCE RMSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.AE.avgRMSE_frc,Results.AE.stdRMSE_frc,'ko');
    subplot(2,3,6)
    bar(h,Results.AE.avgR2_frc), title('AE FORCE R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');  
    hold on
    errorbar(Results.AE.avgR2_frc,Results.AE.stdR2_frc,'ko');

fprintf('##### PLOTTING DAE RESULTS #####\n');
figure(2);
    % MSE, RMSE and R2 barplots for EMG
    subplot(2,3,1)
    bar(h,Results.DAE.avgMSE_emg), title('DAE EMG MSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.DAE.avgMSE_emg,Results.DAE.stdMSE_emg,'ko');
    subplot(2,3,2)
    bar(h,Results.DAE.avgRMSE_emg), title('DAE EMG RMSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.DAE.avgRMSE_emg,Results.DAE.stdRMSE_emg,'ko');
    subplot(2,3,3)
    bar(h,Results.DAE.avgR2_emg), title('DAE EMG R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.DAE.avgR2_emg,Results.DAE.stdR2_emg,'ko');
    
    % MSE, RMSE and R2 barplots for FORCE
    subplot(2,3,4)
    bar(h,Results.DAE.avgMSE_frc), title('DAE FORCE MSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.DAE.avgMSE_frc,Results.DAE.stdMSE_frc,'ko');
    subplot(2,3,5)
    bar(h,Results.DAE.avgRMSE_frc), title('DAE FORCE RMSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(Results.DAE.avgRMSE_frc,Results.DAE.stdRMSE_frc,'ko');
    subplot(2,3,6)
    bar(h,Results.DAE.avgR2_frc), title('DAE FORCE R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');  
    hold on
    errorbar(Results.DAE.avgR2_frc,Results.DAE.stdR2_frc,'ko');



