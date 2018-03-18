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
               modelType = walkJump.ClassificationEnsemble; 
                [predictedWalkA,scoreWalkA] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               modelType = walkFall.ClassificationEnsemble; 
               [predictedWalkB,scoreWalkB] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               modelType = walkRun.ClassificationEnsemble; 
               [predictedWalkC,scoreWalkC] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               predictedWalk = [predictedWalkA(end),predictedWalkB(end),predictedWalkC(end)];
           %    display(predictedWalk);
               scoreWalk = [scoreWalk;[scoreWalkA(end),scoreWalkB(end),scoreWalkC(end)]];
               if ((strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkB,'Walk'))...
                       || (strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkC,'Walk'))...
                       || (strcmp(predictedWalkB,'Walk')&&strcmp(predictedWalkC,'Walk')))
                   Walk = char('Walk');
               else 
                   Walk = char('Abnormal');
               end
               
               
               modelType = standJump.ClassificationEnsemble; 
                [predictedStandA,scoreStandA] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               modelType = standFall.ClassificationEnsemble; 
               [predictedStandB,scoreStandB] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               modelType = standRun.ClassificationEnsemble; 
               [predictedStandC,scoreStandC] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               predictedStand = [predictedStandA(end),predictedStandB(end),predictedStandC(end)];
               scoreStand = [scoreStand;[scoreStandA(end),scoreStandB(end),scoreStandC(end)]];
           %    display(predictedStand);
               
               
               if ((strcmp(predictedStandA,'Stand')&&strcmp(predictedStandB,'Stand'))...
                       || (strcmp(predictedStandA,'Stand')&&strcmp(predictedStandC,'Stand'))...
                       || (strcmp(predictedStandB,'Stand')&&strcmp(predictedStandC,'Stand')))
                   Stand = char('Stand');
               else 
                   Stand = char('Abnormal');
               end
               
               
               modelType = waveJump.ClassificationEnsemble; 
                [predictedWaveA,scoreWaveA] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               modelType = waveFall.ClassificationEnsemble; 
               [predictedWaveB,scoreWaveB] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               modelType = waveRun.ClassificationKNN; 
               [predictedWaveC,scoreWaveC] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               predictedWave = [predictedWaveA(end),predictedWaveB(end),predictedWaveC(end)];
               scoreWave = [scoreWave;[scoreWaveA,scoreWaveB,scoreWaveC]];
            %   display(predictedWave);
               
               if ((strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveB,'Wave'))...
                       || (strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveC,'Wave'))...
                       || (strcmp(predictedWaveB,'Wave')&&strcmp(predictedWaveC,'Wave')))
                   Wave = char('Wave');
                   if strcmp(Stand,'Stand')
                       other = 'Stand/Wave';
                   else 
                       other = 'Wave';
                   end
               else 
                   Wave = char('Abnormal');
                   if strcmp(Stand,'Stand')
                       other = 'Stand';
                   else 
                       other = 'Abnormal';
                   end
               end
               
               myTable(row,:) = [Walk,predictedWalkA,scoreWalkA(end),predictedWalkB,scoreWalkB(end),predictedWalkC,scoreWalkC(end),other];
               
%                predictedWalk = char(predictedWalk(end));
%                allPlaces = [allPlaces,{predictedWalk}]; 
%                scoreTable = [scoreTable; scoreWalk];
               
               
%               [predictedNorm,scoreNorm] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60))
             % ref =  (person(i)-1)*60;
%              R1 = VelocityDiffJWC(1,[(person(i)-1)*60+1:(person(i)-1)*60+9]);
%              R2 = VelocityDiffJWC(1,[(person(i)-1)*60+43:(person(i)-1)*60+48]);
%              R3 = VelocityDiffJWC(1,[(person(i)-1)*60+55:(person(i)-1)*60+60]);
%              
%               [predictedNorm,scoreNorm] = predict(modelType, [R1,R2,R3])
%                    VelocityDiffJWC(1,[(person(i)-1)*60+1:(person(i)-1)*60+9]),...
%                    VelocityDiffJWC(1,[(person(i)-1)*60+43:(person(i)-1)*60+48]),...
%                    VelocityDiffJWC(1,[(person(i)-1)*60+55:(person(i)-1)*60+60]))
               
              % display(predictedNorm(end));
%                predictedWalk = char(predictedWalk);
%                predictedStand = char(predictedStand);
%                predictedWave = char(predictedWave);
               allPlaces = [allPlaces,{Walk,Stand,Wave}]; 
               scoreTable = [scoreTable; [scoreWalk(end),scoreStand(end),scoreWave(end)]];
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