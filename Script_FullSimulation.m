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
% Initialization
fprintf('##### TRAINING SIMULATION LOOP #####\n');
LFRsims_sf = cell(40,1);    LFRsims_mf = cell(40,1);
NNMFsims_sf = cell(40,1);   NNMFsims_mf = cell(40,1);
AEsims_sf = cell(40,1);     AEsims_mf = cell(40,1);
DAEsims_sf = cell(40,1);    DAEsims_mf = cell(40,1);
% Loop start
selector = 1:4;
for trSogg = selSbj
    fprintf('Subject: %d\n', trSogg);
    %% DATA SELECTION
    EMGsf       = sfDataSet{trSogg}.emg;
    maxEMGsf	= sfDataSet{trSogg}.maxEmg;
    EMGmf       = fullDataSet{trSogg}.emg;
    maxEMGmf	= fullDataSet{trSogg}.maxEmg;
    FORCEsf     = sfDataSet{trSogg}.force;
    maxFORCEsf	= sfDataSet{trSogg}.maxForce;
    FORCEmf     = fullDataSet{trSogg}.force;
    maxFORCEmf	= fullDataSet{trSogg}.maxForce;
    %% DATA NORMALIZATION
    EMGsf_DAE   = normalize(EMGsf,2,'range',[0 r_emg]);
    EMGsf	    = normalize(EMGsf,2,'range',[0 1]);
    EMGmf_DAE   = normalize(EMGmf,2,'range',[0 r_emg]);
    EMGmf	    = normalize(EMGmf,2,'range',[0 1]);
    FORCEsf_DAE = normalize(FORCEsf,2,'range',[0 r_frc]);
    FORCEmf_DAE = normalize(FORCEmf,2,'range',[0 r_frc]);
    %% SEPARATION INDEXES    
    TIsf        = sfDataSet{trSogg}.testIndex; 
    TImf        = fullDataSet{trSogg}.testIndex; 
    VIsf        = sfDataSet{trSogg}.validIndex;
    VImf        = fullDataSet{trSogg}.validIndex; 
    %% LFR METH OD
   if any(selector == 1)
    fprintf('   LFR: single fingers\n');
    LFRsims_sf{trSogg}  = meth1_LFR(EMGsf, FORCEsf, [TIsf, VIsf]);
    fprintf('   LFR: multiple fingers\n');
    LFRsims_mf{trSogg}  = meth1_LFR(EMGmf, FORCEmf, [TImf, VImf]);
   end
   %% NNMF METHOD
   if any(selector == 2)
    fprintf('   NNMF: single fingers\n');
    NNMFsims_sf{trSogg} = meth2_NNMF(EMGsf, FORCEsf, maxEMGsf, [TIsf, VIsf]);
    fprintf('   NNMF: multiple fingers\n');
    NNMFsims_mf{trSogg} = meth2_NNMF(EMGmf, FORCEmf, maxEMGmf, [TImf, VImf]);
   end
   %% AE METHOD
   if any(selector == 3)
    fprintf('   AE: single fingers\n');
    AEsims_sf{trSogg}   = meth3_AE(EMGsf, FORCEsf, maxEMGsf, [TIsf, VIsf], maxEpochs);
    fprintf('   AE: multiple fingers\n');
    AEsims_mf{trSogg}   = meth3_AE(EMGmf, FORCEmf, maxEMGmf, [TImf, VImf], maxEpochs);
   end
   %% DAE METHOD
   if any(selector == 4)
    fprintf('   DAE: single fingers\n');
    DAEsims_sf{trSogg} = meth4_DAE(EMGsf_DAE, FORCEsf_DAE, maxEMGsf, maxFORCEsf, [TIsf, VIsf], maxEpochs);
    fprintf('   DAE: multiple fingers\n');
    DAEsims_mf{trSogg}  = meth4_DAE(EMGmf_DAE, FORCEmf_DAE, maxEMGmf, maxFORCEmf, [TImf, VImf], maxEpochs);
   end
    
end

%% GENERATION OF SIMRESULT STRUCTURE
simResults = cell(40,1);
for trSogg = selSbj
    simResults{trSogg}.LFR.SF  = LFRsims_sf{trSogg};
    simResults{trSogg}.LFR.MF  = LFRsims_mf{trSogg};
    simResults{trSogg}.NNMF.SF = NNMFsims_sf{trSogg};
    simResults{trSogg}.NNMF.MF = NNMFsims_mf{trSogg};
    simResults{trSogg}.AE.SF   = AEsims_sf{trSogg};
    simResults{trSogg}.AE.MF   = AEsims_mf{trSogg};
    simResults{trSogg}.DAE.SF  = DAEsims_sf{trSogg};
    simResults{trSogg}.DAE.MF  = DAEsims_mf{trSogg};  
end

%% GENERATING THE AVGRESULT STRUCTURE
avgResults.LFR.SF  = dataSimResults(LFRsims_sf, selSbj);
avgResults.LFR.MF  = dataSimResults(LFRsims_mf, selSbj);
avgResults.NNMF.SF = dataSimResults(NNMFsims_sf, selSbj);
avgResults.NNMF.MF = dataSimResults(NNMFsims_mf, selSbj);
avgResults.AE.SF   = dataSimResults(AEsims_sf, selSbj);
avgResults.AE.MF   = dataSimResults(AEsims_mf, selSbj);
avgResults.DAE.SF  = dataSimResults(DAEsims_sf, selSbj);
avgResults.DAE.MF  = dataSimResults(DAEsims_mf, selSbj);

%% SAVING
if (upper(input('Save the results? [Y,N]\n','s')) == 'Y')
    fprintf('Insert the filename: (press enter to use the default one)\n');
    filename = 'Data_fullResults';
    filename = [filename, input(filename,'s'),'.mat'];
    fprintf('Saving...\n');
    save(filename,'simResults','avgResults');
    fprintf('%s saved!\n',filename);
end

