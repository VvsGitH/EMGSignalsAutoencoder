clearvars 
clc
%% Load data
ttds=tabularTextDatastore('./Daniel & Roberto/DB2','FileExtensions','.mat','NumHeaderLines',129);
S = cell(40,1);
for s=1:40
    fprintf('Soggetto %d \n',s)
    filename=string(ttds.Files(s));
    S{s} = load(filename);
end
%% Constant definition
t=length(emg); %length of the emg signal
f=2000; %sampling frequency
ne=12; %number of electrodes