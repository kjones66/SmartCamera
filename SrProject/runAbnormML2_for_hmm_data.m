clc; clear; close all;
%load('AbVwalk_spineankle.mat')
load('walkRun.mat')
load('walkJump.mat')
load('walkFall.mat')
load('standRun.mat')
load('standJump.mat')
load('standFall.mat')
load('waveRun.mat')
load('waveJump.mat')
load('waveFall.mat')
load('newWalkRun.mat')
load('WavLeftR.mat')
load('WavLeftF.mat')
load('WavLeftJ.mat')
%load('st23SVM.mat')
load('st23predictnoConfidence.mat')
% load('WaveStand2.mat')
% load('WaveWalk2.mat')
% load('hmm_data_matrix.mat')
% any2W = s;
 load('new_hmm_training_data.mat')
 load('new_hmm_training_data_2state.mat')
% anyW = s;
%load('hmm_data_matrix_anyWalk.mat')
stateList = [];
stateList2 = [];
stateList_2W = [];
stateList2_2W = [];
TRGUESS = [[.85],[.15];[.4],[.6]];
EMITGUESS2 = [[.4],[.45],[.05];[.05],[.05],[.9]];
EMITGUESS = [[.33],[.30],[.32],[.05];[.03],[.04],[.03],[.9]];
% % [ESTTR_2W,ESTEMIT_2W] = hmmtrain(any2W,TRGUESS,EMITGUESS);
% % [ESTTR_anyW,ESTEMIT_anyW] = hmmtrain(anyW,TRGUESS,EMITGUESS);
[ESTTR,ESTEMIT] = hmmtrain(new_hmm_training_data,TRGUESS,EMITGUESS);
[ESTTR2,ESTEMIT2] = hmmtrain(new_hmm_training_data_2state,TRGUESS,EMITGUESS2);
% Initialize Camera
[vid, depthVid, himg, src] = InitializeKinect();
firstLoop = 1;
oldData = 0;
oldDataJWC = 0;
scoreTable = [];
scoreWalk  = [];
scoreStand = [];
scoreWave = [];
myTable = cell(300,8);
row = 0;
loop = 0;
last3 = [];
last3Name = [];

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
        %log data
       % [VelocityDiff,oldData] = logAllData(d,oldData,JDI,JII,JTS,JWC,PDI,PII,PWC,SD,firstLoop)
        [VelocityDiffJWC, oldData, oldDataJWC] = logAllData(d,numberOfPeople,person,oldData,oldDataJWC,JDI,JII,JTS,JWC,PDI,PII,PWC,SD,firstLoop);
        % Prep data for plotting
       skeletonJoints = depthMetaData.JointDepthIndices(:,:,depthMetaData.IsSkeletonTracked);
       allPlaces = [];
       if (firstLoop ==0)
           loop = loop+1;
           for i = 1:numberOfPeople
%                print('i :')
               %display(i)
               thisJWC = VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60);
               modelType = walkJump.ClassificationEnsemble; 
               [predictedWalkA,scoreWalkA] = predict(modelType, thisJWC);
              
               modelType = walkFall.ClassificationEnsemble; 
               [predictedWalkB,scoreWalkB] = predict(modelType, thisJWC);
               modelType = newWalkRun.ClassificationEnsemble; 
               [predictedWalkC,scoreWalkC] = predict(modelType, thisJWC);
               predictedWalk = [predictedWalkA(end),predictedWalkB(end),predictedWalkC(end)];
           %    display(predictedWalk);
               scoreWalk = [scoreWalk;[scoreWalkA(end),scoreWalkB(end),scoreWalkC(end)]];
                              
               
               modelType = standJump.ClassificationEnsemble; 
                [predictedStandA,scoreStandA] = predict(modelType, thisJWC);
               modelType = standFall.ClassificationEnsemble; 
               [predictedStandB,scoreStandB] = predict(modelType, thisJWC);
               modelType = standRun.ClassificationEnsemble; 
               [predictedStandC,scoreStandC] = predict(modelType, thisJWC);
               predictedStand = [predictedStandA(end),predictedStandB(end),predictedStandC(end)];
               scoreStand = [scoreStand;[scoreStandA(end),scoreStandB(end),scoreStandC(end)]];
               
                                    
               modelType = waveJump.ClassificationEnsemble; 
                [predictedWaveA,scoreWaveA] = predict(modelType, thisJWC);
               modelType = waveFall.ClassificationEnsemble; 
               [predictedWaveB,scoreWaveB] = predict(modelType, thisJWC);
               modelType = waveRun.ClassificationKNN; 
               [predictedWaveC,scoreWaveC] = predict(modelType, thisJWC);
               
                modelType = WavLeftR.ClassificationEnsemble; 
               [predictedWaveD,scoreWaveD] = predict(modelType, thisJWC);
               modelType = WavLeftF.ClassificationKNN; 
               [predictedWaveE,scoreWaveE] = predict(modelType, thisJWC);
               modelType = WavLeftJ.ClassificationSVM; 
               [predictedWaveF,scoreWaveF] = predict(modelType, thisJWC);
               
               predictedWave = [predictedWaveA(end),predictedWaveB(end),predictedWaveC(end),predictedWaveD(end),predictedWaveE(end)];
               scoreWave = [scoreWave;[scoreWaveA,scoreWaveB,scoreWaveC]];
            %   display(predictedWave);
               
%                
               


               if(((strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveB,'Wave'))...
                       || (strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveC,'Wave'))...
                       || (strcmp(predictedWaveB,'Wave')&&strcmp(predictedWaveC,'Wave')))...
                       || ((strcmp(predictedWaveD,'Wave')&&strcmp(predictedWaveE,'Wave'))...
                       || (strcmp(predictedWaveD,'Wave')&&strcmp(predictedWaveF,'Wave'))...
                       || (strcmp(predictedWaveE,'Wave')&&strcmp(predictedWaveF,'Wave'))))
                   Move = 'Wave';
                   stateKey = 1;
                   stateKey2 = 1;
                   stateKey_2W = 1;
                   stateKey2_2W = 1;
               elseif ((strcmp(predictedStandA,'Stand')&&strcmp(predictedStandB,'Stand'))...
                       || (strcmp(predictedStandA,'Stand')&&strcmp(predictedStandC,'Stand'))...
                       || (strcmp(predictedStandB,'Stand')&&strcmp(predictedStandC,'Stand')))
                        Move = 'Stand';
                        stateKey = 3;
                        stateKey2 = 1;
                        stateKey_2W = 3;
                        stateKey2_2W = 1;
               else
                        Move = 'Abnormal';
                        stateKey = 4;
                        stateKey2 = 3;
                        stateKey_2W = 4;
                        stateKey2_2W = 3;
               end
               
               if strcmp(Move,'Abnormal')
                   if ((strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkB,'Walk'))...
                           || (strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkC,'Walk'))...
                           || (strcmp(predictedWalkB,'Walk')&&strcmp(predictedWalkC,'Walk')))
                       Move = 'Walk';
                       stateKey_2W = 2;
                       stateKey2_2W = 2;
                   elseif (strcmp(predictedWalkA,'Walk')||strcmp(predictedWalkB,'Walk')...
                           ||strcmp(predictedWalkC,'Walk'))
                   %    Move = 'Walk';
                       stateKey = 2;
                       stateKey2 = 2;
                   end
                
               stateList = [stateList;stateKey];
               stateList2 = [stateList2;stateKey2];
               stateList_2W = [stateList_2W;stateKey_2W];
               stateList2_2W = [stateList2_2W;stateKey2_2W];

               fid = fopen('test.csv', 'w') ;
               filename = sprintf('JWC_hmm_data_4versions.csv');
               dataLine = [thisJWC,stateKey,stateKey2,stateKey_2W,stateKey2_2W];
               dlmwrite(filename,dataLine,'-append','delimiter',',')
               fclose(fid)
               
%                
%                if (loop > 4)
% %                    last3 = [last3,stateKey];
% %                    last3 = last3(1,2:4);
% %                    last3Name = [last3Name,state];
% %                    last3Name = last3Name(1,2:4);
%                    STATES = hmmviterbi(transpose(stateList(end-4:end,1)),ESTTR,ESTEMIT);
%                    STATES2 = hmmviterbi(transpose(stateList2(end-4:end,1)),ESTTR2,ESTEMIT2);
%                    %STATES_anyW = hmmviterbi(last3,ESTTR_anyW,ESTEMIT_anyW);
%                elseif (loop <= 4)
% %                    last3 = [last3,stateKey];
% %                    last3Name = [last3Name,state];
% %                    STATES = hmmviterbi(last3,ESTTR_2W,ESTEMIT_2W);
% %                    STATES_anyW = hmmviterbi(last3,ESTTR_anyW,ESTEMIT_anyW);
%                     STATES = hmmviterbi(transpose(stateList(end,1)),ESTTR,ESTEMIT);
%                     STATES2 = hmmviterbi(transpose(stateList2(end,1)),ESTTR2,ESTEMIT2);
%                end
               
%                if (ismember(2,STATES_anyW))
%                    if (ismember(2,STATES))
%                        report = 'Abnormal'
%                        reportnum = 2;
% %                        send_text_message('925-337-5087','Verizon', 'Smart Camera: Security Alert!')
% %                        sendmail('aweber13@lion.lmu.edu','Smart Security System: Alert!','Smart Security System: Alert!')
%                    end
%                else
%                    report = 'Normal'
%                    reportnum = 1;
%                end
%                 if (ismember(2,STATES2))
%                    if (ismember(2,STATES))
%                        report = 'Abnormal'
%                        reportnum = 2;
% %                        send_text_message('925-337-5087','Verizon', 'Smart Camera: Security Alert!')
% %                        sendmail('aweber13@lion.lmu.edu','Smart Security System: Alert!','Smart Security System: Alert!')
%                    end
%                else
%                    report = 'Normal'
%                    reportnum = 1;
%                end
%                display (report)
%                
               
%                
%                allPlaces = {char(last3Name),char(num2str(STATES)),char(num2str(STATES_anyW)),char(report)};
%                scoreTable = [scoreTable; [scoreWalk(end),scoreStand(end),scoreWave(end)]];
%                  if (length(stateList)>5)
%                        display(transpose(stateList2(end-4:end,1)));
%                  else
%                      display(stateList2(end,1));
%                  end
                 %scoreTable = [scoreTable; [scoreWalk(end),scoreStand(end),scoreWave(end)]];
           end
           allLabels = [];
           lineOptions = [{':o'}, {':go'},{':ko'}, {':ro'}, {':po'}, {':yo'}];
           hold on;
           for i = 1:numberOfPeople
               currentSym = char(lineOptions(i));
               plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),currentSym);
           end
           hold off;
%            display('STATES: ')
%            display(STATES2)
           allPlaces = {char(Move)};
           lgd = legend(allPlaces);
           lgd.FontSize = 20;
%            set(gcf,'units','normalized','outerposition',[0 0 1 1])
       end
       firstLoop = 0;
     %  scoreTable
    end
end
