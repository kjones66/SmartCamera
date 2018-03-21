
function [data] = predictData(var)
        load('walkRun.mat')
        load('walkJump.mat')
        load('walkFall.mat')
        load('standRun.mat')
        load('standJump.mat')
        load('standFall.mat')
        load('waveRun.mat')
        load('waveJump.mat')
        load('waveFall.mat')   
        data = [];
        
for i = 1:height(var)
        modelType = standJump.ClassificationEnsemble;
        [predictedStandA,scoreStandA] = predict(modelType, var(i,:));
        modelType = standFall.ClassificationEnsemble;
        [predictedStandB,scoreStandB] = predict(modelType, var(i,:));
        modelType = standRun.ClassificationEnsemble;
        [predictedStandC,scoreStandC] = predict(modelType, var(i,:));
        predictedStand = [predictedStandA(end),predictedStandB(end),predictedStandC(end)];
        DataLine = [var(i,:), predictedStand]
        data = [data; DataLine];
    end
end