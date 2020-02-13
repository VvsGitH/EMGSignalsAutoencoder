h = 1:10;

fprintf('##### PLOTTING AE RESULTS #####\n');
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

fprintf('##### PLOTTING DAE RESULTS #####\n');
figure(2);
    % MSE, RMSE and R2 barplots for EMG
    subplot(2,3,1)
    bar(h,simResults.DAE.avgMSE_emg), title('DAE EMG MSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgMSE_emg,simResults.DAE.stdMSE_emg,'ko');
    subplot(2,3,2)
    bar(h,simResults.DAE.avgRMSE_emg), title('DAE EMG RMSE [mV]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgRMSE_emg,simResults.DAE.stdRMSE_emg,'ko');
    subplot(2,3,3)
    bar(h,simResults.DAE.avgR2_emg), title('DAE EMG R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgR2_emg,simResults.DAE.stdR2_emg,'ko');
    
    % MSE, RMSE and R2 barplots for FORCE
    subplot(2,3,4)
    bar(h,simResults.DAE.avgMSE_frc), title('DAE FORCE MSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgMSE_frc,simResults.DAE.stdMSE_frc,'ko');
    subplot(2,3,5)
    bar(h,simResults.DAE.avgRMSE_frc), title('DAE FORCE RMSE [N]'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');
    hold on
    errorbar(simResults.DAE.avgRMSE_frc,simResults.DAE.stdRMSE_frc,'ko');
    subplot(2,3,6)
    bar(h,simResults.DAE.avgR2_frc), title('DAE FORCE R2'),
    set(gca,'YGrid','on'),
    xlabel('Number of synergies');  
    hold on
    errorbar(simResults.DAE.avgR2_frc,simResults.DAE.stdR2_frc,'ko');