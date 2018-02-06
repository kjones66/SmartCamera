
clc; clear all; close all;
load('WalkStandModel.mat')
load('Model4.mat')
% load('t3_depthModel.mat')
% load('t3_positionModel.mat')
% load('trainedModel.mat')

% Initialize Camera
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
oldData = 0;
firstLoop = 1;

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
        dlmwrite(filename,dataLine,'-append','delimiter',',')
        % Save data
        fclose(fid)
        if (firstLoop == 0)
            VelocityDiff = dataLine - oldData;
            fid = fopen('test.csv', 'w') ;
            filename = 'trial4_JWCVelocity_noWave.csv';
            sprintf(filename);
            dlmwrite(filename,VelocityDiff,'-append','delimiter',',');
            % Save data
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
       modelType = WalkStandModel.ClassificationTree; 
       modelType2 = Model4.ClassificationKNN;
       person = depthMetaData.IsSkeletonTracked;
       person = find(d.IsSkeletonTracked == 1);
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
               [predictedMotion,scoreMotion] = predict(modelType, VelocityDiff(1,(person(i)-1)*60+1:person(i)*60))
               display(predictedMotion(end));
               [predictedWave,scoreWave] = predict(modelType2, VelocityDiff(1,(person(i)-1)*60+1:person(i)*60))
               display(predictedWave(end));
               predictedWave = char(predictedWave(end));
               predictedMotion = char(predictedMotion(end));
               allPlaces = [allPlaces,{predictedWave,predictedMotion}]; 
           end
           allLabels = [];
           lineOptions = [{':go'}, {':mo'},{':ko'}, {':ro'}, {':wo'}, {':yo'}];
           hold on;
           
           for i = 1:numberOfPeople
               currentSym = char(lineOptions(i));
               plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),currentSym);
               %             display(allPlaces)
           end
           hold off;
           %        figure1 = figure();
           
           
           %save pictures
%            saveas(figure, fullfile('T:\Kinect Data','asdf.jpg'))
%            pic = sprintf('%d_%d_%d_%d.jpg',d.AbsTime(2),...
%                d.AbsTime(3),d.AbsTime(1),d.FrameNumber);
%            saveas(figure(1),fullfile('T:\Kinect Data',pic));
%            frame = getsnapshot(vid);
%            
%           figure2 = image(frame);
%           image(frame);
%           pic = sprintf('%d_%d_%d_%dimage.jpg',d.AbsTime(2),...
%                d.AbsTime(3),d.AbsTime(1),d.FrameNumber);
%           saveas(figure(1),fullfile('T:\Kinect Data',pic));
%    %        close figure1;
%           close (figure(2));
           
           allPlaces = char(allPlaces)
           legend(allPlaces);
       end
       firstLoop = 0;
    end
end