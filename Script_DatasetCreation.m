close all
clearvars 
clc

%% Load data
% Loading NinaPro Databes files from './Daniel & Roberto/DB2'
ttds=tabularTextDatastore('./Daniel & Roberto/DB2','FileExtensions','.mat','NumHeaderLines',129);
Sbj = cell(40,1);
for s=1:40
    fprintf('Loading Subject %d \n',s)
    filename = string(ttds.Files(s));
    Sbj{s} = load(filename);
    Sbj{s,1}.restimulus = Sbj{s,1}.restimulus - 40;
end

%% Removing unused channels
for s = 1:40
    % Removing biceps and triceps channels from EMG
    Sbj{s,1}.emg(:,12) = [];
    Sbj{s,1}.emg(:,11) = [];
    % Removing thumb channels from forces
    Sbj{s,1}.force(:,6) = [];
    Sbj{s,1}.force(:,5) = [];
end

%% Post Processing
f  = 2000; % sampling frequency
ne = 10;   % number of electrodes
for s = 1:40
    fprintf('PostProcessing of Subject: %d\n',s);
    %% Band-Pass filtering 20-500 Hz
    % Reduce obscillations of EMG signals
    bpl = 20;
    bph = 500;
    Wn = [bpl/(f/2),bph/(f/2)];
    [b,a] = butter(2,Wn,'bandpass');
    emgf = filter(b,a,Sbj{s,1}.emg);
    
    %% Rectification
    % Make the EMG signal non-negative
    emgfr = abs(emgf);
    
    %% Low-Pass filtering 2 Hz
    % Signal smoothing
    l = 2;
    Wn = l/(f/2);
    [b,a] = butter(2,Wn,'low');
    emgfrl = filter(b,a,emgfr);
    
    %% cross correlation to adjust delay
    % Filtering applies a delay to the signal. Cross-Correlation realigns
    % the filtered signal with the original
    t = size(Sbj{s,1}.emg,1);
    for i = 1:ne
        [rr,lags] = xcorr(emgfr(:,i)',emgfrl(:,i)'); % estimate delay
        [~,d] = max(rr);
        d = t-d;
        emgfrl(:,i) = [emgfrl((d+1:t)',i);zeros(d,1)];
    end
    
    %% elimination of negative elements of the force
    cutforce = zeros(size(Sbj{s,1}.force,1),4);
    posInd = Sbj{s,1}.force>=0;
    cutforce(posInd) = Sbj{s,1}.force(posInd);
    
    %% saving
    Sbj{s,1}.emgpp = emgfrl;
    Sbj{s,1}.cutforce = cutforce;
   
end

%% Segmentation of Data
% Movements List
%   1   |   Little Finger Flexion
%   2   |   Ring Finger Flexion
%   3   |   Medium Finger Flexion
%   4   |   Index Finger Flexion
%   5   X   Thumb Abduction
%   6   X   Thumb Flexion
%   7   |   Index and Little Finger Flexion
%   8   |   Ring and Medium Finger Flexion
%   9   X   Thumb and Index Flexion
mov = [1,2,3,4,7,8];

% Segmentation: dividing the EMG and Force signals into their different
% movements. 6rip x 6mov = 36 blocks. In this way we can eliminate
% the zeros and the movements we do not want to study and we can easily
% reorganize the order of the blocks for the creation of the dataset.
% For the segmentation we use the restimulus: a rectangular wave signal
% that indicates the movements done by the subject; the height of the
% rectangle indicates the movement; the length of the rectangle indicates
% the duration.

for s = 1:40
    fprintf('Segmentation of Subject: %d\n',s);
    ind = [];
    z = [];
    for i = mov                                 % For each one of the selected Movements
        ind = find(Sbj{s,1}.restimulus==i);     % Ind contains the indexes of the elements of restimulus equals to the number of the movement
        ind2 = zeros(1, length(ind));           % Ind2 will be equal to 1 when an two elements of ind are not consecutive
        for j = 2:length(ind)-1                 % For each element of ind, starting from the second
            if (ind(j) ~= ind(j-1)+1)           % Searching for the starting corners of the restimulus signal
                ind2(j) = 1;
            elseif  ind(j)+1 ~= ind(j+1)        % Searching for the ending corners of the restimulus signal
                ind2(j) = 1;
            end
        end
        
        % The repetitions of the movement i start in ind(1) and end in
        % ind(end). However theese repetitions are interrupted by pauses:
        % ind2 is equal to 1 at the start and end of theese pauses.
        z = [ind(1),ind(ind2==1)',ind(end)];    % z has 12 elements: the corners of each repetitions
        
        Sbj{s,1}.Mov(i).T(1).emg = Sbj{s,1}.emgpp(z(1):z(2),:)';
        Sbj{s,1}.Mov(i).T(2).emg = Sbj{s,1}.emgpp(z(3):z(4),:)';
        Sbj{s,1}.Mov(i).T(3).emg = Sbj{s,1}.emgpp(z(5):z(6),:)';
        Sbj{s,1}.Mov(i).T(4).emg = Sbj{s,1}.emgpp(z(7):z(8),:)';
        Sbj{s,1}.Mov(i).T(5).emg = Sbj{s,1}.emgpp(z(9):z(10),:)';
        Sbj{s,1}.Mov(i).T(6).emg = Sbj{s,1}.emgpp(z(11):z(12),:)';
        
        Sbj{s,1}.Mov(i).T(1).cutforce = Sbj{s,1}.cutforce(z(1):z(2),:)';
        Sbj{s,1}.Mov(i).T(2).cutforce = Sbj{s,1}.cutforce(z(3):z(4),:)';
        Sbj{s,1}.Mov(i).T(3).cutforce = Sbj{s,1}.cutforce(z(5):z(6),:)';
        Sbj{s,1}.Mov(i).T(4).cutforce = Sbj{s,1}.cutforce(z(7):z(8),:)';
        Sbj{s,1}.Mov(i).T(5).cutforce = Sbj{s,1}.cutforce(z(9):z(10),:)';
        Sbj{s,1}.Mov(i).T(6).cutforce = Sbj{s,1}.cutforce(z(11):z(12),:)';
        
        Sbj{s,1}.Mov(i).T(1).force = Sbj{s,1}.force(z(1):z(2),:)';
        Sbj{s,1}.Mov(i).T(2).force = Sbj{s,1}.force(z(3):z(4),:)';
        Sbj{s,1}.Mov(i).T(3).force = Sbj{s,1}.force(z(5):z(6),:)';
        Sbj{s,1}.Mov(i).T(4).force = Sbj{s,1}.force(z(7):z(8),:)';
        Sbj{s,1}.Mov(i).T(5).force = Sbj{s,1}.force(z(9):z(10),:)';
        Sbj{s,1}.Mov(i).T(6).force = Sbj{s,1}.force(z(11):z(12),:)';
    end
end

%% Reunification of the signal for the Single Finger Database
movsf = [1,2,3,4];
% Selecting the way the dataset will be divided
trainRip = [1 3 5];     % Repetitions for the train set
testRip = [2 6];        % Repetitions for the test set
validRip = 4;           % Repetitions for the validation set

% All repetitions and movements will be put one after the other, but in a
% different order from the starting one: TrainSet TestSet ValidSet
% In each set the repetitions and the movements are ordered like this:
% MiRj MiRj+1 ... MiRk Mi+1Rj Mi+1Rj+1 ... Mi+1Rk ... MwRk

sfDataSet = cell(40,1);
for s = 1:40
    fprintf('Signal finger dataset generation for subject: %d \n',s);
    sfDataSet{s,1}.emg = [];
    sfDataSet{s,1}.force = [];
    % Train set
    for m = movsf
        for r = trainRip            
            sfDataSet{s,1}.emg = [sfDataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emg];
            sfDataSet{s,1}.force = [sfDataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).cutforce];
        end
    end
    % Test set
    sfDataSet{s,1}.testIndex = size(sfDataSet{s,1}.emg,2)+1;    % Starting index of the test set
    for m = movsf
        for r = testRip            
            sfDataSet{s,1}.emg = [sfDataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emg];
            sfDataSet{s,1}.force = [sfDataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).cutforce];
        end
    end
    % Validation set
    sfDataSet{s,1}.validIndex = size(sfDataSet{s,1}.emg,2)+1;   % Starting index of the validation set
    for m = movsf
        for r = validRip            
            sfDataSet{s,1}.emg = [sfDataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emg];
            sfDataSet{s,1}.force = [sfDataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).cutforce];
        end
    end
end

%% Reunification of the signal for the Single and Multiple Finger Database
% Same division as the precedent

fullDataSet = cell(40,1);
for s = 1:40
    fprintf('Multiple finger dataset generation for subject: %d \n',s);
    fullDataSet{s,1}.emg = [];
    fullDataSet{s,1}.force = [];
    % Train set
    for m = mov
        for r = trainRip            
            fullDataSet{s,1}.emg = [fullDataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emg];
            fullDataSet{s,1}.force = [fullDataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).cutforce];
        end
    end
    % Test set
    fullDataSet{s,1}.testIndex = size(fullDataSet{s,1}.emg,2)+1;    % Starting index of the test set
    for m = mov
        for r = testRip            
            fullDataSet{s,1}.emg = [fullDataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emg];
            fullDataSet{s,1}.force = [fullDataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).cutforce];
        end
    end
    % Validation set
    fullDataSet{s,1}.validIndex = size(fullDataSet{s,1}.emg,2)+1;   % Starting index of the validation set
    for m = mov
        for r = validRip            
            fullDataSet{s,1}.emg = [fullDataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emg];
            fullDataSet{s,1}.force = [fullDataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).cutforce];
        end
    end
end

%% Saving signals max and min for future de/normalization
for s = 1:40
	% EMG 
    maxEMG = max(sfDataSet{s,1}.emg,[],2);
    sfDataSet{s,1}.maxEmg = maxEMG;
    maxEMG = max(fullDataSet{s,1}.emg,[],2);
    fullDataSet{s,1}.maxEmg = maxEMG;
    
    % FORCE
    maxForce = max(sfDataSet{s,1}.force,[],2);
    sfDataSet{s,1}.maxForce = maxForce;
    maxForce = max(fullDataSet{s,1}.force,[],2);
    fullDataSet{s,1}.maxForce = maxForce;
end

%% Saving Full Dataset
if (upper(input('Save the file? [Y,N]\n','s')) == 'Y')
    fprintf('Saving sfDataSet...\n');
    save('Data_sfDataSet.mat', 'sfDataSet')
    fprintf('Saving fullDataSet...\n');
    save('Data_fullDataSet.mat', 'fullDataSet')
    fprintf('Saving completed!\n');
end

