% Initialize Camera
%clc; clear all; close all;
close all;
imaqreset; %just to make tilt adjustable, click on src
vid = videoinput('kinect',1,'RGB_640x480');
src = getselectedsource(vid);
depthVid = videoinput('kinect',2)
triggerconfig(depthVid, 'manual');
src2 = getselectedsource(depthVid);
src2.TrackingMode
src2.TrackingMode = 'Skeleton'; % doesn't seem to make a difference
%src2.EnableBodyTracking = 'on'; only for V2
depthVid.FramesPerTrigger = 1;
depthVid.TriggerREpeat = inf;
set(getselectedsource(depthVid), 'TrackingMode', 'Skeleton');
viewer = vision.DeployableVideoPlayer();
start(depthVid);
himg = figure;
j=0;
zeros19 = zeros(19, 1);
% ----------------modelType = trainedModel.ClassificationSVM; 
oldData = 0;
firstLoop = 1;

% Run Kinect
while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);
    
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
        src2
        % Prep to log data in one line
        fid = fopen('test.csv', 'w') ;
        filename = 'trial3_OutNear.csv';
        sprintf(filename);
        d = depthMetaData;
        [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);
        % Log data
        dataLine = [d.AbsTime,d.FrameNumber,...
            d.IsPositionTracked,d.IsSkeletonTracked,...
            JDI,JII,JWC,PDI,PII,PWC,d.RelativeFrame,... %Add Segmentation Data
            d.SkeletonTrackingID,d.TriggerIndex];
        dlmwrite(filename,dataLine,'-append','delimiter',',');
        % Save data
        fclose(fid);
        
        if (firstLoop == 0)
            diff = dataLine - oldData;
            
            fid = fopen('test.csv', 'w') ;
            filename = 'trial3_OutNearDistance.csv';
            sprintf(filename);
            dlmwrite(filename,diff,'-append','delimiter',',');
            % Save data
            fclose(fid);
        end
        firstLoop = 0;
        
        
        oldData = dataLine;
        % Prep data for plotting
        numberOfPeople = sum(depthMetaData.IsSkeletonTracked)
        skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
        index = [];
        count = 0;
        j = 0;
        joints = [];
        for count = 1 : numberOfPeople
            j = j+1;
            if depthMetaData.IsSkeletonTracked(j)
                index = [[index],j];
                joints = [[joints],depthMetaData.JointDepthIndices(:,:,j)];
                %SJ = daTr20by2(skeletonJoints(:,:,j));
            end
        end

       % Plot skeleton joints 
       allLabels = [];
       lineOptions = [":o", ":go", ":ko", ":ro", ":po", ":yo"];

       hold on;
       for i = 1:numberOfPeople
               num = num2str(i);
               plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),lineOptions(i));
               thisLabel = ["Person " + num];
               allLabels = [allLabels, thisLabel];
       end        
       hold off;
       legend(allLabels);
    end
end

stop(depthVid);
