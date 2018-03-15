clc; clear; close all;
load('fjsModel3.mat')

% Initialize Camera
[vid, depthVid, himg, src] = InitializeKinect();
firstLoop = 1;
oldData = 0;
oldDataJWC = 0;
scoreTable = [];

% Run Kinect
while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
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
       modelType = fjsModel3.ClassificationSVM;
      %modelType = AbVwalk.ClassificationEnsemble;  
      allPlaces = [];
       if (firstLoop ==0)
           for i = 1:numberOfPeople
%                [predictedNorm,scoreNorm] = predict(modelType, JWC(1,(person(i)-1)*60+1:person(i)*60))
%                display(predictedWalk(end));
%                predictedWalk = char(predictedWalk(end));
%                allPlaces = [allPlaces,{predictedWalk}]; 
%                scoreTable = [scoreTable; scoreWalk];
               yfit = fjsModel3.predictFcn(JWC(1,(person(i)-1)*60+1:person(i)*60))  %% not valid in this version of MATLAB
               
%               [predictedNorm,scoreNorm] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60))
             % ref =  (person(i)-1)*60;
%              R1 = VelocityDiffJWC(1,[(person(i)-1)*60+1:(person(i)-1)*60+3]);
%              R2 = VelocityDiffJWC(1,[(person(i)-1)*60+10:(person(i)-1)*60+12]);
%              R3 = VelocityDiffJWC(1,[(person(i)-1)*60+40:(person(i)-1)*60+42]);
%              R4 = VelocityDiffJWC(1,[(person(i)-1)*60+52:(person(i)-1)*60+54]);
%              R5 = VelocityDiffJWC(1,[(person(i)-1)*60+46:(person(i)-1)*60+48]);
%              R6 = VelocityDiffJWC(1,[(person(i)-1)*60+58:(person(i)-1)*60+60]);
% %              
%               [predictedNorm,scoreNorm] = predict(modelType, [R1,R2,R3,R4,R5,R6])
%                    VelocityDiffJWC(1,[(person(i)-1)*60+1:(person(i)-1)*60+9]),...
%                    VelocityDiffJWC(1,[(person(i)-1)*60+43:(person(i)-1)*60+48]),...
%                    VelocityDiffJWC(1,[(person(i)-1)*60+55:(person(i)-1)*60+60]))
               
               display(predictedNorm(end));
               predictedNorm = char(predictedNorm(end));
               allPlaces = [allPlaces,{predictedNorm}]; 
               scoreTable = [scoreTable; scoreNorm];
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
           set(gcf,'units','normalized','outerposition',[0 0 1 1]);
       end
       firstLoop = 0;
    end
end

