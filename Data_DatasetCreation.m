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

%% Remove Unused Movements
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

%% Segmentation of RawData
for s = 1:40 % soggetti
    fprintf('Segmentation of Subject %d \n',s);
    ind = [];
    z = [];
    for i = mov % Movimenti
        ind = find(Sbj{s,1}.restimulus==i);
        ind2 = zeros(1, length(ind));
        for r = 2:length(ind)-1 % Ripetizioni
            if (ind(r) ~= ind(r-1)+1)
                ind2(r) = 1;
            elseif  ind(r)+1 ~= ind(r+1)
                ind2(r) = 1;
            end
        end
        z = [ind(1),ind(ind2==1)',ind(end)];
        Sbj{s,1}.Mov(i).T(1).emg = Sbj{s,1}.emg(z(1):z(2),:)';
        Sbj{s,1}.Mov(i).T(2).emg = Sbj{s,1}.emg(z(3):z(4),:)';
        Sbj{s,1}.Mov(i).T(3).emg = Sbj{s,1}.emg(z(5):z(6),:)';
        Sbj{s,1}.Mov(i).T(4).emg = Sbj{s,1}.emg(z(7):z(8),:)';
        Sbj{s,1}.Mov(i).T(5).emg = Sbj{s,1}.emg(z(9):z(10),:)';
        Sbj{s,1}.Mov(i).T(6).emg = Sbj{s,1}.emg(z(11):z(12),:)';
        Sbj{s,1}.Mov(i).T(1).force = Sbj{s,1}.force(z(1):z(2),:)';
        Sbj{s,1}.Mov(i).T(2).force = Sbj{s,1}.force(z(3):z(4),:)';
        Sbj{s,1}.Mov(i).T(3).force = Sbj{s,1}.force(z(5):z(6),:)';
        Sbj{s,1}.Mov(i).T(4).force = Sbj{s,1}.force(z(7):z(8),:)';
        Sbj{s,1}.Mov(i).T(5).force = Sbj{s,1}.force(z(9):z(10),:)';
        Sbj{s,1}.Mov(i).T(6).force = Sbj{s,1}.force(z(11):z(12),:)';
    end
end

%% Post Processing
f = 2000; %sampling frequency
ne = 10; %number of electrodes
for s = 1:40
    fprintf('PostProcessing of Subject: %d\n',s);
    for m = mov
        for r = 1:6
            %% band-pass filtering 20-500 Hz
            % Serve a ridurre le oscillazione dei segnali EMG
            bpl = 20;
            bph = 500;
            Wn = [bpl/(f/2),bph/(f/2)];
            [b,a] = butter(2,Wn,'bandpass');
            emgf = filter(b,a,Sbj{s,1}.Mov(m).T(r).emg);
            
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
            t = size(Sbj{s,1}.Mov(m).T(r).emg,1);
            for i = 1:ne
                [rr,lags] = xcorr(emgfr(:,i)',emgfrl(:,i)'); %estimate delay
                [~,d] = max(rr);
                d = t-d;
                emgfrl(:,i) = [emgfrl((d+1:t)',i);zeros(d,1)];
            end
            
            %% normalization
            % normalization between 0 and 1
            emgfrln = normalize(emgfrl,2,'range');
            
            % z-score normalization
            %   X = (x - mean(x))/dev_std(x))
            % emgfrln = normalize(emgfrl, 'zscore');   
            
            Sbj{s,1}.Mov(m).T(r).emgpp = emgfrln;
        end
    end
end

%% Signals Length Analisys
fprintf('Signal Length Analisys\n');
dimVector = [];
for s = 1:40
    for m = mov
        for r = 1:6
            dimVector = [dimVector, size(Sbj{s,1}.Mov(m).T(r).emgpp,2)]; 
        end
    end
end
histogram(dimVector);

%% Test and Train Dataset Generation
trainRip = [1 3 5];
testRip = [2 4 6];

fprintf('Generating Train DataSet\n');
TrainDataSet = cell(40,1);
for s = 1:40
    TrainDataSet{s,1}.emg = [];
    TrainDataSet{s,1}.force = [];
    for m = mov
        for r = trainRip            
            TrainDataSet{s,1}.emg = [TrainDataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emgpp];
            TrainDataSet{s,1}.force = [TrainDataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).force];
        end
    end
end

fprintf('Generating Test DataSet\n');
TestDataSet = cell(40,1);
for s = 1:40
    TestDataSet{s,1}.emg = [];
    TestDataSet{s,1}.force = [];
    for m = mov
        for r = testRip            
            TestDataSet{s,1}.emg = [TestDataSet{s,1}.emg, Sbj{s,1}.Mov(m).T(r).emgpp];
            TestDataSet{s,1}.force = [TestDataSet{s,1}.force, Sbj{s,1}.Mov(m).T(r).force];
        end
    end
end

%% Saving Dataset
fprintf('Saving...\n');
save('Data_TrainDataset.mat', 'TrainDataSet');
save('Data_TestDataset.mat', 'TestDataSet');


