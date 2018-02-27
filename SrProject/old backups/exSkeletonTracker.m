clc; clear; close all;
imaqreset;

depthVid = videoinput('kinect',2)

triggerconfig(depthVid, 'manual');
depthVid.FramesPerTrigger = 1;
depthVid.TriggerREpeat = inf;
set(getselectedsource(depthVid), 'TrackingMode', 'Skeleton');

viewer = vision.DeployableVideoPlayer();

start(depthVid);
himg = figure;

while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
       numberOfPeople = sum(depthMetaData.IsSkeletonTracked);
       skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
       hold on;
       for i = 1:numberOfPeople
           plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),'*');
       end
       hold off;
    end
end

stop(depthVid);
