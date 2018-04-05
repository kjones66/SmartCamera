clc; clear; close all;
%load('AbVwalk_spineankle.mat')
load('walkRun.mat')
load('walkJump.mat')
load('walkFall.mat')
load('standRun.mat')
load('standJump.mat')
load('standFall.mat')
load('waveRun.mat')
load('waveJump.mat')
load('waveFall.mat')
load('stage2Stand.mat')


% Initialize Camera
[vid, depthVid, himg, src] = InitializeKinect();
firstLoop = 1;
oldData = 0;
oldDataJWC = 0;
scoreTable = [];
scoreWalk  = [];
scoreStand = [];
scoreWave = [];
myTable = cell(300,8);
row = 0;

% Run Kinect
while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
        row = row +1;
        d = depthMetaData;
        % Prep to log data in one line
        numberOfPeople = sum(depthMetaData.IsSkeletonTracked);
        person = find(d.IsSkeletonTracked == 1);
        [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);
        %log data
       % [VelocityDiff,oldData] = logAllData(d,oldData,JDI,JII,JTS,JWC,PDI,PII,PWC,SD,firstLoop)
        [VelocityDiffJWC, oldData, oldDataJWC] = logAllData(d,numberOfPeople,person,oldData,oldDataJWC,JDI,JII,JTS,JWC,PDI,PII,PWC,SD,firstLoop);
        % Prep data for plotting
       skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
       %modelType = AbVwalk_spineankle.ClassificationEnsemble; 
      %modelType = AbVwalk.ClassificationEnsemble;  
      allPlaces = [];
       if (firstLoop ==0)
           for i = 1:numberOfPeople
               thisJWC = VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60)
               modelType = walkJump.ClassificationEnsemble; 
                [predictedWalkA,scoreWalkA] = predict(modelType, thisJWC);
               modelType = walkFall.ClassificationEnsemble; 
               [predictedWalkB,scoreWalkB] = predict(modelType, thisJWC);
               modelType = walkRun.ClassificationEnsemble; 
               [predictedWalkC,scoreWalkC] = predict(modelType, thisJWC);
               predictedWalk = [predictedWalkA(end),predictedWalkB(end),predictedWalkC(end)];
               
               
           %    display(predictedWalk);
               scoreWalk = [scoreWalk;[scoreWalkA(end),scoreWalkB(end),scoreWalkC(end)]];
               
               
               modelType = standJump.ClassificationEnsemble; 
                [predictedStandA,scoreStandA] = predict(modelType, thisJWC);
               modelType = standFall.ClassificationEnsemble; 
               [predictedStandB,scoreStandB] = predict(modelType, thisJWC);
               modelType = standRun.ClassificationEnsemble; 
               [predictedStandC,scoreStandC] = predict(modelType, thisJWC);
               predictedStand = [predictedStandA(end),predictedStandB(end),predictedStandC(end)];
               scoreStand = [scoreStand;[scoreStandA(end),scoreStandB(end),scoreStandC(end)]];
           %    display(predictedStand);
               
%                A = [VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60),predictedWalk];
%                stage2S_Data = array2table(A);
                now = person(i);
               stage2S_Data = label4Stage2(thisJWC, predictedStand)
               modelType = stage2Stand.ClassificationSVM; 
               [predictedStage2Stand,scoreStage2Stand] = predict(modelType, stage2S_Data);

               
               
%                modelType = waveJump.ClassificationEnsemble; 
%                 [predictedWaveA,scoreWaveA] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
%                modelType = waveFall.ClassificationEnsemble; 
%                [predictedWaveB,scoreWaveB] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
%                modelType = waveRun.ClassificationKNN; 
%                [predictedWaveC,scoreWaveC] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
%                predictedWave = [predictedWaveA(end),predictedWaveB(end),predictedWaveC(end)];
%                scoreWave = [scoreWave;[scoreWaveA,scoreWaveB,scoreWaveC]];
%             %   display(predictedWave);
%               
%                
%                myTable(row,:) = [Wave,predictedWaveA,scoreWaveA(end),predictedWaveB,scoreWaveB(end),predictedWaveC,scoreWaveC(end),other];
              
               allPlaces = {'Stand vs Abnormal: ' char(predictedStage2Stand)};%'Walk vs Abnormal: ' Walk, 'Wave vs Abnormal: ' Wave}; 
               
               scoreTable = [scoreTable; [scoreWalk(end),scoreStand(end)]];%,scoreWave(end)]];
           end
           allLabels = [];
           lineOptions = [{':o'}, {':go'},{':ko'}, {':ro'}, {':po'}, {':yo'}];
           hold on;
           for i = 1:numberOfPeople
               currentSym = char(lineOptions(i));
               plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),currentSym);
           end
           hold off;
           allPlaces = char(allPlaces);
           lgd = legend(allPlaces);
           lgd.FontSize = 20;
%            set(gcf,'units','normalized','outerposition',[0 0 1 1])
       end
       firstLoop = 0;
     %  scoreTable
    end
end