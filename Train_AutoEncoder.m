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
while all(1:40 ~= trSogg)
    trSogg = input('The chosen subject is not existent!\nInput Subject Number: ');
end

% Naming variable for a clean code
EMG         = DataSet{trSogg}.emg;
EMG			= normalize(EMG,2,'range',[0 1]);
maxEMG		= DataSet{trSogg}.maxEmg;

forceOption = input('Press 1 for force or 2 for cutforce: ');
while all(1:2 ~= forceOption)
    forceOption = input('Option not find!\nPress 1 for force or 2 for cutforce: ');
end
if forceOption == 1
    FORCE   = DataSet{trSogg}.force;
elseif forceOption == 2
    FORCE   = DataSet{trSogg}.cutforce;
end

% Dividing train test and validation for simulation and force reconstruction 
TI = DataSet{trSogg}.testIndex; VI = DataSet{trSogg}.validIndex; END = length(DataSet{trSogg}.emg);
[EMG_Train, EMG_Valid, EMG_Test] = divideind(EMG, 1:TI-1, VI:END,  TI:VI-1);
[FORCE_Train, FORCE_Valid, FORCE_Test] = divideind(FORCE, 1:TI-1, VI:END,  TI:VI-1);

% [Optional] Uncomment to use dividetrain
% EMG = EMG_Train;
% EMG_Test = [EMG_Test, EMG_Valid];
% FORCE_Test = [FORCE_Test, FORCE_Valid];

%% TRAINING/SIMULATION LOOP
MSE_emg = zeros(1,10); MSE_frc = zeros(1,10);
RMSE_emg = zeros(1,10); RMSE_frc = zeros(1,10);
R2_emg = zeros(1,10); R2_frc = zeros(1,10);
trainedNet = cell(1,10); trainingReport = cell(1,10);
emgToForceMatrix = cell(1,10);

parfor h = 1:10
    
    fprintf('H%d: Generating Net...\n',h);
    net = netAutoEncoder(h, EMG, 10000, [TI, VI]); % divideind
    
    %% TRAINING
    fprintf('H%d: Training...\n',h);
    [trNet, tr] = train(net,EMG,EMG,'useParallel','no');
    trainedNet{1,h} = trNet;
    trainingReport{1,h} = tr;
    
    %% SIMULATION
    fprintf('H%d: Simulation...\n',h);
    EMG_Recos = trNet(EMG_Test,'useParallel','no');
    
    %% FORCE RECONSTRUCTION
    fprintf('H%d: Force Reconstruction...\n',h);
    inputWeigths = cell2mat(trNet.IW);
    S_Train = poslin(inputWeigths*EMG_Train); % tf -> poslin
    Hae = FORCE_Train*pinv(S_Train);
    emgToForceMatrix{1,h} = Hae;
    S_Test = poslin(inputWeigths*EMG_Test); % tf -> poslin
    FORCE_Recos = Hae*S_Test;
    
    %% PERFORMANCE
    % Performance for the reconstruction of EMG signal
    fprintf('H%d_EMG: Calculating performance indexes...\n',h)
	EMG_Test_den  = dataDenormalize(EMG_Test,0,1,maxEMG);
	EMG_Recos_den = dataDenormalize(EMG_Recos,0,1,maxEMG);
    [mse_emg, rmse_emg, r2_emg] = dataPerformance(EMG_Test_den, EMG_Recos_den);
    fprintf('   The mse is: %d\n   The RMSE is: %d\n   The R2 is: %d\n',...
        mse_emg,rmse_emg,r2_emg);
    
    % Performance for the reconstruction of Forces
    fprintf('H%d_FORCE: Calculating performance indexes...\n',h)
    [mse_frc, rmse_frc, r2_frc] = dataPerformance(FORCE_Test, FORCE_Recos);
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
AEsim.subject = trSogg';
AEsim.trainedNet = trainedNet';
AEsim.trainingReport = trainingReport';
AEsim.emgToForceMatrix = emgToForceMatrix';
AEsim.MSE_emg = MSE_emg';
AEsim.MSE_frc = MSE_frc';
AEsim.RMSE_emg = RMSE_emg';
AEsim.RMSE_frc = RMSE_frc';
AEsim.R2_emg = R2_emg';
AEsim.R2_frc = R2_frc';

if (upper(input('Save the file? [Y,N]\n','s')) == 'Y')
    fprintf('Insert the filename: (press enter to use the default one)\n');
    filename = ['AEsim_sbj', num2str(trSogg), '_allSizes'];
    filename = [filename, input(filename,'s'),'.mat'];
    fprintf('Saving...\n');
    save(filename,'AEsim');
    fprintf('%s saved!\n',filename);
end

%% PLOTTING PERFOMANCE INDEXES
fprintf('Plotting Performance Indexes...\n')
h = 1:10;
figure(1);
    % MSE, RMSE and R2 barplots for EMG
    subplot(2,3,1)
    bar(h,AEsim.MSE_emg), title('EMG MSE'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    subplot(2,3,2)
    bar(h,AEsim.RMSE_emg), title('EMG RMSE'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');    
    subplot(2,3,3)
    bar(h,AEsim.R2_emg), title('EMG R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');    
    subplot(2,3,4)
    
    % MSE, RMSE and R2 barplots for FORCE
    bar(h,AEsim.MSE_frc), title('FORCE MSE'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    subplot(2,3,5)
    bar(h,AEsim.RMSE_frc), title('FORCE RMSE'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');    
    subplot(2,3,6)
    bar(h,AEsim.R2_frc), title('FORCE R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');   

%% PLOTTING RECONSTRUCTED SIGNALS
fprintf('Plotting Signals...\n')
t1 = 1:1:size(EMG_Test,2);
for h = 1:10
    % Calculating EMG_Recos and plotting EMG signals
    EMG_Recos = AEsim.trainedNet{h}(EMG_Test,'useParallel','no');
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
    inputWeigths = cell2mat(AEsim.trainedNet{h}.IW);
    S_Test = elliotsig(inputWeigths*EMG_Test);
    FORCE_Recos = AEsim.emgToForceMatrix{h}*S_Test;
    figure(2*h+1)
    for i = 1:6
        subplot(2,3,i)
        plot(t1,FORCE_Test(i,:),'b');
        hold on
        plot(t2,FORCE_Recos(i,:),'r');
    end
    sgtitle(['H' num2str(h) ': FORCE'])
end   

