% Initialize Camera
clc; clear all; close all;
%close all;
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
modelType = trainedModel.ClassificationKNN; 


% Run Kinect
while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
        % Prep to log data in one line
        fid = fopen('test.csv', 'w') ;
        filename = 'Temp.csv';
        sprintf(filename);
        d = depthMetaData;
        [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);
        % Log data
        dlmwrite(filename,[d.AbsTime,d.FrameNumber,...
            d.IsPositionTracked,d.IsSkeletonTracked,...
            JDI,JII,JWC,PDI,PII,PWC,d.RelativeFrame,... %Add Segmentation Data
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
                %SJ = daTr20by2(depthMetaData.JointDepthIndices(:,:,j));
                yfit = predict(trainedModel.ClassificationKNN, [JDI,JII]);
                %display(yfit)
                
            end
        end

       % Plot skeleton joints  
       hold on;
       for i = 1:numberOfPeople
           plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),'*');
            % Step 4: Plot Results
            try
                imshow(insertText(img,[640,1],upper(cellstr(imagepred)),...
                    'AnchorPoint','RightTop','FontSize',50,'BoxColor','Green',...
                    'BoxOpacity',0.4),'Parent',ax1);
                ax2.Children.YData = yfit;
                ax2.YLim = [0 1];
            catch err
            end
            drawnow
       end
%        modelType = courseG_Model.ClassificationSVM; 
%        yfit = predict(modelType, SJ);
%        yfit2 = predict(modelType, SJ2);
%        display(yfit, yfit2)

%        position = trainedModel.predictFcn([skeletonJoints(3,1,1),skeletonJoints(3,2,1)])
% 
% %        position = TrainedModel.predictFcn(depthMetaData.JointDepthIndices(3,:,6))
%        print (position)
       
       hold off;
    end
end

stop(depthVid);