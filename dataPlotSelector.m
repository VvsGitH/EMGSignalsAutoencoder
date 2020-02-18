%% Generating a cell array containig the performance indexes corresponding to selected scenary
% selResults has the following structure:
% P cells, each one corresponds to a performance indexes, in this order:
%   MSE_emg; MSE_frc; RMSE_emg; RMSE_frc; R2_emg; R2_frc; [...stdIndexes] 
% Each cell contains a 10xM array. The M methods are in this order:
%   LFR, NNMF, AE, DAE

function selResults = dataPlotSelector(resStruct, single_multiple, train_test)

%% Exploring the structure fields for future indexing
fingChoice = single_multiple +1;
dataChoice = train_test +1;

methods = fieldnames(resStruct);
methodNumber = length(methods);
fing = fieldnames(resStruct.(methods{1})); % equal for all the methods
perfs = fieldnames(resStruct.(methods{1}).(fing{1}).Train); % equals for all the methods and scenaries
perfNumber = length(perfs); % 6 for simResults, 12 for avgResults

%% Generating selResults
selResults = cell(perfNumber,1);
for pI = 1: perfNumber       % PERFORMANCE INDEXES LOOP
    for mI = 1: methodNumber % METHODS LOOP
        % Finding the index of Train and Test fields:
        % the data field comprehends Train, Test and all the conversion
        % matrices and nets: H for LFR, W and Hc for NNMF, Hae and trNet 
        %                    for AE, trNet for DAE
        % Train and Test fields are always after the convMatrices and nets
        data = fieldnames(resStruct.(methods{mI}).(fing{fingChoice}));
        dataAdd = length(data) -2; % is the number convMatrices and nets presents in the dataField 
        % Generating selResults
        if any(pI == [1 2 3]) && mI == 1 
            selResults{pI}(:,mI) = zeros(10,1) + NaN;
        else
            selResults{pI}(:,mI) = zeros(10,1) + resStruct.(methods{mI}).(fing{fingChoice}).(data{dataChoice+dataAdd}).(perfs{pI});
            % The sum with zeros(10,1) is used to convert the scalar index of the LFR method to vectors.
        end
    end
end

end