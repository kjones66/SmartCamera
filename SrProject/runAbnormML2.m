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
%load('st23SVM.mat')
load('st23predictnoConfidence.mat')


% Initialize Camera
[vid, depthVid, himg, src] = InitializeKinect();
% global firstLoop = 1;
% global oldData = 0;
% global oldDataJWC = 0;
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
       allPlaces = [];
       if (firstLoop ==0)
           for i = 1:numberOfPeople
%                print('i :')
               display(i)
               thisJWC = VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60);
               modelType = walkJump.ClassificationEnsemble; 
               [predictedWalkA,scoreWalkA] = predict(modelType, thisJWC);
                display('Got here')
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
               
                                    
               modelType = waveJump.ClassificationEnsemble; 
                [predictedWaveA,scoreWaveA] = predict(modelType, thisJWC);
               modelType = waveFall.ClassificationEnsemble; 
               [predictedWaveB,scoreWaveB] = predict(modelType, thisJWC);
               modelType = waveRun.ClassificationKNN; 
               [predictedWaveC,scoreWaveC] = predict(modelType, thisJWC);
               predictedWave = [predictedWaveA(end),predictedWaveB(end),predictedWaveC(end)];
               scoreWave = [scoreWave;[scoreWaveA,scoreWaveB,scoreWaveC]];
            %   display(predictedWave);
               
               
               if(((strcmp(predictedStandA,'Stand')&&strcmp(predictedStandB,'Stand'))...
                       || (strcmp(predictedStandA,'Stand')&&strcmp(predictedStandC,'Stand'))...
                       || (strcmp(predictedStandB,'Stand')&&strcmp(predictedStandC,'Stand')))...
                       ||((strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveB,'Wave'))...
                       || (strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveC,'Wave'))...
                       || (strcmp(predictedWaveB,'Wave')&&strcmp(predictedWaveC,'Wave'))))
                   state = 'Stand/Wave';
                   stateKey = 1;
               elseif ((strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkB,'Walk'))...
                       ||(strcmp(predictedWalkB,'Walk')&&strcmp(predictedWalkC,'Walk'))...
                       ||(strcmp(predictedWalkC,'Walk')&&strcmp(predictedWalkA,'Walk')))
                   state = 'Walk';
                   stateKey = 2;
               else 
                   state = 'Abnormal';
                   stateKey = 3;
               end
               
               fid = fopen('test.csv', 'w') ;
               filename = sprintf('JWC_hmm_labels.csv');
               dataLine = [thisJWC,stateKey];
               dlmwrite(filename,dataLine,'-append','delimiter',',')
               fclose(fid)
               
               
%                Var = [0,0,predictedStand,predictedWalk, predictedWave];
%                C = cell2table(Var);
%                thisModel = st23predictnoConfidence.ClassificationEnsemble; 
%                [prediction,scoreOut] = predict(thisModel,C(1,3:11));

              
%                if (strcmp(Walk,'Abnormal')&&strcmp(Stand,'Abnormal')&&strcmp(Wave,'Abnormal'))
%                    allPlaces = {'Abnormal'}; 
%                else
%                    allPlaces = {'Normal'}; 
%                end
               allPlaces = {char(state)};
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
