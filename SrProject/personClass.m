classdef personClass
   properties
      JWC_V
      last3
      last3Names
      STATES
      STATES_anyW
      ID
      ESTTR_2W
      ESTEMIT_2W
      ESTTR_anyW
      ESTEMIT_anyW
      predictedWalk
      predictedStand
      predictedWave
      behave
      behaveKey
      report
      scoreWalk
      scoreStand
      scoreWave
      reportName
      reportnum
      label
   end
   methods
      function obj = personClass(i,ESTTR_2W,ESTEMIT_2W,ESTTR_anyW,ESTEMIT_anyW)
          obj.ID = i;
          obj.last3 = [];
          obj.last3Names = [];
          obj.ESTTR_2W = ESTTR_2W;
          obj.ESTEMIT_2W = ESTEMIT_2W;
          obj.ESTTR_anyW = ESTTR_anyW;
          obj.ESTEMIT_anyW = ESTEMIT_anyW;
           obj.scoreWalk = [];
           obj.scoreStand = [];
           obj.scoreWave = [];
      end
      function r = addLast3(obj)
          display('Adding hmm')
          if (length(obj.last3)< 1)
                   obj.last3 = [obj.behaveKey];
                   obj.STATES = hmmviterbi(obj.last3,obj.ESTTR_2W,obj.ESTEMIT_2W);
                   obj.STATES_anyW = hmmviterbi(obj.last3,obj.ESTTR_anyW,obj.ESTEMIT_anyW);
          elseif (length(obj.last3)< 3)
                   obj.last3(1,(length(obj.last3)+1)) = [obj.behaveKey];
                   obj.STATES = hmmviterbi(obj.last3,obj.ESTTR_2W,obj.ESTEMIT_2W);
                   obj.STATES_anyW = hmmviterbi(obj.last3,obj.ESTTR_anyW,obj.ESTEMIT_anyW);
          else
                   obj.last3 = [obj.last3(1,2:3),obj.behaveKey];
                   obj.STATES = hmmviterbi(obj.last3,obj.ESTTR_2W,obj.ESTEMIT_2W);
                   obj.STATES_anyW = hmmviterbi(obj.last3,obj.ESTTR_anyW,obj.ESTEMIT_anyW);
          end
          if (ismember(2,obj.STATES_anyW))
               if (ismember(2,obj.STATES))
                   obj.reportName = 'Abnormal';
                   obj.reportnum = 2;
                   end
           else
               obj.reportName = 'Normal';
               obj.reportnum = 1;
          end
          obj.label = strcat(char(obj.last3),char(num2str(obj.STATES)),char(num2str(obj.STATES_anyW)),char(obj.reportName)); %cell?
          %obj.label = char(obj.label);
      end
      function r = getBehavior(obj)
              load('walkRun.mat')
              load('walkJump.mat')
              load('walkFall.mat')
              load('standRun.mat')
              load('standJump.mat')
              load('standFall.mat')
              load('waveRun.mat')
              load('waveJump.mat')
              load('waveFall.mat')
                %load('st23SVM.mat')
              load('st23predictnoConfidence.mat')
               modelType = walkJump.ClassificationEnsemble; 
               [predictedWalkA,scoreWalkA] = predict(modelType, obj.JWC_V);
               modelType = walkFall.ClassificationEnsemble; 
               [predictedWalkB,scoreWalkB] = predict(modelType, obj.JWC_V);
               modelType = walkRun.ClassificationEnsemble; 
               [predictedWalkC,scoreWalkC] = predict(modelType, obj.JWC_V);
               obj.predictedWalk = [predictedWalkA(end),predictedWalkB(end),predictedWalkC(end)];
               obj.scoreWalk = [obj.scoreWalk;[scoreWalkA(end),scoreWalkB(end),scoreWalkC(end)]];
                              
               
               modelType = standJump.ClassificationEnsemble; 
                [predictedStandA,scoreStandA] = predict(modelType, obj.JWC_V);
               modelType = standFall.ClassificationEnsemble; 
               [predictedStandB,scoreStandB] = predict(modelType, obj.JWC_V);
               modelType = standRun.ClassificationEnsemble; 
               [predictedStandC,scoreStandC] = predict(modelType, obj.JWC_V);
               obj.predictedStand = [predictedStandA(end),predictedStandB(end),predictedStandC(end)];
               obj.scoreStand = [obj.scoreStand;[scoreStandA(end),scoreStandB(end),scoreStandC(end)]];
               
                                    
               modelType = waveJump.ClassificationEnsemble; 
                [predictedWaveA,scoreWaveA] = predict(modelType, obj.JWC_V);
               modelType = waveFall.ClassificationEnsemble; 
               [predictedWaveB,scoreWaveB] = predict(modelType, obj.JWC_V);
               modelType = waveRun.ClassificationKNN; 
               [predictedWaveC,scoreWaveC] = predict(modelType, obj.JWC_V);
               obj.predictedWave = [predictedWaveA(end),predictedWaveB(end),predictedWaveC(end)];
               obj.scoreWave = [obj.scoreWave;[scoreWaveA,scoreWaveB,scoreWaveC]];
               
               if(((strcmp(predictedStandA,'Stand')&&strcmp(predictedStandB,'Stand'))...
                       || (strcmp(predictedStandA,'Stand')&&strcmp(predictedStandC,'Stand'))...
                       || (strcmp(predictedStandB,'Stand')&&strcmp(predictedStandC,'Stand')))...
                       ||((strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveB,'Wave'))...
                       || (strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveC,'Wave'))...
                       || (strcmp(predictedWaveB,'Wave')&&strcmp(predictedWaveC,'Wave'))))
                   obj.behave = 'Stand/Wave';
                   obj.behaveKey = 1;
               elseif (strcmp(predictedWalkA,'Walk')...
                       ||strcmp(predictedWalkB,'Walk')...
                       ||strcmp(predictedWalkC,'Walk'))
                   obj.behave = 'Walk';
                   obj.behaveKey = 2;
               else 
                   obj.behave = 'Abnormal';
                   obj.behaveKey = 3;
               end
               addLast3(obj)
      end
   end
end 