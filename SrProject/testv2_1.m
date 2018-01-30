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
%modelType = trainedModel.ClassificationSVM; 


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
        dlmwrite(filename,[d.AbsTime,d.FrameNumber,...
            d.IsPositionTracked,d.IsSkeletonTracked,...
            JDI,JII,JTS,JWC,PDI,PII,PWC,d.RelativeFrame,... %Add Segmentation Data
            d.SkeletonTrackingID,d.TriggerIndex],'-append','delimiter',',')
        % Save data
        fclose(fid)
        
        % Prep data for plotting
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
                %SJ = daTr20by2(skeletonJoints(:,:,j));
            end
        end
%        modelType = courseG_Model.ClassificationSVM; 
    %  person = depthMetaData.IsSkeletonTracked;
       person = find(d.IsSkeletonTracked ==1);
%        t3_1 = trainedModel.ClassificationSVM;  
%        [predictedPosition, scoreML] = predict(t3_1, [[depthMetaData.JointDepthIndices(7,:,person)],...
%            [depthMetaData.JointDepthIndices(11,:,person)],...
%            [depthMetaData.JointDepthIndices(13,:,person)],...
%            [depthMetaData.JointDepthIndices(17,:,person)]]);
%        %d.JointWorldCoordinates(:,:,person(1)))
%        display(predictedPosition(end))
%        predictedPosition = string(predictedPosition(end))
       t3_2 = t3_depthModel.ClassificationSVM;      
       [predictedPlace,scorePlace] = predict(t3_2, JWC(1,(person(1)-1)*60+1:person(1)*60))
       display(predictedPlace(end));
       %predictedPlace = yfit.LABEL()
       predictedPlace = string(predictedPlace(end))
       hold on;
       for i = 1:numberOfPeople
           plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),'*');
       end
%        position = trainedModel.predictFcn([skeletonJoints(3,1,1),skeletonJoints(3,2,1)])
% 
% %        position = TrainedModel.predictFcn(depthMetaData.JointDepthIndices(3,:,6))
%        print (position)
       
       hold off;
       %aLabel = string(predictedPosition(end))
       bLabel = sprintf("%s %s",predictedPlace); %,predictedPosition);
       legend(bLabel);
    end
end

stop(depthVid);