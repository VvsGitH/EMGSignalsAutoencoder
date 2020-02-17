function FORCE_Recos = methForce(dataSet, resStruct, methNum, synNum, scenary)

TI = dataSet.testIndex;
VI = dataSet.validIndex;
END = length(dataSet.emg);
if methNum ~= 0
    % scenary legend:
    % 1 -> single finger, train data
    % 2 -> single finger, test data
    % 3 -> mult finger,   train data
    % 4 -> mult finger,   test data
    methods = fieldnames(resStruct);
    if (scenary == 1) || (scenary == 3)
        fing = 'SF';
    else, fing = 'MF';
    end
    openStruct = resStruct.(methods{methNum}).(fing);
end

switch methNum
    case 1
        %% LFR METHOD
        EMG_all = normalize(dataSet.emg,2,'range',[0 1]);
        [EMG_Train, ~, EMG_Test] = divideind(EMG_all, 1:TI-1, VI:END,  TI:VI-1);
        if (scenary == 1) || (scenary == 3)
            EMG = EMG_Train;
        else, EMG = EMG_Test;
        end
        H = openStruct.convMatrix;
        FORCE_Recos = H*EMG;
    case 2
        %% NNMF METHOD
        EMG_all = normalize(dataSet.emg,2,'range',[0 1]);
        [EMG_Train, ~, EMG_Test] = divideind(EMG_all, 1:TI-1, VI:END,  TI:VI-1);
        if (scenary == 1) || (scenary == 3)
            EMG = EMG_Train;
        else, EMG = EMG_Test;
        end
        W = openStruct.synMatrix{synNum};
        C = pinv(W)*EMG;
        Hc = openStruct.convMatrix{synNum};
        FORCE_Recos = Hc*C;
    case 3
        %% AE METHOD
        EMG_all = normalize(dataSet.emg,2,'range',[0 1]);
        [EMG_Train, ~, EMG_Test] = divideind(EMG_all, 1:TI-1, VI:END,  TI:VI-1);
        if (scenary == 1) || (scenary == 3)
            EMG = EMG_Train;
        else, EMG = EMG_Test;
        end
        trNet = openStruct.trainedNet{synNum};
        inputWeigths = cell2mat(trNet.IW);
        S = poslin(inputWeigths*EMG);
        Hae = openStruct.convMatrix{synNum};
        FORCE_Recos = Hae*S;
    case 4
        %% DAE METHOD
        [r_emg, r_frc] = netDAEoutputNorm(dataSet.emg, dataSet.force);
        EMG_all = normalize(dataSet.emg,2,'range',[0 r_emg]);
        [EMG_Train, ~, EMG_Test] = divideind(EMG_all, 1:TI-1, VI:END,  TI:VI-1);
        if (scenary == 1) || (scenary == 3)
            EMG = EMG_Train;
        else, EMG = EMG_Test;
        end
        trNet = openStruct.trainedNet{synNum};
        XRecos = trNet(EMG,'useParallel','no');
        FORCE_Recos = dataDenormalize(XRecos(11:14,:),0,r_frc,dataSet.maxForce);
    otherwise
        %% DEFAULT
        [FORCE_Train, ~, FORCE_Test] = divideind(dataSet.force, 1:TI-1, VI:END,  TI:VI-1);
        if (scenary == 1) || (scenary == 3)
            FORCE = FORCE_Train;
        else, FORCE = FORCE_Test;
        end
        FORCE_Recos = FORCE;
end

end