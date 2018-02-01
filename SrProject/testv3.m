clc; clear all; close all;
load('t3_depthModel.mat')
load('t3_positionModel.mat')
load('trainedModel.mat')

% Initialize Camera
%clc; clear all; close all;
close all;
imaqreset; %just to make tilt adjustable, click on src
vid = videoinput('kinect',1,'RGB_640x480');
src = getselectedsource(vid);
depthVid = videoinput('kinect',2)
triggerconfig(depthVid, 'manual');
depthVid.FramesPerTrigger = 1;
depthVid.TriggerREpeat = inf;
set(getselectedsource(depthVid), 'TrackingMode', 'Skeleton');
viewer = vision.DeployableVideoPlayer();
start(depthVid);
himg = figure;
j=0;
zeros19 = zeros(19, 1);

% Run Kinect
while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
        % Prep to log data in one line
%         fid = fopen('test.csv', 'w') ;
%         filename = 'testv2.csv';
%         sprintf(filename);
        d = depthMetaData;
        [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);
%         % Log data
%         dlmwrite(filename,[d.AbsTime,d.FrameNumber,...
%             d.IsPositionTracked,d.IsSkeletonTracked,...
%             JDI,JII,JTS,JWC,PDI,PII,PWC,d.RelativeFrame,... %Add Segmentation Data
%             d.SkeletonTrackingID,d.TriggerIndex],'-append','delimiter',',')
%         % Save data
%         fclose(fid)
        
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
%        modelType = courseG_Model.ClassificationSVM; 
%        person = depthMetaData.IsSkeletonTracked;
       person = find(d.IsSkeletonTracked == 1);
%        t3_1 = trainedModel.ClassificationSVM;  
%        [predictedPosition, scoreML] = predict(t3_1, [[depthMetaData.JointDepthIndices(7,:,person)],...
%            [depthMetaData.JointDepthIndices(11,:,person)],...
%            [depthMetaData.JointDepthIndices(13,:,person)],...
%            [depthMetaData.JointDepthIndices(17,:,person)]]);
        
%        display(predictedPosition(end))
%        predictedPosition = string(predictedPosition(end))
       t3_2 = t3_depthModel.ClassificationSVM; 
       allPlaces = [];
       for i = 1:numberOfPeople
            [predictedPlace,scorePlace] = predict(t3_2, JWC(1,(person(i)-1)*60+1:person(i)*60))
            display(predictedPlace(end));
            predictedPlace = string(predictedPlace(end))
            allPlaces = [allPlaces,predictedPlace];
       end
       allLabels = [];
       lineOptions = [":o", ":go", ":ko", ":ro", ":po", ":yo"];
       hold on;
       for i = 1:numberOfPeople 
           plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),lineOptions(i));
            display(allPlaces)
       end
       hold off;
       legend(allPlaces);
    end
end

stop(depthVid);