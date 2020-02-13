close all
clearvars
clc
rng('default')
pool = gcp;

%% SETTING UP
fprintf('##### LOADING DATA #####\n');
load Data_fullDataset
load Data_sfDataset

% Selecting Subjects
selSbj = [4, 10, 16, 17, 21];  % best five subjects
N = length(selSbj);

% Setting max training epochs
maxEpochs = 1000;

% DAE: different normalization for output balance
[r_emg, r_frc] = netDAEoutputNorm(fullDataSet{1}.emg, fullDataSet{1}.force);

%% TRAINING SIMULATION LOOP
fprintf('##### TRAINING SIMULATION LOOP #####\n');
LFRsims_sf = cell(40,1);    LFRsims_mf = cell(40,1);
NNMFsims_sf = cell(40,1);   NNMFsims_mf = cell(40,1);
AEsims_sf = cell(40,1);     AEsims_mf = cell(40,1);
DAEsims_sf = cell(40,1);    DAEsims_mf = cell(40,1);
for trSogg = selSbj
    
    fprintf('Subject: %d\n', trSogg);
    
    EMGsf       = sfDataSet{trSogg}.emg;
    maxEMGsf	= sfDataSet{trSogg}.maxEmg;
    EMGmf       = fullDataSet{trSogg}.emg;
    maxEMGmf	= fullDataSet{trSogg}.maxEmg;
    
    FORCEsf     = sfDataSet{trSogg}.force;
    maxFORCEsf	= sfDataSet{trSogg}.maxForce;
    FORCEmf     = fullDataSet{trSogg}.force;
    maxFORCEmf	= fullDataSet{trSogg}.maxForce;
    
    EMGsf_DAE   = normalize(EMGsf,2,'range',[0 r_emg]);
    EMGsf	    = normalize(EMGsf,2,'range',[0 1]);
    EMGmf_DAE   = normalize(EMGmf,2,'range',[0 r_emg]);
    EMGmf	    = normalize(EMGmf,2,'range',[0 1]);
    
    FORCEsf_DAE   = normalize(FORCEsf,2,'range',[0 r_frc]);
    FORCEmf_DAE   = normalize(FORCEmf,2,'range',[0 r_frc]);
        
    TIsf       = sfDataSet{trSogg}.testIndex; 
    TImf       = fullDataSet{trSogg}.testIndex; 
    VIsf       = sfDataSet{trSogg}.validIndex;
    VImf       = fullDataSet{trSogg}.testIndex; 
    
%     fprintf('   LFR: single fingers\n');
%     LFRsims_sf{trSogg}  = meth1_LFR(EMGsf, FORCEsf, [TIsf, VIsf]);
%     fprintf('   LFR: multiple fingers\n');
%     LFRsims_mf{trSogg}  = meth1_LFR(EMGmf, FORCEmf, [TImf, VImf]);
    
    fprintf('   NNMF: single fingers\n');
    NNMFsims_sf{trSogg} = meth2_NNMF(EMGsf, FORCEsf, maxEMGsf, [TIsf, VIsf]);
    fprintf('   NNMF: single fingers\n');
    NNMFsims_mf{trSogg} = meth2_NNMF(EMGmf, FORCEmf, maxEMGmf, [TImf, VImf]);
    
%     fprintf('   AE: single fingers\n');
%     AEsims_sf{trSogg}   = meth3_AE(EMGsf, FORCEsf, maxEMGsf, [TIsf, VIsf], maxEpochs);
%     fprintf('   AE: multiple fingers\n');
%     AEsims_mf{trSogg}   = meth3_AE(EMGmf, FORCEmf, maxEMGmf, [TImf, VImf], maxEpochs);
%     
%     fprintf('   DAE: single fingers\n');
%     DAEsims_sf{trSogg}  = meth4_DAE(EMGsf_DAE, FORCEsf_DAE, maxEMGsf, maxFORCEsf, [TIsf, VIsf], maxEpochs);
%     fprintf('   DAE: multiple fingers\n');
%     DAEsims_mf{trSogg}  = meth4_DAE(EMGmf_DAE, FORCEmf_DAE, maxEMGmf, maxFORCEmf, [TImf, VImf], maxEpochs);
    
end

%% MEAN PERFORMANCE
fprintf('##### CALCULATING PERFORMANCES #####\n');

simResults = cell(40,1);
for trSogg = selSbj
    simResults{trSogg}.LFR_sf  = LFRsims_sf{trSogg};
    simResults{trSogg}.LFR_mf  = LFRsims_mf{trSogg};
    simResults{trSogg}.NNMF_sf = NNMFsims_sf{trSogg};
    simResults{trSogg}.NNMF_mf = NNMFsims_mf{trSogg};
    simResults{trSogg}.AE_sf   = AEsims_sf{trSogg};
    simResults{trSogg}.AE_mf   = AEsims_mf{trSogg};
    simResults{trSogg}.DAE_sf  = DAEsims_sf{trSogg};
    simResults{trSogg}.DAE_sf  = DAEsims_mf{trSogg};  
end

avgResults.LFR_sf  = dataSimResults(LFRsims_sf, selSbj);
avgResults.LFR_mf  = dataSimResults(LFRsims_mf, selSbj);
avgResults.NNMF_sf = dataSimResults(NNMFsims_sf, selSbj);
avgResults.NNMF_mf = dataSimResults(NNMFsims_mf, selSbj);
avgResults.AE_sf   = dataSimResults(AEsims_sf, selSbj);
avgResults.AE_mf   = dataSimResults(AEsims_mf, selSbj);
avgResults.DAE_sf  = dataSimResults(DAEsims_sf, selSbj);
avgResults.DAE_mf  = dataSimResults(DAEsims_mf, selSbj);

%% SAVING
if (upper(input('Save the results? [Y,N]\n','s')) == 'Y')
    fprintf('Insert the filename: (press enter to use the default one)\n');
    filename = 'Data_fullResults';
    filename = [filename, input(filename,'s'),'.mat'];
    fprintf('Saving...\n');
    save(filename,'simResults','avgResults');
    fprintf('%s saved!\n',filename);
end

%% PLOTTING (TO DO: SPOSTA QUESTA PARTE IN SCRIPT_PLOTRESULTS)
h = 1:10;

fprintf('##### PLOTTING AE RESULTS #####\n');
figure(1);
    % MSE, RMSE and R2 barplots for EMG
    subplot(2,3,1)
    bar(h,simResults.AE.avgMSE_emg), title('AE EMG MSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.AE.avgMSE_emg,simResults.AE.stdMSE_emg,'ko');
    subplot(2,3,2)
    bar(h,simResults.AE.avgRMSE_emg), title('AE EMG RMSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.AE.avgRMSE_emg,simResults.AE.stdRMSE_emg,'ko');
    subplot(2,3,3)
    bar(h,simResults.AE.avgR2_emg), title('AE EMG R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.AE.avgR2_emg,simResults.AE.stdR2_emg,'ko');
    
    % MSE, RMSE and R2 barplots for FORCE
    subplot(2,3,4)
    bar(h,simResults.AE.avgMSE_frc), title('AE FORCE MSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.AE.avgMSE_frc,simResults.AE.stdMSE_frc,'ko');
    subplot(2,3,5)
    bar(h,simResults.AE.avgRMSE_frc), title('AE FORCE RMSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.AE.avgRMSE_frc,simResults.AE.stdRMSE_frc,'ko');
    subplot(2,3,6)
    bar(h,simResults.AE.avgR2_frc), title('AE FORCE R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');  
    hold on
    errorbar(simResults.AE.avgR2_frc,simResults.AE.stdR2_frc,'ko');

fprintf('##### PLOTTING DAE RESULTS #####\n');
figure(2);
    % MSE, RMSE and R2 barplots for EMG
    subplot(2,3,1)
    bar(h,simResults.DAE.avgMSE_emg), title('DAE EMG MSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgMSE_emg,simResults.DAE.stdMSE_emg,'ko');
    subplot(2,3,2)
    bar(h,simResults.DAE.avgRMSE_emg), title('DAE EMG RMSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgRMSE_emg,simResults.DAE.stdRMSE_emg,'ko');
    subplot(2,3,3)
    bar(h,simResults.DAE.avgR2_emg), title('DAE EMG R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgR2_emg,simResults.DAE.stdR2_emg,'ko');
    
    % MSE, RMSE and R2 barplots for FORCE
    subplot(2,3,4)
    bar(h,simResults.DAE.avgMSE_frc), title('DAE FORCE MSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgMSE_frc,simResults.DAE.stdMSE_frc,'ko');
    subplot(2,3,5)
    bar(h,simResults.DAE.avgRMSE_frc), title('DAE FORCE RMSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgRMSE_frc,simResults.DAE.stdRMSE_frc,'ko');
    subplot(2,3,6)
    bar(h,simResults.DAE.avgR2_frc), title('DAE FORCE R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');  
    hold on
    errorbar(simResults.DAE.avgR2_frc,simResults.DAE.stdR2_frc,'ko');



