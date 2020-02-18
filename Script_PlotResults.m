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
close all
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
        labelArray = [{'V'},{' '},{'N'},{' '}];
        for m = 1:4
            subplot(2,2,m)
            bar(plotArray{m});
            set(gca,'YGrid','on'), title(titleArray{m}),
            xlabel('Number of synergies'), ylabel(labelArray{m}),
            hold on
            for j = 1:barXgroup
                x = (1:groupNumber) - groupwidth/2 + (2*j-1) * groupwidth / (2*barXgroup);
                errorbar(x,plotArray{m}(:,j),plotArray{m+4}(:,j));
            end
        end
        legend({'LFR','NNMF','AE','DAE','LFR std','NNMF std','AE std','DAE std'}, ...
            'NumColumns',4,'Position',[0.465 0.456 0.1 0.1],'Units','Normalized');
        set(gcf, 'WindowState', 'maximized');
        saveas(gcf,['./Figures/' sgtitleArray{count}],'jpeg')
        count = count +1;
    end
end

%% PLOT SINGLE SUBJECT PERFORMANCE GRAPHS
close all
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
            labelArray = [{'V'},{' '},{'N'},{' '}];
            for m = 1:4
                subplot(2,2,m)
                bar(plotArray{m});
                set(gca,'YGrid','on'), title(titleArray{m}),
                xlabel('Number of synergies'), ylabel(labelArray{m}),
            end
            legend({'LFR','NNMF','AE','DAE'},'NumColumns',2,'Position',[0.465 0.456 0.1 0.1],'Units','Normalized');
            set(gcf, 'WindowState', 'maximized');
            saveas(gcf,['./Figures/' sgtitleArray{intCount}],'jpeg')
            intCount = intCount +1;
            extCount = extCount +1;
        end
    end
end

%% PLOTTING RECONSTRUCTED SIGNALS
close all
fprintf('##### PLOTTING RECONSTRUCTED SIGNALS #####\n');
% 5 subjects
% 1:10 synergies
% 4 methods
% single and multiple fingers
% train and test dataset
% 4 forces (no EMG)
colorArray{1} = [0.4660 0.6740 0.1880]; % NinaPro
colorArray{2} = [0 0.4470 0.7410];      % LFR
colorArray{3} = [0.8500 0.3250 0.0980]; % NNMF
colorArray{4} = [0.9290 0.6940 0.1250]; % AE
colorArray{5} = [0.4940 0.1840 0.5560]; % DAE
titleArray{1} = 'Index Finger Forces'; 
titleArray{2} = 'Middle Finger Forces';
titleArray{3} = 'Ring Finger Forces';
titleArray{4} = 'Little Finger Forces';

figNum = 1;
for sbj = 33                    % best subject
    for s = 1:10                % synergies number
        for scen = 2            % scenary: single finger - test data
            for m = [0 1 4]     % methods: NinaPro, LFR, DAE
                
                if (scen == 1) || (scen == 3)
                    dataSet = sfDataSet{sbj};
                else, dataSet = fullDataSet{sbj};
                end
                FORCE_Recos = methForce(dataSet, simResults{sbj}, m, s, scen);
                figure(figNum)   
                sgTitleArray = ['SBJ ',num2str(sbj),' RECOS FORCES - S ',num2str(s),' - SCEN ',num2str(scen)];
                sgtitle(sgTitleArray)
                for i = 1:4 % sensors
                    subplot(2,2,i)
                    plot(FORCE_Recos(i,:),'Color',colorArray{m+1},'LineWidth',1.1),
                    axis tight
                    xlabel('samples'), ylabel('N'),
                    grid on, title(titleArray{i}),
                    hold on
                end
                hold on
                
            end
            legend({'NinaPro','LFR','DAE'},'NumColumns',3,'Position',[0.465 0.456 0.1 0.1],'Units','Normalized');
            set(gcf, 'WindowState', 'maximized');
            saveas(gcf,['./Figures/' sgTitleArray],'jpeg')
            figNum = figNum +1;
        end
    end
end

