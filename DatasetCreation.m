clearvars 
clc
%% Load data
ttds=tabularTextDatastore('./Daniel & Roberto/DB2','FileExtensions','.mat','NumHeaderLines',129);
Sbj = cell(40,1);
for s=1:40
    fprintf('Carico soggetto %d \n',s)
    filename = string(ttds.Files(s));
    Sbj{s} = load(filename);
    Sbj{s,1}.restimulus = Sbj{s,1}.restimulus - 40;
end
%% Constant definition
% t=length(emg); %length of the emg signal
f = 2000; %sampling frequency
ne = 10; %number of electrodes
% movements labels
%   1   |   Little Finger Flexion
%   2   |   Ring Finger Flexion
%   3   |   Medium Finger Flexion
%   4   |   Index Finger Flexion
%   5   X   Thumb Abduction
%   6   X   Thumb Flexion
%   7   |   Index and Little Finger Flexion
%   8   |   Ring and Medium Finger Flexion
%   9   X   Thumb and Index Flexion

%% Remove Triceps and Biceps
for s = 1:40
    Sbj{s,1}.emg(:,12) = [];
    Sbj{s,1}.emg(:,11) = [];
end

%% Segmentation of RawData

for s = 1:40 % soggetti
    fprintf('Segmento soggetto %d \n',s);
    ind = [];
    z = [];
    for i = 1:9 % Movimenti
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
