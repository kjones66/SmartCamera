function position = jointsLive2(trial1_ArmPosition,data)
  [fig, ax1, ax2] = figureSetup(trial1_ArmPosition);
  [imagepred, probabilities] = predict(trial1_ArmPosition,data); %fix for kinect?????
  position = imagepred; 
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
end
