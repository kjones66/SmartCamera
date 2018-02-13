
clc; clear all; close all;
load('ProximityModel4.mat')

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
    
    if sum(depthMetaData.IsSkeletonTracked) > 0
        d = depthMetaData;
        numberOfPeople = sum(depthMetaData.IsSkeletonTracked);
        person = find(d.IsSkeletonTracked == 1);
        [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);
       
        if (numberOfPeople > 1)
            FullData = [];
           % fid = fopen('test.csv', 'w') ;
            for i = 1:numberOfPeople
                line = [];
                for j = (i+1):numberOfPeople
                    %xyz difference between two people's (hip center,
                    %spine, shoulder center)
                    line = [line, JWC((person(i)-1)*60+1:person(i)*60-51)-JWC((person(j)-1)*60+1:person(j)*60-51)];
                    %filename = sprintf('%d_%d_%dIndivD.csv',d.AbsTime(2),d.AbsTime(3),d.AbsTime(1));
                    %dlmwrite(fullfile('T:\Kinect Data',filename),line,'-append','delimiter',',')
                    %fclose(fid)
                end
                 FullData = [FullData;line]
            end
        end
%             fclose(fid)
            
            % Prep data for plotting
            skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
            modelType = ProximityModel4.ClassificationTree;
            allPlaces = [];
            if (firstLoop ==0)
                for i = 1:(numberOfPeople-1)
                    if (numberOfPeople > 1)
                        [predictedDist,scoreDist] = predict(modelType, FullData(i,:))
                        display(predictedDist(end));
                        predictedDist = char(predictedDist(end));
                        allPlaces = [allPlaces,{predictedDist}];
                        scoreTable = [scoreTable; scoreDist];
                    end
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
                lgd.FontSize = 40;
                set(gcf,'units','normalized','outerposition',[0 0 1 1])
            end
            firstLoop = 0;
        end
    end