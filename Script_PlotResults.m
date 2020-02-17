% This script loads the dataset and the results of the simulations done with the different
% methods and plot graphs to illustrate the results.

clearvars
close all
clc

%% LOADING DATA
load Data_fullDataset
load Data_sfDataset
load Data_fullResults

selSbj = [4, 16, 17, 21, 33];

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
        for m = 1:4
            subplot(2,2,m)
            p1 = bar(plotArray{m});
            set(gca,'YGrid','on'), title(titleArray{m}),
            xlabel('Number of synergies'), ylabel(labelArray{m}),
            hold on
            for j = 1:barXgroup
                x = (1:groupNumber) - groupwidth/2 + (2*j-1) * groupwidth / (2*barXgroup);
                p2 = errorbar(x,plotArray{m}(:,j),plotArray{m+4}(:,j));
            end
            legend(p1,{'LFR','NNMF','AE','DAE'},'NumColumns',2),
        end
        count = count +1;
    end
end

%% PLOT SINGLE SUBJECT PERFORMANCE GRAPHS
fprintf('##### PLOTTING PER SUBJECT RESULTS #####\n');
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
            for m = 1:4
                subplot(2,2,m)
                bar(plotArray{m});
                set(gca,'YGrid','on'), title(titleArray{m}),
                xlabel('Number of synergies'), ylabel(labelArray{m}),
                legend({'LFR','NNMF','AE','DAE'},'NumColumns',2),
            end
            intCount = intCount +1;
            extCount = extCount +1;
        end
    end
end

%% PLOTTING RECONSTRUCTED SIGNALS
% 5 subjects
% 1:10 synergies
% 4 methods
% single and multiple fingers
% train and test dataset
% 4 forces (no EMG)
figNum = 1;
for sbj = selSbj            % subjects
    for s = 1:10            % synergies number
        for scen = 1:4      % scenaries
            for m = 0:4     % methods
                
                if (scen == 1) || (scen == 3)
                    dataSet = sfDataSet{sbj};
                else, dataSet = fullDataSet{sbj};
                end
                FORCE_Recos = methForce(dataSet, simResults{sbj}, m, s, scen);
                figure(figNum)   
                for i = 1:4
                    subplot(2,2,i)
                    plot(FORCE_Recos(i,:)),
                    xlabel('samples'), ylabel('N'),
                    hold on
                end
                hold on
                
            end
            sgTitleArray = ['SBJ:',num2str(sbj),' - S:',num2str(s),' - Scenary:',num2str(scen)];
            sgtitle(sgTitleArray)
            legend({'NinaPro','LFR','NNMF','AE','DAE'},'NumColumns',2)
            figNum = figNum +1;
        end
    end
end

