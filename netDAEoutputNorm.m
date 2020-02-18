%% Determination of the normalization values for EMG and FORCE signals for the DAE
% In order to make the DAE optimize both EMG and FORCE signals equally, the
% signals must be normalized in a different way, since EMG comes with 10
% channels and FORCE comes with 4 channels.

function [r_emg, r_frc] = netDAEoutputNorm(EMG, FORCE)

% TOTAL OUTPUT SIZE
outSize = size(EMG,1)+size(FORCE,1);    % 14
% EMG RELATIVE WEIGTH IN THE OUTPUT
emgRelSize = size(EMG,1)/outSize;       % 10/14
% FORCE RELATIVE WEIGTH IN THE OUTPUT
forceRelSize = size(FORCE,1)/outSize;   % 4/14
% UNIFORMING THE WEIGTH TO 50%
r_emg = 0.5/emgRelSize;
r_frc = 0.5/forceRelSize;

end