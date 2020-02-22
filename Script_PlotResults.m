% This script loads the dataset and the results of the simulations done with the different
% methods and plot graphs to illustrate the results.

clearvars
close all
clc

%% LOADING DATA
load Data_fullDataset
load Data_sfDataset
load Data_fullResults

selSbj = [4, 16, 17, 21, 33]; % best subjects

%% PLOT MEAN PERFORMANCE GRAPHS
% bar graph with 10 groups of 4 bars:
% each group corresponds to a synergy number
% each bars corresponds to a different method
close all
fprintf('##### PLOTTING MEAN RESULTS #####\n');
% index for counting the figures
count = 1; 
% graphs titles and labels in cell arrays
sgtitleArray{1} = 'AVERAGE PERFOMANCE - SINGLE FINGER - TRAIN DATA';
sgtitleArray{2} = 'AVERAGE PERFOMANCE - SINGLE FINGER - TEST DATA';
sgtitleArray{3} = 'AVERAGE PERFOMANCE - MULTIPLE FINGER - TRAIN DATA';
sgtitleArray{4} = 'AVERAGE PERFOMANCE - MULTIPLE FINGER - TEST DATA';
titleArray = [{'EMG RMSE'},{'EMG R2'},{'FORCE RMSE'},{'FORCE R2'}];
labelArray = [{'V'},{' '},{'N'},{' '}];
% double loop for the four scenaries
for single_multiple = 0:1 % single fingers movements or full movements
    for train_test = 0:1  % test with train data or test with test data
        % array containing al the selected scenary performance indexes
        plotArray = dataPlotSelector(avgResults, single_multiple, train_test);
        plotArray([1 4 7 10]) = []; % removing MSE
        % determining the dimension of the 10 grops of 4 bars
        groupNumber = size(plotArray{1},1);
        barXgroup = size(plotArray{1},2);
        groupwidth = min(0.8, barXgroup/(barXgroup + 1.5));
        % FIGURE START
        figure(count)
        sgtitle(sgtitleArray{count});
        for m = 1:4
            subplot(2,2,m)
            bar(plotArray{m}); % bar graph
            set(gca,'YGrid','on'), title(titleArray{m}),
            xlabel('Number of synergies'), ylabel(labelArray{m}),
            hold on
            % generating the std graphs and moving on top of the 
            %   corresponding bars, in the middle
            for j = 1:barXgroup
                x = (1:groupNumber) - groupwidth/2 + (2*j-1) * groupwidth / (2*barXgroup);
                errorbar(x,plotArray{m}(:,j),plotArray{m+4}(:,j));
            end
        end
        % generating only one legend and moving it in the center of the figure
        legend({'LFR','NNMF','AE','DAE','LFR std','NNMF std','AE std','DAE std'}, ...
            'NumColumns',4,'Position',[0.465 0.456 0.1 0.1],'Units','Normalized');
        % set the figure full screen and saving in jpeg
        set(gcf, 'WindowState', 'maximized');
        saveas(gcf,['./Figures/' sgtitleArray{count}],'jpeg')
        % FIGURE SAVED
        count = count +1;
    end
end

%% PLOT SINGLE SUBJECT PERFORMANCE GRAPHS
% per subjetc bar graph with 10 groups of 4 bars 
% each group corresponds to a synergy number
% each bars corresponds to a different method
close all
fprintf('##### PLOTTING PER SUBJECT RESULTS #####\n');
% index for counting the figures
extCount = 1;
for sbj = selSbj % SUBJECT LOOP
    % index for counting the scenary
    intCount = 1;
    % cell arrays with sgtitles, titles and labels
    sgtitleArray{1} = ['SBJ ',num2str(sbj),' PERFOMANCE - SINGLE FINGER - TRAIN DATA'];
    sgtitleArray{2} = ['SBJ ',num2str(sbj),' PERFOMANCE - SINGLE FINGER - TEST DATA'];
    sgtitleArray{3} = ['SBJ ',num2str(sbj),' PERFOMANCE - MULTIPLE FINGER - TRAIN DATA'];
    sgtitleArray{4} = ['SBJ ',num2str(sbj),' PERFOMANCE - MULTIPLE FINGER - TEST DATA'];
    titleArray = [{'EMG RMSE'},{'EMG R2'},{'FORCE RMSE'},{'FORCE R2'}];
    labelArray = [{'V'},{' '},{'N'},{' '}];
    for single_multiple = 0:1 % DATASET CHOICE
        for train_test = 0:1  % TEST DATA CHOICE
            % array containing al the selected scenary performance indexes
            plotArray = dataPlotSelector(simResults{sbj}, single_multiple, train_test);
            plotArray([1 4]) = []; % removing MSE
            % determining the dimension of the 10 grops of 4 bars
            groupNumber = size(plotArray{1},1);
            barXgroup = size(plotArray{1},2);
            groupwidth = min(0.8, barXgroup/(barXgroup + 1.5));
            % FIGURE START
            figure(extCount)
            sgtitle(sgtitleArray{intCount});
            for m = 1:4
                subplot(2,2,m)
                bar(plotArray{m});
                set(gca,'YGrid','on'), title(titleArray{m}),
                xlabel('Number of synergies'), ylabel(labelArray{m}),
            end
            % generating only one legend and moving it in the center of the figure
            legend({'LFR','NNMF','AE','DAE'},'NumColumns',2,'Position',[0.465 0.456 0.1 0.1],'Units','Normalized');
            % set the figure to full screen and save it
            set(gcf, 'WindowState', 'maximized');
            saveas(gcf,['./Figures/' sgtitleArray{intCount}],'jpeg')
            % FIGURE SAVED
            intCount = intCount +1;
            extCount = extCount +1;
        end
    end
end

%% PLOTTING RECONSTRUCTED SIGNALS
% Per subject, per synergies number plots with overlapping reconstructed
% force signals.
% There are 200 total combinations of plots:
%   5 subjects
%   1:10 synergies
%   4 scenaries 
% Each one of this graphs comprehends 4 subplots (one for each finger sensor)
% Each one of the subplots shows the a up to five overlapping signals:
%      * the original force
%      * the 4 reconstructed forces corresponding to the 4 methods
close all
fprintf('##### PLOTTING RECONSTRUCTED SIGNALS #####\n');
% signals colors and subplot titles in cell arrays.
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
for sbj = selSbj                % SUBJECTS LOOP
    for s = 1:10                % SYNERGIES NUMBER LOOP
        for scen = 4            % SCENARY LOOP: all movements and test data
            for m = [0 1 4]     % METHODS LOOP: NinaPro, LFR, DAE
                % choosing the dataset based on the scenary
                if (scen == 1) || (scen == 2)
                    dataSet = sfDataSet{sbj};
                else, dataSet = fullDataSet{sbj};
                end
                % calculating the recostructed force
                FORCE_Recos = methForce(dataSet, simResults{sbj}, m, s, scen);
                % FIGURE START
                figure(figNum)   
                sgTitleArray = ['SBJ ',num2str(sbj),' RECOS FORCES - S ',num2str(s),' - SCEN ',num2str(scen)];
                sgtitle(sgTitleArray)
                for i = 1:4     % SENSORS LOOP
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
            % set the figure to full screen and save it
            set(gcf, 'WindowState', 'maximized');
            saveas(gcf,['./Figures/' sgTitleArray],'jpeg')
            % FIGURE SAVED
            figNum = figNum +1;
        end
    end
end

