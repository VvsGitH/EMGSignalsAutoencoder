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
fprintf('##### PLOTTING MEAN RESULTS #####\n');
N = size(plotArray{1},1);
M = size(plotArray{1},2);
groupwidth = min(0.8, M/(M + 1.5));
figure(1)
plotArray = varSelector(avgResults, 0, 0);
for i = 1:6
    subplot(2,3,i)
    bar(plotArray{i}),
    set(gca,'YGrid','on'), xlabel('Number of synergies'),
    hold on
    for j = 1:M
        x = (1:N) - groupwidth/2 + (2*j-1) * groupwidth / (2*M);
        errorbar(x,plotArray{i}(:,j),plotArray{i+6}(:,j),'ko');
    end
end


%% PLOT SINGLE SUBJECT PERFORMANCE GRAPHS


%% PLOT SINGLE SUBJECT SIGNAL GRAPHS


%% FUNCTION

function selResults = varSelector(resStruct, single_multiple, train_test)
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
selResults = cell(M,1);
for m = 1:M
    for n = 1:N
       selResults{m}(:,n)  = resStruct.(selMeth{n}).(selPerf{n,m});
    end
end
% selResults has the following structure:
% M cells, each one corresponds to a performance indexes, in thi order:
%   MSE_emg; MSE_frc; RMSE_emg; RMSE_frc; R2_emg; R2_frc; [...stdIndexes] 
% Each cell contains a 10xN array. The N methods are in this order:
%   LFR, NNMF, AE, DAE

end
