
clc; clear all; close all;
% load('WaveDetect.mat')
load('WalkStandModel.mat')
% load('t3_depthModel.mat')
% load('t3_positionModel.mat')
% load('trainedModel.mat')

% Initialize Camera
[vid, depthVid, himg] = InitializeKinect();
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
        %frame = getsnapshot(vid);

        % Prep to log data in one line
        numberOfPeople = sum(depthMetaData.IsSkeletonTracked);
        person = find(d.IsSkeletonTracked == 1);
        [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);
        %log data
        [VelocityDiffJWC, oldData, oldDataJWC] = logAllData(d,numberOfPeople,person,oldData,oldDataJWC,JDI,JII,JTS,JWC,PDI,PII,PWC,SD,firstLoop);
        
        % Prep data for plotting
       skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
       %modelType = WaveDetect.ClassificationTree; 
       modelType = WalkStandModel.ClassificationTree;
%        t3_1 = trainedModel.ClassificationSVM;  
%        [predictedPosition, scoreML] = predict(t3_1, [[depthMetaData.JointDepthIndices(7,:,person)],...
%            [depthMetaData.JointDepthIndices(11,:,person)],...
%            [depthMetaData.JointDepthIndices(13,:,person)],...
%            [depthMetaData.JointDepthIndices(17,:,person)]]);
        
%        display(predictedPosition(end))
%        predictedPosition = string(predictedPosition(end))
%        t3_2 = t3_depthModel.ClassificationSVM; 
       allPlaces = [];
       if (firstLoop ==0)
           for i = 1:numberOfPeople
%                [predictedWave,scoreWave] = predict(modelType, VelocityDiff(1,(person(i)-1)*60+1:person(i)*60))
%                display(predictedWave(end));
%                predictedWave = char(predictedWave(end));
%                allPlaces = [allPlaces,{predictedWave}]; 
%                scoreTable = [scoreTable; scoreWave];
               [predictedWalk,scoreWalk] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60))
               display(predictedWalk(end));
               predictedWalk = char(predictedWalk(end));
               allPlaces = [allPlaces,{predictedWalk}]; 
               scoreTable = [scoreTable; scoreWalk];
           end
           %plot skeleton joints
           %plotData(skeletonJoints,numberOfPeople,allPlaces);
           allLabels = [];
           lineOptions = [{':o'}, {':go'},{':ko'}, {':ro'}, {':po'}, {':yo'}];
           hold on;
           for i = 1:numberOfPeople
               plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),'*');
           end
           hold off;
           allPlaces = char(allPlaces)
           legend(allPlaces);
           
           %save figures
         %  saveKinectPictures(d,frame);  
       end
       firstLoop = 0;
    end
end
