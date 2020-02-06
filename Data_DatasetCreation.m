clearvars 
clc

%% Load data
ttds=tabularTextDatastore('./Daniel & Roberto/DB2','FileExtensions','.mat','NumHeaderLines',129);
Sbj = cell(40,1);
for s=1:40
    fprintf('Loading Subject %d \n',s)
    filename = string(ttds.Files(s));
    Sbj{s} = load(filename);
    Sbj{s,1}.restimulus = Sbj{s,1}.restimulus - 40;
end

%% Remove Triceps and Biceps
for s = 1:40
    Sbj{s,1}.emg(:,12) = [];
    Sbj{s,1}.emg(:,11) = [];
end

%% Post Processing
f = 2000; %sampling frequency
ne = 10; %number of electrodes
for s = 1:40
    fprintf('PostProcessing of Subject: %d\n',s);
    %% band-pass filtering 20-500 Hz
    % Serve a ridurre le oscillazione dei segnali EMG
    bpl = 20;
    bph = 500;
    Wn = [bpl/(f/2),bph/(f/2)];
    [b,a] = butter(2,Wn,'bandpass');
    emgf = filter(b,a,Sbj{s,1}.emg);
    
    %% rectification
    % Per renderlo non negativo
    emgfr = abs(emgf);
    
    %% low-pass filtering 2 Hz
    % Smoothing del segnale
    l = 2;
    Wn = l/(f/2);
    [b,a] = butter(2,Wn,'low');
    emgfrl = filter(b,a,emgfr);
    
    %% cross correlation to adjust delay
    % Il filtraggio applica un delay. La cross-correlazione riallinea il
    % segnale filtrato con quello orginale
    t = size(Sbj{s,1}.emg,1);
    for i = 1:ne
        [rr,lags] = xcorr(emgfr(:,i)',emgfrl(:,i)'); %estimate delay
        [~,d] = max(rr);
        d = t-d;
        emgfrl(:,i) = [emgfrl((d+1:t)',i);zeros(d,1)];
    end
    
    %% elimination of negative elements of the force
    cutforce = zeros(size(Sbj{s,1}.force,1),6);
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

%% Reunification of the signal
% Selecting the way the dataset will be divided
trainRip = [1 3 5];     % Repetitions for the train set
testRip = [2 6];        % Repetitions for the test set
validRip = 4;           % Repetitions for the validation set

% All repetitions and movements will be put one after the other, but in a
% different order from the starting one: TrainSet TestSet ValidSet
% In each set the repetitions and the movements are ordered like this:
% MiRj MiRj+1 ... MiRk Mi+1Rj Mi+1Rj+1 ... Mi+1Rk ... MwRk

DataSet = cell(40,1);
for s = 1:40
    fprintf('Signal Reunification for subject: %d \n',s);
    DataSet{s,1}.emg = [];
    DataSet{s,1}.force = [];
    DataSet{s,1}.cutforce = [];
    % Train set
    for m = mov
        for r = trainRip            
            DataSet{s,1}.emg = [DataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emg];
            DataSet{s,1}.force = [DataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).force];
            DataSet{s,1}.cutforce = [DataSet{s,1}.cutforce, Sbj{s,1}.Mov(m).T(r).cutforce];
        end
    end
    % Test set
    DataSet{s,1}.testIndex = size(DataSet{s,1}.emg,2)+1;    % Starting index of the test set
    for m = mov
        for r = testRip            
            DataSet{s,1}.emg = [DataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emg];
            DataSet{s,1}.force = [DataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).force];
            DataSet{s,1}.cutforce = [DataSet{s,1}.cutforce, Sbj{s,1}.Mov(m).T(r).cutforce];
        end
    end
    % Validation set
    DataSet{s,1}.validIndex = size(DataSet{s,1}.emg,2)+1;   % Starting index of the validation set
    for m = mov
        for r = validRip            
            DataSet{s,1}.emg = [DataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emg];
            DataSet{s,1}.force = [DataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).force];
            DataSet{s,1}.cutforce = [DataSet{s,1}.cutforce, Sbj{s,1}.Mov(m).T(r).cutforce];
        end
    end
end

%% Normalization
for s = 1:40
    fprintf('Signal normalization for subject: %d\n',s);
    % EMG normalization between 0 and 1
    maxEMG = max(DataSet{s,1}.emg,[],2);
    DataSet{s,1}.emg = normalize(DataSet{s,1}.emg,2,'range',[0,1]);
    DataSet{s,1}.maxEmg = maxEMG;
    
    % Force normalization between -1 and 1
    maxForce = max(DataSet{s,1}.force,[],2);
    minForce = min(DataSet{s,1}.force,[],2);
    DataSet{s,1}.force = normalize(DataSet{s,1}.force,2,'range',[-1,1]);
    DataSet{s,1}.maxForce = maxForce;
    DataSet{s,1}.minForce = minForce;
    
    % cutForce normalization between 0 and 1
    DataSet{s,1}.cutforce = normalize(DataSet{s,1}.cutforce,2,'range',[0,1]);
end

%% Saving Full Dataset
if (upper(input('Save the file? [Y,N]\n','s')) == 'Y')
    fprintf('Saving...\n');
    save('Data_FullDataset.mat', 'DataSet')
    fprintf('Saving completed!\n');
end

