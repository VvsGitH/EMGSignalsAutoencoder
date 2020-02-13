% This script loads the dataset and the results of the simulations done with the different
% methods and plot graphs to illustrate the results.

clearvars
close all
clc

%% LOADING DATA
% load Data_fullDataset
% load Data_sfDataset
load Data_fullResults


%% PLOT MEAN PERFORMANCE GRAPHS
h = 1:10;

fprintf('##### PLOTTING MEAN RESULTS #####\n');
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

%% PLOT SINGLE SUBJECT PERFORMANCE GRAPHS


%% PLOT SINGLE SUBJECT SIGNAL GRAPHS


%% FUNCTION

function selMeth = varSelector(resStruct, single_multiple, train_test)
%%
fields = fieldnames(resStruct);
N = length(fields);
selMeth = cell(N,1);
if single_multiple == 0
    for n = 1:N
        if strfind(fields{n},'_sf') ~= 0
            selMeth{n} = fields{n};
        end
    end
else
    for n = 1:N
        if strfind(fields{n},'_mf') ~= 0
            selMeth{n} = fields{n};
        end
    end
end

%% eliminiamo gli elementi nulli da sellMeth
selMeth = selMeth(~cellfun(@isempty, selMeth));

%%
N = length(selMeth);
M = length(fieldnames(resStruct.(selMeth{1})));
selPerf = cell(N,M);
for n = 1:N
    fields = fieldnames(resStruct.(selMeth{n}));    
    if train_test == 0
        for m = 1:M
            if strfind(fields{m},'_tr') ~= 0
                selPerf{n,m} = fields{m};
            end
        end
    else
        for m = 1:M
            if strfind(fields{m},'_ts') ~= 0
                selPerf{n,m} = fields{m};
            end
        end
    end
    
end

%% eliminiamo gli elementi nulli da selPerf
selPerf(:,any(cellfun(@isempty, selPerf),1)) = [];

%% Creiamo una nuova struttura
N = length(selMeth);
M = length(selPerf);
for n = 1:N
    for m = 1:M
        output.(selMeth{n}).(selPerf{n,m}) = resStruct.(selMeth{n}).(selPerf{n,m});
    end
end

end
