function jointsLive(trial1_ArmPosition,bag)
% CarFinderLive uses a trained classifier and a featureExtractor function
% to classify streaming webcam images 
% Copyright (c) 2015, MathWorks, Inc.

[fig, ax1, ax2] = figureSetup(trial1_ArmPosition);

% Start webcam
% wcam = webcam;

% Run live car detection
while ishandle(fig)
    % Step 1: Get Next Frame
%     img = snapshot(wcam);
%     grayimg = rgb2gray(img);
%     
%     % Step 2: Extract Features
% 	imagefeatures = double(encode(bag,grayimg));  
    % Step 3: Predict car using extracted features
	[imagepred, probabilities] = predict(trial1_ArmPosition,imagefeatures); %fix for kinect?????
    
    % Step 4: Plot Results
    try
        imshow(insertText(img,[640,1],upper(cellstr(imagepred)),...
            'AnchorPoint','RightTop','FontSize',50,'BoxColor','Green',...
            'BoxOpacity',0.4),'Parent',ax1);    
        ax2.Children.YData = probabilities;
        ax2.YLim = [0 1];
    catch err
    end
    drawnow
end 

function cname = getClassifierName(trial1_ArmPosition)
% getClassifierName extracts name of the classifier from a trained model
cname = class(trial1_ArmPosition);
if isa(trial1_ArmPosition,'ClassificationECOC')
    cname = 'SVM';
end
pos = strfind(cname,'.');
if ~isempty(pos)
  cname = cname(pos(end)+1:end);
end

function [fig, ax1, ax2] = figureSetup(trial1_ArmPosition)
% figureSetup sets up figure window for webcam feed and bar chart for
% classification probability
warning('off','images:imshow:magnificationMustBeFitForDockedFigure')
set(0,'defaultfigurewindowstyle','docked')
fig = figure('Name','Skeleton Finder Go!','NumberTitle','off');
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
bar(ax2,zeros(1,numel(trial1_ArmPosition.ClassNames)),'FaceColor',[0.2 0.6 0.8])
set(ax2,'XTickLabel',cellstr(trial1_ArmPosition.ClassNames));
title(getClassifierName(trial1_ArmPosition)), ylabel('Probability')
set(0,'defaultfigurewindowstyle','normal')