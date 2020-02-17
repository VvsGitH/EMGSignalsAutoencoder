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
count = 1;
sgtitleArray{1} = 'AVERAGE PERFOMANCE - SINGLE FINGER - TRAIN DATA';
sgtitleArray{2} = 'AVERAGE PERFOMANCE - SINGLE FINGER - TEST DATA';
sgtitleArray{3} = 'AVERAGE PERFOMANCE - MULTIPLE FINGER - TRAIN DATA';
sgtitleArray{4} = 'AVERAGE PERFOMANCE - MULTIPLE FINGER - TEST DATA';
for single_multiple = 0:1
    for train_test = 0:1
        plotArray = dataPlotSelector(avgResults, single_multiple, train_test);
        plotArray([1 4 7 10]) = []; % removing MSE
        groupNumber = size(plotArray{1},1);
        barXgroup = size(plotArray{1},2);
        groupwidth = min(0.8, barXgroup/(barXgroup + 1.5));
        figure(count)
        sgtitle(sgtitleArray{count});
        titleArray = [{'EMG RMSE'},{'EMG R2'},{'FORCE RMSE'},{'FORCE R2'}];
        labelArray = [{'mV'},{' '},{'N'},{' '}];
        for i = 1:4
            subplot(2,2,i)
            p1 = bar(plotArray{i});
            set(gca,'YGrid','on'), title(titleArray{i}),
            xlabel('Number of synergies'), ylabel(labelArray{i}),
            hold on
            for j = 1:barXgroup
                x = (1:groupNumber) - groupwidth/2 + (2*j-1) * groupwidth / (2*barXgroup);
                p2 = errorbar(x,plotArray{i}(:,j),plotArray{i+4}(:,j));
            end
            legend(p1,{'LFR','NNMF'},'NumColumns',2),
        end
        count = count +1;
    end
end

%% PLOT SINGLE SUBJECT PERFORMANCE GRAPHS
fprintf('##### PLOTTING PER SUBJECT RESULTS #####\n');
selSbj = [4, 33, 16, 17, 21];
extCount = 1;
for sbj = selSbj
    intCount = 1;
    sgtitleArray{1} = ['SBJ ',num2str(sbj),' PERFOMANCE - SINGLE FINGER - TRAIN DATA'];
    sgtitleArray{2} = ['SBJ ',num2str(sbj),' PERFOMANCE - SINGLE FINGER - TEST DATA'];
    sgtitleArray{3} = ['SBJ ',num2str(sbj),' PERFOMANCE - MULTIPLE FINGER - TRAIN DATA'];
    sgtitleArray{4} = ['SBJ ',num2str(sbj),' PERFOMANCE - MULTIPLE FINGER - TEST DATA'];
    for single_multiple = 0:1
        for train_test = 0:1
            plotArray = dataPlotSelector(simResults{sbj}, single_multiple, train_test);
            plotArray([1 4]) = []; % removing MSE
            groupNumber = size(plotArray{1},1);
            barXgroup = size(plotArray{1},2);
            groupwidth = min(0.8, barXgroup/(barXgroup + 1.5));
            figure(extCount)
            sgtitle(sgtitleArray{intCount});
            titleArray = [{'EMG RMSE'},{'EMG R2'},{'FORCE RMSE'},{'FORCE R2'}];
            labelArray = [{'mV'},{' '},{'N'},{' '}];
            for i = 1:4
                subplot(2,2,i)
                bar(plotArray{i});
                set(gca,'YGrid','on'), title(titleArray{i}),
                xlabel('Number of synergies'), ylabel(labelArray{i}),
                legend({'LFR','NNMF'},'NumColumns',2),
            end
            intCount = intCount +1;
            extCount = extCount +1;
        end
    end
end

%% PLOTTING RECONSTRUCTED SIGNALS AUTOENCODER
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

%% PLOTTING RECONSTRUCTED SIGNALS DOUBLE AUTOENCODER
fprintf('Plotting Signals...\n')
t1 = 1:1:size(EMG_Test,2);
for h = 1:10
    % Calculating XRecos and plotting EMG signals
    XRecos = DAEsim.trainedNet{h}(EMG_Test,'useParallel','no');
    t2 = 1:1:size(XRecos,2);
    figure(2*h)
    for i = 1:10
        subplot(2,5,i)
        plot(t1,EMG_Test(i,:),'b');
        hold on
        plot(t2,XRecos(i,:),'r');
    end
    sgtitle(['H' num2str(h) ': EMG'])
    
    % Plotting FORCE signals
    figure(2*h+1)
    for i = 1:6
        subplot(2,3,i)
        plot(t1,FORCE_Test(i,:),'b');
        hold on
        plot(t2,XRecos(i+10,:),'r');
    end
    sgtitle(['H' num2str(h) ': FORCE'])
end



