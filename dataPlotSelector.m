

function selResults = dataPlotSelector(resStruct, single_multiple, train_test)

%%
methods = fieldnames(resStruct);
methodNumber = length(methods);
fing = fieldnames(resStruct.(methods{1}));
data = fieldnames(resStruct.(methods{1}).(fing{1}));
dataNumber = length(data);
perfs = fieldnames(resStruct.(methods{1}).(fing{1}).(data{dataNumber}));
perfNumber = length(perfs);

fingChoice = single_multiple +dataNumber -1;
dataChoice = train_test +dataNumber -1;

%%
selResults = cell(perfNumber,1);
for pI = 1: perfNumber
    selResults{pI} = zeros(10,1);
    for mI = 1: methodNumber
        selResults{pI}(:,mI) = selResults{pI} + resStruct.(methods{mI}).(fing{fingChoice}).(data{dataChoice}).(perfs{pI});
    end
end

% selResults has the following structure:
% M cells, each one corresponds to a performance indexes, in thi order:
%   MSE_emg; MSE_frc; RMSE_emg; RMSE_frc; R2_emg; R2_frc; [...stdIndexes] 
% Each cell contains a 10xN array. The N methods are in this order:
%   LFR, NNMF, AE, DAE

end