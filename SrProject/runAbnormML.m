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
load('st23SVM.mat')


% Initialize Camera
global vid
global depthVid, 
global himg, 
global src
[vid, depthVid, himg, src] = InitializeKinect();

global firstLoop
global oldData 
global oldDataJWC 
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
%                print('i :')
               display(i)
               modelType = walkJump.ClassificationEnsemble; 
               [predictedWalkA,scoreWalkA] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               modelType = walkFall.ClassificationEnsemble; 
               [predictedWalkB,scoreWalkB] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               modelType = walkRun.ClassificationEnsemble; 
               [predictedWalkC,scoreWalkC] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               predictedWalk = [predictedWalkA(end),predictedWalkB(end),predictedWalkC(end)];
           %    display(predictedWalk);
               scoreWalk = [scoreWalk;[scoreWalkA(end),scoreWalkB(end),scoreWalkC(end)]];
%                if ((strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkB,'Walk'))...
%                        || (strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkC,'Walk'))...
%                        || (strcmp(predictedWalkB,'Walk')&&strcmp(predictedWalkC,'Walk')))
               if    (strcmp(predictedWalkA,'Walk')...
                       || strcmp(predictedWalkC,'Walk')...
                       || strcmp(predictedWalkB,'Walk'))
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
                   if strcmp(Walk,'Walk')
                       other = 'Walk/Stand';
                   else 
                       other = 'Stand';
                   end
               else 
                   Stand = char('Abnormal');
                   if strcmp(Walk,'Walk')
                       other = 'Walk';
                   else 
                       other = 'Abnormal';
                   end
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
%                    if strcmp(Walk,'Walk')
%                        other = 'Walk/Wave';
%                    else 
%                        other = 'Wave';
%                    end
               else 
                   Wave = char('Abnormal');
%                    if strcmp(Walk,'Walk')
%                        other = 'Walk';
%                    else 
%                        other = 'Abnormal';
%                    end
               end
               
               C = [0,0,predictedStand,predictedWalk, predictedWave];
               C = cell2table(C);
               modelType = st23SVM.ClassificationSVM; 
               [predict,score] = predict(modelType,C(1,3:11));

              % clear Var;
               
              % myTable(row,:) = [Wave,predictedWaveA,scoreWaveA(end),predictedWaveB,scoreWaveB(end),predictedWaveC,scoreWaveC(end),other];
               
%                predictedWalk = char(predictedWalk(end));
%                allPlaces = [allPlaces,{predictedWalk}]; 
%                scoreTable = [scoreTable; scoreWalk];
               
               
              % display(predictedNorm(end));
%                predictedWalk = char(predictedWalk);
%                predictedStand = char(predictedStand);
%                predictedWave = char(predictedWave);
               %allPlaces = [allPlaces,{Walk,Stand,Wave}]; 
               %allPlaces = {'Walk vs Abnormal: ' Walk, 'Stand vs Abnormal: ' Stand,'Wave vs Abnormal: ' Wave}; 
               if (strcmp(Walk,'Abnormal')&&strcmp(Stand,'Abnormal')&&strcmp(Wave,'Abnormal'))
                   allPlaces = {'Abnormal'}; 
               else
                   allPlaces = {'Normal'}; 
               end
               allPlaces = {char(predict)};
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
       clear variables
     %  scoreTable
    end
end
