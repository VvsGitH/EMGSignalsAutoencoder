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
[r_emg, r_frc] = netDAEoutputNorm(DataSet{1}.emg, DataSet{1}.force);

%% TRAINING SIMULATION LOOP
fprintf('##### TRAINING SIMULATION LOOP #####\n');
LFRsims_sf = cell(40,1);    LFRsims_mf = cell(40,1);
NNMFsims_sf = cell(40,1);   NNMFsims_mf = cell(40,1);
AEsims_sf = cell(40,1);     AEsims_mf = cell(40,1);
DAEsims_sf = cell(40,1);    DAEsims_mf = cell(40,1);
for trSogg = selSbj
    
    fprintf('Subject: %d\n', trSogg);
    
    EMG      = DataSet{trSogg}.emg;
    EMG1	 = normalize(EMG,2,'range',[0 1]);
    EMG2     = normalize(EMG,2,'range',[0 r_emg]);
    maxEmg	 = DataSet{trSogg}.maxEmg;
    
    FORCE1   = DataSet{trSogg}.force;
    FORCE2   = normalize(FORCE1,2,'range',[0 r_frc]);
    maxForce = DataSet{trSogg}.maxForce;
    
    TI       = DataSet{trSogg}.testIndex; 
    VI       = DataSet{trSogg}.validIndex;
    
    fprintf('   LFR: single fingers\n');
    LFRsims_sf{trSogg}  = meth1_LFR(EMG, FORCE1, [TI, VI]);
    fprintf('   LFR: multiple fingers\n');
    LFRsims_mf{trSogg}  = meth1_LFR(EMG, FORCE1, [TI, VI]);
    
    fprintf('   NNMF: single fingers\n');
    NNMFsims_sf{trSogg} = meth2_NNMF(EMG1, FORCE1, maxEmg, [TI, VI]);
    fprintf('   NNMF: single fingers\n');
    NNMFsims_mf{trSogg} = meth2_NNMF(EMG1, FORCE1, maxEmg, [TI, VI]);
    
    fprintf('   AE: single fingers\n');
    AEsims_sf{trSogg}   = meth3_AE(EMG1, FORCE1, maxEmg, [TI, VI], maxEpochs);
    fprintf('   AE: multiple fingers\n');
    AEsims_mf{trSogg}   = meth3_AE(EMG1, FORCE1, maxEmg, [TI, VI], maxEpochs);
    
    fprintf('   DAE: single fingers\n');
    DAEsims_sf{trSogg}  = meth4_DAE(EMG2, FORCE2, maxEmg, maxForce, [TI, VI], maxEpochs);
    fprintf('   DAE: multiple fingers\n');
    DAEsims_mf{trSogg}  = meth4_DAE(EMG2, FORCE2, maxEmg, maxForce, [TI, VI], maxEpochs);
    
end

%% MEAN PERFORMANCE
fprintf('##### CALCULATING PERFORMANCES #####\n');
modResults.AE.AEsims = AEsims_sf;
[modResults.AE.avgMSE_emg, modResults.AE.avgMSE_frc,   ...
modResults.AE.avgRMSE_emg, modResults.AE.avgRMSE_frc,  ...
modResults.AE.avgR2_emg,   modResults.AE.avgR2_frc,    ...
modResults.AE.stdMSE_emg,  modResults.AE.stdMSE_frc,   ...
modResults.AE.stdRMSE_emg, modResults.AE.stdRMSE_frc,  ...
modResults.AE.stdR2_emg,   modResults.AE.stdR2_frc]  = dataSimResults(AEsims_sf, selSbj);

modResults.DAE.DAEsims = DAEsims_sf;
[modResults.DAE.avgMSE_emg, modResults.DAE.avgMSE_frc,  ...
modResults.DAE.avgRMSE_emg, modResults.DAE.avgRMSE_frc, ...
modResults.DAE.avgR2_emg,   modResults.DAE.avgR2_frc,   ...
modResults.DAE.stdMSE_emg,  modResults.DAE.stdMSE_frc,  ...
modResults.DAE.stdRMSE_emg, modResults.DAE.stdRMSE_frc, ...
modResults.DAE.stdR2_emg,   modResults.DAE.stdR2_frc] = dataSimResults(DAEsims_sf, selSbj);

%% SAVING
if (upper(input('Save the results? [Y,N]\n','s')) == 'Y')
    fprintf('Insert the filename: (press enter to use the default one)\n');
    filename = 'Data_modResults';
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
    bar(h,modResults.AE.avgMSE_emg), title('AE EMG MSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.AE.avgMSE_emg,modResults.AE.stdMSE_emg,'ko');
    subplot(2,3,2)
    bar(h,modResults.AE.avgRMSE_emg), title('AE EMG RMSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.AE.avgRMSE_emg,modResults.AE.stdRMSE_emg,'ko');
    subplot(2,3,3)
    bar(h,modResults.AE.avgR2_emg), title('AE EMG R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.AE.avgR2_emg,modResults.AE.stdR2_emg,'ko');
    
    % MSE, RMSE and R2 barplots for FORCE
    subplot(2,3,4)
    bar(h,modResults.AE.avgMSE_frc), title('AE FORCE MSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.AE.avgMSE_frc,modResults.AE.stdMSE_frc,'ko');
    subplot(2,3,5)
    bar(h,modResults.AE.avgRMSE_frc), title('AE FORCE RMSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.AE.avgRMSE_frc,modResults.AE.stdRMSE_frc,'ko');
    subplot(2,3,6)
    bar(h,modResults.AE.avgR2_frc), title('AE FORCE R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');  
    hold on
    errorbar(modResults.AE.avgR2_frc,modResults.AE.stdR2_frc,'ko');

fprintf('##### PLOTTING DAE RESULTS #####\n');
figure(2);
    % MSE, RMSE and R2 barplots for EMG
    subplot(2,3,1)
    bar(h,modResults.DAE.avgMSE_emg), title('DAE EMG MSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.DAE.avgMSE_emg,modResults.DAE.stdMSE_emg,'ko');
    subplot(2,3,2)
    bar(h,modResults.DAE.avgRMSE_emg), title('DAE EMG RMSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.DAE.avgRMSE_emg,modResults.DAE.stdRMSE_emg,'ko');
    subplot(2,3,3)
    bar(h,modResults.DAE.avgR2_emg), title('DAE EMG R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.DAE.avgR2_emg,modResults.DAE.stdR2_emg,'ko');
    
    % MSE, RMSE and R2 barplots for FORCE
    subplot(2,3,4)
    bar(h,modResults.DAE.avgMSE_frc), title('DAE FORCE MSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.DAE.avgMSE_frc,modResults.DAE.stdMSE_frc,'ko');
    subplot(2,3,5)
    bar(h,modResults.DAE.avgRMSE_frc), title('DAE FORCE RMSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(modResults.DAE.avgRMSE_frc,modResults.DAE.stdRMSE_frc,'ko');
    subplot(2,3,6)
    bar(h,modResults.DAE.avgR2_frc), title('DAE FORCE R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');  
    hold on
    errorbar(modResults.DAE.avgR2_frc,modResults.DAE.stdR2_frc,'ko');



