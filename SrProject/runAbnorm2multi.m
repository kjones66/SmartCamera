clc; clear; close all;
load('hmm_data_matrix.mat')
any2W = s;
load('hmm_data_matrix_anyWalk.mat')
anyW = s;
TRGUESS = [[.85],[.15];[.4],[.6]];
EMITGUESS = [[.4],[.45],[.05];[.05],[.05],[.9]];
[ESTTR_2W,ESTEMIT_2W] = hmmtrain(any2W,TRGUESS,EMITGUESS);
[ESTTR_anyW,ESTEMIT_anyW] = hmmtrain(anyW,TRGUESS,EMITGUESS);

% Initialize Camera
[vid, depthVid, himg, src] = InitializeKinect();
firstLoop = 1;
oldData = 0;
oldDataJWC = 0;
myTable = cell(300,8);
row = 0;
% for i = 1:6               
 %   ThisPerson = personClass(1,ESTTR_2W,ESTEMIT_2W,ESTTR_anyW,ESTEMIT_anyW);
%  end
  for i = 1:6               
     ThisPerson(i) = personClass(i,ESTTR_2W,ESTEMIT_2W,ESTTR_anyW,ESTEMIT_anyW);
  end

% Run Kinect
while ishandle(himg)
    trigger(depthVid);
    [depthMap, ~, depthMetaData] = getdata(depthVid);
    imshow(depthMap, [0 4096]);

    if sum(depthMetaData.IsSkeletonTracked) > 0
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
            for i = 1:numberOfPeople               
               %ThisPerson(i) = personClass(i,ESTTR_2W,ESTEMIT_2W,ESTTR_anyW,ESTEMIT_anyW);
             %  ThisPerson.JWC_V = VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60);

               
               ThisPerson(i).getBehavior(VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60));


               %ThisPerson.JWC_V = VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60);
               %ThisPerson.getBehavior()
             
%                if (ThisPerson.reportnum == 2)
%                        send_text_message('925-337-5087','Verizon', 'Smart Camera: Security Alert!')
%                        sendmail('aweber13@lion.lmu.edu','Smart Security System: Alert!','Smart Security System: Alert!')
%                end
               
%                fid = fopen('test.csv', 'w') ;
               %filename = sprintf('JWC_hmm_labels_Walk_Mohammed.csv');
               %filename = sprintf('JWC_hmm_labels_Run_Mohammed.csv');
%                dataLine = [thisJWC,stateKey,last3,STATES,STATES_anyW,reportnum];
%                dlmwrite(filename,dataLine,'-append','delimiter',',')
%                fclose(fid)
               
                allPlaces = [allPlaces,ThisPerson(i).label];
            end
            %   scoreTable = [scoreTable; [scoreWalk(end),scoreStand(end),scoreWave(end)]];
%            end
           allLabels = [];
           lineOptions = [{':o'}, {':go'},{':ko'}, {':ro'}, {':po'}, {':yo'}];
           hold on;
           for i = 1:numberOfPeople
               currentSym = char(lineOptions(i));
               plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),currentSym);
           end
           hold off;
           allPlaces = char(allPlaces);
           lgd = legend(allPlaces);
           lgd.FontSize = 20;
%            set(gcf,'units','normalized','outerposition',[0 0 1 1])
       end
       firstLoop = 0;
     %  scoreTable
    end
end
