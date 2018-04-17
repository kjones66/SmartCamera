classdef personClass2 < handle
    properties
        JWC_V
        last3
        last3Names
%         last3_2
%         last3Names
        STATES
        STATES2
        STATES_2W
        STATES2_2W
        ID
        ESTTR
        ESTEMIT
        ESTTR2
        ESTEMIT2
        ESTTR_2W
        ESTEMIT_2W
        ESTTR2_2W
        ESTEMIT2_2W
        predictedWalk
        predictedStand
        predictedWave
        behave
        behaveKey
        behaveKey2
        behaveKey_2W
        behaveKey2_2W
        report
        scoreWalk
        scoreStand
        scoreWave
        reportName
        reportnum
        label
        newWalkRun
        walkJump
        walkFall
        standRun
        standJump
        standFall
        waveRun
        waveJump
        waveFall
        st23predictnoConfidence
        WavLeftR
        WavLeftF
        WavLeftJ
        stateList
        stateList2
        stateList_2W 
        stateList2_2W
    end
    methods
        function obj = personClass2(i,ESTTR,ESTEMIT,ESTTR2,ESTEMIT2,ESTTR_2W,ESTEMIT_2W,ESTTR2_2W,ESTEMIT2_2W)
            obj.ID = i;
            obj.last3 = [];
            obj.last3Names = [];
            obj.stateList = [];
            obj.stateList2 = [];
            obj.stateList_2W = [];
            obj.stateList2_2W = [];
            obj.ESTTR = ESTTR;
            obj.ESTEMIT = ESTEMIT;
            obj.ESTTR2 = ESTTR2;
            obj.ESTEMIT2 = ESTEMIT2;
            obj.ESTTR_2W = ESTTR_2W;
            obj.ESTEMIT_2W = ESTEMIT_2W;
            obj.ESTTR2_2W = ESTTR2_2W;
            obj.ESTEMIT2_2W = ESTEMIT2_2W;
            obj.scoreWalk = [];
            obj.scoreStand = [];
            obj.scoreWave = [];
            load('newWalkRun.mat')
            load('walkJump.mat')
            load('walkFall.mat')
            load('standRun.mat')
            load('standJump.mat')
            load('standFall.mat')
            load('waveRun.mat')
            load('waveJump.mat')
            load('waveFall.mat')
            load('WavLeftR.mat')
            load('WavLeftF.mat')
            load('WavLeftJ.mat')
            %load('st23SVM.mat')
            load('st23predictnoConfidence.mat')
            obj.newWalkRun = newWalkRun;
            obj.walkJump = walkJump;
            obj.walkFall = walkFall;
            obj.standRun = standRun;
            obj.standJump = standJump;
            obj.standFall = standFall;
            obj.waveRun = waveRun;
            obj.waveJump = waveJump;
            obj.waveFall = waveFall;
            obj.st23predictnoConfidence = st23predictnoConfidence;
            obj.WavLeftR = WavLeftR;
            obj.WavLeftF = WavLeftF;
            obj.WavLeftJ = WavLeftJ;
        end
        function getBehavior(obj,ThisJWC)
            obj.JWC_V = ThisJWC;
            modelType = obj.walkJump.ClassificationEnsemble;
            [predictedWalkA,scoreWalkA] = predict(modelType, obj.JWC_V);
            modelType = obj.walkFall.ClassificationEnsemble;
            [predictedWalkB,scoreWalkB] = predict(modelType, obj.JWC_V);
            modelType = obj.newWalkRun.ClassificationEnsemble;
            [predictedWalkC,scoreWalkC] = predict(modelType, obj.JWC_V);
            obj.predictedWalk = [predictedWalkA(end),predictedWalkB(end),predictedWalkC(end)];
            obj.scoreWalk = [obj.scoreWalk;[scoreWalkA(end),scoreWalkB(end),scoreWalkC(end)]];
            
            
            modelType = obj.standJump.ClassificationEnsemble;
            [predictedStandA,scoreStandA] = predict(modelType, obj.JWC_V);
            modelType = obj.standFall.ClassificationEnsemble;
            [predictedStandB,scoreStandB] = predict(modelType, obj.JWC_V);
            modelType = obj.standRun.ClassificationEnsemble;
            [predictedStandC,scoreStandC] = predict(modelType, obj.JWC_V);
            obj.predictedStand = [predictedStandA(end),predictedStandB(end),predictedStandC(end)];
            obj.scoreStand = [obj.scoreStand;[scoreStandA(end),scoreStandB(end),scoreStandC(end)]];
            
            
            modelType = obj.waveJump.ClassificationEnsemble;
            [predictedWaveA,scoreWaveA] = predict(modelType, obj.JWC_V);
            modelType = obj.waveFall.ClassificationEnsemble;
            [predictedWaveB,scoreWaveB] = predict(modelType, obj.JWC_V);
            modelType = obj.waveRun.ClassificationKNN;
            [predictedWaveC,scoreWaveC] = predict(modelType, obj.JWC_V);
            obj.predictedWave = [predictedWaveA(end),predictedWaveB(end),predictedWaveC(end)];
            obj.scoreWave = [obj.scoreWave;[scoreWaveA,scoreWaveB,scoreWaveC]];
            
            modelType = obj.WavLeftR.ClassificationEnsemble;
            [predictedWaveD,scoreWaveD] = predict(modelType, obj.JWC_V);
            modelType = obj.WavLeftF.ClassificationKNN;
            [predictedWaveE,scoreWaveE] = predict(modelType, obj.JWC_V);
            modelType = obj.WavLeftJ.ClassificationSVM;
            [predictedWaveF,scoreWaveF] = predict(modelType, obj.JWC_V);
            
            if(((strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveB,'Wave'))...
                       || (strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveC,'Wave'))...
                       || (strcmp(predictedWaveB,'Wave')&&strcmp(predictedWaveC,'Wave')))...
                       || ((strcmp(predictedWaveD,'Wave')&&strcmp(predictedWaveE,'Wave'))...
                       || (strcmp(predictedWaveD,'Wave')&&strcmp(predictedWaveF,'Wave'))...
                       || (strcmp(predictedWaveE,'Wave')&&strcmp(predictedWaveF,'Wave'))))
                   obj.behave = 'Wave';
                   obj.behaveKey = 1;
                   obj.behaveKey2 = 1;
                   obj.behaveKey_2W = 1;
                   obj.behaveKey2_2W = 1;
               elseif ((strcmp(predictedStandA,'Stand')&&strcmp(predictedStandB,'Stand'))...
                       || (strcmp(predictedStandA,'Stand')&&strcmp(predictedStandC,'Stand'))...
                       || (strcmp(predictedStandB,'Stand')&&strcmp(predictedStandC,'Stand')))
                        obj.behave = 'Stand';
                        obj.behaveKey = 3;
                        obj.behaveKey2 = 1;
                        obj.behaveKey_2W = 3;
                        obj.behaveKey2_2W = 1;
               else
                        obj.behave = 'Abnormal';
                        obj.behaveKey = 4;
                        obj.behaveKey2 = 3;
                        obj.behaveKey_2W = 4;
                        obj.behaveKey2_2W = 3;
               end
               
               if strcmp(obj.behave,'Abnormal')
                   if ((strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkB,'Walk'))...
                           || (strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkC,'Walk'))...
                           || (strcmp(predictedWalkB,'Walk')&&strcmp(predictedWalkC,'Walk')))
                       obj.behave = 'Walk';
                       obj.behaveKey_2W = 2;
                       obj.behaveKey2_2W = 2;
                   end
                   if (strcmp(predictedWalkA,'Walk')||strcmp(predictedWalkB,'Walk')...
                           ||strcmp(predictedWalkC,'Walk'))
                   %    obj.behave = 'Walk';
                       obj.behaveKey = 2;
                       obj.behaveKey2 = 2;
                   end
               end
                
               obj.stateList = [obj.stateList;obj.behaveKey];
               obj.stateList2 = [obj.stateList2;obj.behaveKey2];
               obj.stateList_2W = [obj.stateList_2W;obj.behaveKey_2W];
               obj.stateList2_2W = [obj.stateList2_2W;obj.behaveKey2_2W];
            
            display('Adding hmm')
            if (length(obj.stateList)> 4)
                obj.STATES = hmmviterbi(transpose(obj.stateList(end-4:end,1)),obj.ESTTR,obj.ESTEMIT);
                obj.STATES2 = hmmviterbi(transpose(obj.stateList2(end-4:end,1)),obj.ESTTR2,obj.ESTEMIT2);
                obj.STATES_2W = hmmviterbi(transpose(obj.stateList_2W(end-4:end,1)),obj.ESTTR_2W,obj.ESTEMIT_2W);
                obj.STATES2_2W = hmmviterbi(transpose(obj.stateList2_2W(end-4:end,1)),obj.ESTTR2_2W,obj.ESTEMIT2_2W);
                %obj.label = strcat(char(num2str(obj.stateList(end-4:end,1))),char(num2str(obj.stateList_2W(end-4:end,1))),char(num2str(obj.stateList2(end-4:end,1))),char(num2str(obj.stateList2_2W(end-4:end,1))));%,char(obj.reportName)); %cell?

            else
                obj.STATES = hmmviterbi(transpose(obj.stateList),obj.ESTTR,obj.ESTEMIT);
                obj.STATES2 = hmmviterbi(transpose(obj.stateList2),obj.ESTTR2,obj.ESTEMIT2);
                obj.STATES_2W = hmmviterbi(transpose(obj.stateList_2W),obj.ESTTR_2W,obj.ESTEMIT_2W);
                obj.STATES2_2W = hmmviterbi(transpose(obj.stateList2_2W),obj.ESTTR2_2W,obj.ESTEMIT2_2W);
                %obj.label = strcat(char(num2str(obj.stateList)),char(num2str(obj.stateList_2W)),char(num2str(obj.stateList2)),char(num2str(obj.stateList2_2W)));%,char(obj.reportName)); %cell?

            end
            if (ismember(2,obj.STATES_2W))
                if (ismember(2,obj.STATES))
                    obj.reportName = 'Abnormal';
                    obj.reportnum = 2;
                elseif (sum(obj.STATES_2W)>7)%sequence!!!!
                    obj.reportName = 'Abnormal';
                    obj.reportnum = 2;  
                else
                    obj.reportName = 'Normal';
                    obj.reportnum = 1;
                end  
            else
                obj.reportName = 'Normal';
                obj.reportnum = 1;
            end
      
            %obj.label = char(obj.reportName);
            obj.label = strcat(char(num2str(transpose(obj.STATES))),char(num2str(transpose(obj.STATES_2W))),char(num2str(transpose(obj.STATES2))),char(num2str(transpose(obj.STATES2_2W))),char(obj.reportName)); %cell?
            %obj.label = strcat(char(num2str(obj.stateList(end-4:end,1))),char(num2str(obj.stateList_2W(end-4:end,1))),char(num2str(obj.stateList2(end-4:end,1))),char(num2str(obj.stateList2_2W(end-4:end,1))));%,char(obj.reportName)); %cell?
            %obj.label = char(obj.label);

            
        end
    end
end