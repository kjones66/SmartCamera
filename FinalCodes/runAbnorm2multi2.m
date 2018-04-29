clc; clear; close all;
data = load('JWC_hmm_data_4versions.csv');
TRGUESS = [[.85],[.15];[.4],[.6]];
EMITGUESS2 = [[.4],[.45],[.05];[.05],[.05],[.9]];
EMITGUESS = [[.33],[.30],[.32],[.05];[.03],[.04],[.03],[.9]];
[ESTTR,ESTEMIT] = hmmtrain(data(:,61),TRGUESS,EMITGUESS);
[ESTTR2,ESTEMIT2] = hmmtrain(data(:,62),TRGUESS,EMITGUESS2);
[ESTTR_2W,ESTEMIT_2W] = hmmtrain(data(:,63),TRGUESS,EMITGUESS);
[ESTTR2_2W,ESTEMIT2_2W] = hmmtrain(data(:,64),TRGUESS,EMITGUESS2);
alertRecord = [];
firstAlertSent = 0;
countSinceSent = 0;

% Initialize Camera
[vid, depthVid, himg, src] = InitializeKinect();
firstLoop = 1;
oldData = 0;
oldDataJWC = 0;
myTable = cell(300,8);
row = 0;
  for i = 1:6               
     ThisPerson(i) = personClass2(i,ESTTR,ESTEMIT,ESTTR2,ESTEMIT2,ESTTR_2W,ESTEMIT_2W,ESTTR2_2W,ESTEMIT2_2W);
  end

prompt = {'Please enter your phone number:','Please enter your celular provider:'};
title = 'On Duty Security Personel';
dims = [1 50];
definput = {'123-456-7890','Verizon'};
answer = inputdlg(prompt,title,dims,definput)
number = answer(1,1);
carrier = char(answer(2,1));
% Run Kinect

while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);

    if sum(depthMetaData.IsSkeletonTracked) > 0
       % frame = getsnapshot(vid);
        
        row = row +1;
        d = depthMetaData;
        % Prep to log data in one line
        numberOfPeople = sum(depthMetaData.IsSkeletonTracked);
        person = find(d.IsSkeletonTracked == 1);
        [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);
        [VelocityDiffJWC, oldData, oldDataJWC] = logAllData(d,numberOfPeople,person,oldData,oldDataJWC,JDI,JII,JTS,JWC,PDI,PII,PWC,SD,firstLoop);
       skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
       allPlaces = [];
       if (firstLoop ==0)
            sendAlert = 0;
            alertMessage = [];
            for i = 1:numberOfPeople                  
               ThisPerson(i).getBehavior(VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));
               currentLabel = {strcat('Person  ', num2str(ThisPerson(i).ID), ': ', ThisPerson(i).label)};
               allPlaces = [allPlaces,currentLabel];
               display(allPlaces)
               alertMessage = strcat(alertMessage,'Person  ', num2str(ThisPerson(i).ID), ' behavior: ',ThisPerson(i).reportName);
                if (ThisPerson(i).reportnum == 2)
                   sendAlert = 1;
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
           lgd = legend(char(allPlaces));
           lgd.FontSize = 20;
            set(gcf,'units','normalized','outerposition',[0 0 1 1])
           
           alertRecord = [alertRecord;sendAlert];
           if (sendAlert ==1)
               if (firstAlertSent ==0)
                   pic = sprintf('%d_%d_%d_%d.jpg',d.AbsTime(2),...
                       d.AbsTime(3),d.AbsTime(1),d.FrameNumber);
                   saveas(figure(1),fullfile('T:\Kinect Data',pic));
                   filePath = fullfile('T:\Kinect Data',pic); % 'T:\Kinect Data\waveScreenshot.png';
                   send_text_message(number,carrier, ['Warning! Suspicious behavior detected. ',alertMessage])
                  %ADD EMAIL TO SEND IT TO
                 % sendmail('email','Smart Security System: Warning! Suspicious behavior detected.',alertMessage,filePath) 
                  firstAlertSent = 1;
                   countSinceSent = 0;
               elseif (countSinceSent > 30)
                   if (sum(alertRecord(end-30:end))>10)
                       pic = sprintf('%d_%d_%d_%d.jpg',d.AbsTime(2),...
                           d.AbsTime(3),d.AbsTime(1),d.FrameNumber);
                       saveas(figure(1),fullfile('T:\Kinect Data',pic));
                       filePath = fullfile('T:\Kinect Data',pic); % 'T:\Kinect Data\waveScreenshot.png';
                       send_text_message(number,carrier, ['Urgent! Suspicious behavior ongoing.',alertMessage])
                      %ADD EMAIL TO SEND IT TO
                      % sendmail('email','Smart Security System: Urgent! Suspicious behavior ongoing.',alertMessage,filePath) 
                   end
                    countSinceSent = 0;
               end
           end
           countSinceSent = countSinceSent + 1;
           display(countSinceSent)
           display(alertRecord(end))
         %  saveKinectPictures(d,frame)

       end
       firstLoop = 0;
     %  scoreTable
    end
end
