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
            [predictedStandA,scoreStandA] = predict(modelType, var(i,1:60));
            modelType = standFall.ClassificationEnsemble;
            [predictedStandB,scoreStandB] = predict(modelType, var(i,1:60));
            modelType = standRun.ClassificationEnsemble;
            [predictedStandC,scoreStandC] = predict(modelType, var(i,1:60));
            predictedStand = [predictedStandA(end),predictedStandB(end),predictedStandC(end)];
%             DataLine = [var(i,:), predictedStand];
%             data = [data; DataLine];
    %end
    
   % for i = 1:height(var)
        modelType = walkJump.ClassificationEnsemble;
        [predictedWalkA,scoreWalkA] = predict(modelType, var(i,1:60));
        modelType = walkFall.ClassificationEnsemble;
        [predictedWalkB,scoreWalkB] = predict(modelType, var(i,1:60));
        modelType = walkRun.ClassificationEnsemble;
        [predictedWalkC,scoreWalkC] = predict(modelType, var(i,1:60));
       predictedWalk = [predictedWalkA(end),predictedWalkB(end),predictedWalkC(end)];
%         predictions = [predictedWalkA(end),scoreWalkA(end),predictedWalkB(end),scoreWalkB(end),predictedWalkC(end),scoreWalkC(end)];
%         DataLine = [var(i,:), predictions];
%         data = [data; DataLine];
    %end
    
    % for i = 1:height(var)
        modelType = waveJump.ClassificationEnsemble;
        [predictedWaveA,scoreWaveA] = predict(modelType, var(i,1:60));
        modelType = waveFall.ClassificationEnsemble;
        [predictedWaveB,scoreWaveB] = predict(modelType, var(i,1:60));
        modelType = waveRun.ClassificationKNN;
        [predictedWaveC,scoreWaveC] = predict(modelType, var(i,1:60));
        predictedWave = [predictedWaveA(end),predictedWaveB(end),predictedWaveC(end)];
%         predictions = [predictedWaveA(end),scoreWaveA(end),predictedWaveB(end),scoreWaveB(end),predictedWaveC(end),scoreWaveC(end)];
%         DataLine = [var(i,:), predictions];
%         data = [data; DataLine];
         data = [data; var(i,61:62), predictedStand,predictedWalk,predictedWave];
    end
    %data = cell2table(data);
    
end