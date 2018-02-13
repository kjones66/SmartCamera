function [vid, depthVid, himg] = InitializeKinect()
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
end

