
clc; clear all; close all;
load('WaveDetect.mat')

% Initialize Camera
[vid, depthVid, himg] = InitializeKinect();
firstLoop = 1;
oldData = 0;
j=0;

% Run Kinect
while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
        % Prep to log data in one line
        fid = fopen('test.csv', 'w') ;
        filename = 'testv2.csv';
        sprintf(filename);
        d = depthMetaData;
        [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);
        % Log data
        dataLine = JWC;
        if (firstLoop == 0)
            VelocityDiff = dataLine - oldData;
            fclose(fid);
        end
        oldData = dataLine;
        % Prep data for plotting
        numberOfPeople = sum(depthMetaData.IsSkeletonTracked)
        skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
        index = [];
        j = 0;
        joints = [];
        for count = 1:numberOfPeople
            j = j+1;
            if depthMetaData.IsSkeletonTracked(j)
                index = [[index],j];
                joints = [[joints],depthMetaData.JointDepthIndices(:,:,j)];
            end
        end
       modelType = WaveDetect.ClassificationTree; 
       person = depthMetaData.IsSkeletonTracked;
       person = find(d.IsSkeletonTracked == 1);
       allPlaces = [];
       scoreTable = [];
       if (firstLoop ==0)
           for i = 1:numberOfPeople
               [predictedWave,scoreWave] = predict(modelType, VelocityDiff(1,(person(i)-1)*60+1:person(i)*60))
               display(predictedWave(end));
               predictedWave = char(predictedWave(end))
               allPlaces = [allPlaces,predictedWave];
               scoreTable = [scoreTable, scoreWave];
           end
           allLabels = [];
           lineOptions = [{':o'}, {':go'},{':ko'}, {':ro'}, {':po'}, {':yo'}];
           hold on;
           
           for i = 1:numberOfPeople
               plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),'*');
           end
           hold off;
           allPlaces = char(allPlaces)
           lgd = legend(allPlaces);
           lgd.FontSize = 40;
           set(gcf,'units','normalized','outerposition',[0 0 1 1])
       end
       firstLoop = 0;
    end
end