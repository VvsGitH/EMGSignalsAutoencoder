function [r_emg, r_frc] = netDAEoutputNorm(EMG, FORCE)

% DAE: different normalization for output balance
outSize = size(EMG,1)+size(FORCE,1);    % 14
emgRelSize = size(EMG,1)/outSize;       % 10/14
forceRelSize = size(FORCE,1)/outSize;   % 4/14
r_emg = 0.5/emgRelSize;
r_frc = 0.5/forceRelSize;

end