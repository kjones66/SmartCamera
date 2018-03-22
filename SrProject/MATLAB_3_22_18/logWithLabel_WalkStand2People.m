clc; clear all; close all;
load('WalkStandModel.mat')

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
    frame = getsnapshot(vid);
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
        d = depthMetaData;
        % Prep to log data in one line
        numberOfPeople = sum(depthMetaData.IsSkeletonTracked);
        person = find(d.IsSkeletonTracked == 1);
        [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);
        %log data
        [VelocityDiffJWC, oldData, oldDataJWC] = logAllData(d,numberOfPeople,person,oldData,oldDataJWC,JDI,JII,JTS,JWC,PDI,PII,PWC,SD,firstLoop);
        % Prep data for plotting
       skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
       modelType = WalkStandModel.ClassificationTree; 
       allPlaces = [];
       if (firstLoop ==0)
           for i = 1:numberOfPeople
               [predictedWalk,scoreWalk] = predict(modelType, VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60))
               display(predictedWalk(end));
               predictedWalk = char(predictedWalk(end));
               allPlaces = [allPlaces,{predictedWalk}]; 
               scoreTable = [scoreTable; scoreWalk];
           end
           allLabels = [];
           lineOptions = [{':o'}, {':go'},{':ko'}, {':ro'}, {':po'}, {':yo'}];
           hold on;
           for i = 1:numberOfPeople
               currentSym = char(lineOptions(i));
               plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),currentSym);
           end
           hold off;
           allPlaces = char(allPlaces)
           lgd = legend(allPlaces);
           lgd.FontSize = 20;
           saveKinectPictures(d,frame)
       end
       firstLoop = 0;
    end
end