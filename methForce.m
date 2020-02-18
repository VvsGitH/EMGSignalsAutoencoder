%% Estimates the FORCE signal with a method specific algorithm
% dataSet: processed NinaPro data -> fullDataSet{.} or sfDataSet{.}
% resStruct: structer containing performance indexes -> simResults{.}
% methNum: 1 -> LFR     2 -> NNMF    3 -> AE     4 -> DAE    0 -> NinaPro
% synNum: synergies number
% scenNum: scenary number
%           1 -> single finger dataset, testing with train data
%           2 -> single finger dataset, testing with test data
%           3 -> full dataset, testing with train data
%           4 -> full dataset, testing with test data

function FORCE_Recos = methForce(dataSet, resStruct, methNum, synNum, scenNum)

% Set Up
TI = dataSet.testIndex;
VI = dataSet.validIndex;
END = length(dataSet.emg);
if methNum ~= 0 % CHECK method different from NinaPro
    methods = fieldnames(resStruct);
    % Selecting struct field based on scenary
    if (scenNum == 1) || (scenNum == 3)
        fing = 'SF';   % single finger dataset
    else, fing = 'MF'; % full dataset
    end
    % Generating a structure tha contains only performance indexes
    openStruct = resStruct.(methods{methNum}).(fing);
end

switch methNum
    case 1
        %% LFR METHOD
        % Normalizing and dividing EMG dataset
        EMG_all = normalize(dataSet.emg,2,'range',[0 1]);
        [EMG_Train, ~, EMG_Test] = divideind(EMG_all, 1:TI-1, VI:END,  TI:VI-1);
        % Selecting subset based on scenary
        if (scenNum == 1) || (scenNum == 3)
            EMG = EMG_Train;
        else, EMG = EMG_Test;
        end
        % Recostructing force with H model
        H = openStruct.convMatrix;
        FORCE_Recos = H*EMG;
    case 2
        %% NNMF METHOD
        % Normalizing and dividing EMG dataset
        EMG_all = normalize(dataSet.emg,2,'range',[0 1]);
        [EMG_Train, ~, EMG_Test] = divideind(EMG_all, 1:TI-1, VI:END,  TI:VI-1);
        % Selecting subset based on scenary
        if (scenNum == 1) || (scenNum == 3)
            EMG = EMG_Train;
        else, EMG = EMG_Test;
        end
        % [W, C] = nnmf(.)
        W = openStruct.synMatrix{synNum};
        C = pinv(W)*EMG;
        % Recostructinf force with Hc model
        Hc = openStruct.convMatrix{synNum};
        FORCE_Recos = Hc*C;
    case 3
        %% AE METHOD
        % Normalizing and dividing EMG dataset
        EMG_all = normalize(dataSet.emg,2,'range',[0 1]);
        [EMG_Train, ~, EMG_Test] = divideind(EMG_all, 1:TI-1, VI:END,  TI:VI-1);
        % Selecting subset based on scenary
        if (scenNum == 1) || (scenNum == 3)
            EMG = EMG_Train;
        else, EMG = EMG_Test;
        end
        % Calculating synergies vector from net weigths
        trNet = openStruct.trainedNet{synNum};
        inputWeigths = cell2mat(trNet.IW);
        S = poslin(inputWeigths*EMG);
        % Recostructinf force with Hae model
        Hae = openStruct.convMatrix{synNum};
        FORCE_Recos = Hae*S;
    case 4
        %% DAE METHOD
        % Normalizing and dividing EMG dataset
        [r_emg, r_frc] = netDAEoutputNorm(dataSet.emg, dataSet.force);
        EMG_all = normalize(dataSet.emg,2,'range',[0 r_emg]);
        [EMG_Train, ~, EMG_Test] = divideind(EMG_all, 1:TI-1, VI:END,  TI:VI-1);
        % Selecting subset based on scenary
        if (scenNum == 1) || (scenNum == 3)
            EMG = EMG_Train;
        else, EMG = EMG_Test;
        end
        % Simulating trained DAE
        trNet = openStruct.trainedNet{synNum};
        XRecos = trNet(EMG,'useParallel','no');
        % Denormalize force
        FORCE_Recos = dataDenormalize(XRecos(11:14,:),0,r_frc,dataSet.maxForce);
    otherwise
        %% DEFAULT NinaPro FORCES
        % Dividing FORCE dataset, no normalization required
        [FORCE_Train, ~, FORCE_Test] = divideind(dataSet.force, 1:TI-1, VI:END,  TI:VI-1);
        % Selecting subset based on scenary
        if (scenNum == 1) || (scenNum == 3)
            FORCE = FORCE_Train;
        else, FORCE = FORCE_Test;
        end
        % Original forces
        FORCE_Recos = FORCE;
end

end