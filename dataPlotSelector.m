

function selResults = dataPlotSelector(resStruct, single_multiple, train_test)

%%
fingChoice = single_multiple +1;
dataChoice = train_test +1;

methods = fieldnames(resStruct);
methodNumber = length(methods);
fing = fieldnames(resStruct.(methods{1}));
perfs = fieldnames(resStruct.(methods{1}).(fing{1}).Train);
perfNumber = length(perfs);

%%
selResults = cell(perfNumber,1);
for pI = 1: perfNumber
    for mI = 1: methodNumber
        data = fieldnames(resStruct.(methods{mI}).(fing{fingChoice}));
        dataAdd = length(data) -2;
        selResults{pI}(:,mI) = zeros(10,1) + resStruct.(methods{mI}).(fing{fingChoice}).(data{dataChoice+dataAdd}).(perfs{pI});
    end
end

% selResults has the following structure:
% M cells, each one corresponds to a performance indexes, in thi order:
%   MSE_emg; MSE_frc; RMSE_emg; RMSE_frc; R2_emg; R2_frc; [...stdIndexes] 
% Each cell contains a 10xN array. The N methods are in this order:
%   LFR, NNMF, AE, DAE

end