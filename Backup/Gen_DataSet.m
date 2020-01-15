clearvars -except Subject
close all
clc

%% Settings
fprintf("Loading Data...\n");
load('All_Subjects.mat');
nsogg = 40;
% movements labels
%   1   |   Little Finger Flexion
%   2   |   Ring Finger Flexion
%   3   |   Medium Finger Flexion
%   4   |   Index Finger Flexion
%   5   |   Thumb Abduction
%   6   |   Thumb Flexion
%   7   |   Index and Little Finger Flexion
%   8   |   Ring and Medium Finger Flexion
%   9   |   Thumb and Index Flexion
train_mov = 1:4;  % Selected Movements: single finger, no thumb
test_mov = [1:4,7,8]; % Single e Multiple fingers, no thumb
ntrmov = length(train_mov); % number of train movements
ntsmov = length(test_mov); % number of test movements
nrip = 3; % Three repetitions for training (odds9 and three for testing (even)  

%% Generating Train Set
fprintf("Generating Train Set...\n");
% Initializing
EMG_rip = cell(1,nrip);
FORCE_rip = cell(1,nrip);
EMG_mov = cell(1,nrip*ntrmov);
FORCE_mov = cell(1,nrip*ntrmov);
EMG_train = cell(1,nrip*ntrmov*nsogg);
FORCE_train = cell(1,nrip*ntrmov*nsogg);
fn_mov = 0;
% Generating Dataset
for s = 1:40
    fprintf("Subject: %d   ",s)
    Movements = Subject(s).Mov(train_mov);
    fn_rip = 0;
    for m = 1:ntrmov
        for r = 1:nrip % ODD REPETITIONS
            EMG_rip{r} = Movements(m).T(2*r-1).emg;
            FORCE_rip{r} = Movements(m).T(2*r-1).force;
        end
        in = fn_rip+1; fn_rip = in+size(EMG_rip,2)-1;
        EMG_mov(in:fn_rip) = EMG_rip(:);
        FORCE_mov(in:fn_rip) = FORCE_rip(:);
    end
    in = fn_mov+1; fn_mov = in+size(EMG_mov,2)-1;
    EMG_train(in:fn_mov) = EMG_mov(:);
    FORCE_train(in:fn_mov) = FORCE_mov(:);
end
clear EMG_rip FORCE_rip EMG_mov FORCE_mov Movements fn_mov fn_rip s r m in
fprintf("\n");

%% Generating Test Set
fprintf("Generating Test Set...\n");
% Initializing
EMG_rip = cell(1,nrip);
FORCE_rip = cell(1,nrip);
EMG_mov = cell(1,nrip*ntsmov);
FORCE_mov = cell(1,nrip*ntsmov);
EMG_test = cell(1,nrip*ntsmov*nsogg);
FORCE_test = cell(1,nrip*ntsmov*nsogg);
fn_mov = 0;
% Generating Dataset
for s = 1:40
    fprintf("Subject: %d   ",s)
    Movements = Subject(s).Mov(test_mov);
    fn_rip = 0;
    for m = 1:ntsmov
        for r = 1:nrip % EVEN REPETITIONS
            EMG_rip{r} = Movements(m).T(2*r).emg;
            FORCE_rip{r} = Movements(m).T(2*r).force;
        end
        in = fn_rip+1; fn_rip = in+size(EMG_rip,2)-1;
        EMG_mov(in:fn_rip) = EMG_rip(:);
        FORCE_mov(in:fn_rip) = FORCE_rip(:);
    end
    in = fn_mov+1; fn_mov = in+size(EMG_mov,2)-1;
    EMG_test(in:fn_mov) = EMG_mov(:);
    FORCE_test(in:fn_mov) = FORCE_mov(:);
end
clear EMG_rip FORCE_rip EMG_mov FORCE_mov Movements fn_mov fn_rip s r m in
fprintf("\n");

%% Uniforming the length of the signals
fprintf("Uniforming signal length... \n");
lEmgTr = zeros(1,size(EMG_train,2));
lEmgTs = zeros(1,size(EMG_test,2));
lFrcTr = zeros(1,size(FORCE_train,2));
lFrcTs = zeros(1,size(FORCE_test,2));
% Generating a vector containing the length of the train signals
for i = 1:size(EMG_train,2)
    lEmgTr(i) = size(EMG_train{i},2); 
    lFrcTr(i) = size(FORCE_train{i},2); 
end
% Generating a vector containing the length of the test signals
for i = 1:size(EMG_test,2)
    lEmgTs(i) = size(EMG_test{i},2); 
    lFrcTs(i) = size(FORCE_test{i},2); 
end
% Calculating max e min length of the EMG and Force signals
minLengthEmg = min(min(lEmgTr),min(lEmgTs));
fprintf("The min length of the EMG signals is: %d\n", minLengthEmg);
maxLengthEmg = max(max(lEmgTr),max(lEmgTs));
fprintf("The max length of the EMG signals is: %d\n", maxLengthEmg);
minLengthForce = min(min(lFrcTr),min(lFrcTs));
fprintf("The min length of the FORCE signals is: %d\n", minLengthForce);
maxLengthForce = max(max(lFrcTr),max(lFrcTs));
fprintf("The max length of the FORCE signals is: %d\n", maxLengthForce);
% Completing the short training signals with zeros
for i = 1:size(EMG_train,2)
    if lEmgTr(i) ~= maxLengthEmg
        EMG_train{i} = [EMG_train{i}, zeros(12,maxLengthEmg-lEmgTr(i))];
    end
    if lFrcTr(i) ~= maxLengthForce
        FORCE_train{i} = [FORCE_train{i}, zeros(6,maxLengthForce-lFrcTr(i))];
    end
end
% Completing the short testing signals with zeros
for i = 1:size(EMG_test,2)
    if lEmgTs(i) ~= maxLengthEmg
        EMG_test{i} = [EMG_test{i}, zeros(12,maxLengthEmg-lEmgTs(i))];
    end
    if lFrcTs(i) ~= maxLengthForce
        FORCE_test{i} = [FORCE_test{i}, zeros(6,maxLengthForce-lFrcTs(i))];
    end
end
clear i
fprintf("END\n")

%% SAVING
fprintf("Saving... ")
save('TrainDataSet.mat','EMG_train','FORCE_train');
save('TestDataSet.mat','EMG_test','FORCE_test');
fprintf("END\n")
