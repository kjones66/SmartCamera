clc; clear; close all;
defineFile = 'SkeletonTestA.csv';
imaqreset;
%just to make tilt adjustable, click on src
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
while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
       numberOfPeople = sum(depthMetaData.IsSkeletonTracked);
       skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
       index = [];
        count = 0;
        j = 0;
        joints = [];
        while count < numberOfPeople
            j = j+1;
            if depthMetaData.IsSkeletonTracked(j)
                index = [[index],j];
                count = count +1;
                joints = [[joints],depthMetaData.JointDepthIndices(:,:,j)];
            end
        end
       fid = fopen('test.csv', 'w') ;
       sprintf(defineFile);
       dlmwrite(defineFile,[[depthMetaData.FrameNumber;zeros19],[joints]],'-append','delimiter',',')
       fclose(fid)  
       hold on;
       for i = 1:numberOfPeople
           plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),'*');
       end
       hold off;
    end
end

stop(depthVid);
