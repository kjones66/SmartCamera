classdef personClass < handle
    properties
        JWC_V
        last3
        last3Names
        last3_2
        last3Names
        STATES
        STATES2
        ID
        ESTTR
        ESTEMIT
        ESTTR2
        ESTEMIT2
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
    end
    methods
        function obj = personClass(i,ESTTR,ESTEMIT,ESTTR2,ESTEMIT2)
            obj.ID = i;
            obj.last3 = [];
            obj.last3Names = [];
            obj.ESTTR = ESTTR;
            obj.ESTEMIT = ESTEMIT;
            obj.ESTTR2 = ESTTR2;
            obj.ESTEMIT2 = ESTEMIT2;
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
            [predictedWaveD,scoreWaveD] = predict(modelType, thisJWC);
            modelType = obj.WavLeftF.ClassificationKNN;
            [predictedWaveE,scoreWaveE] = predict(modelType, thisJWC);
            modelType = obj.WavLeftJ.ClassificationSVM;
            [predictedWaveF,scoreWaveF] = predict(modelType, thisJWC);
            
             if ((strcmp(predictedStandA,'Stand')&&strcmp(predictedStandB,'Stand'))...
                       || (strcmp(predictedStandA,'Stand')&&strcmp(predictedStandC,'Stand'))...
                       || (strcmp(predictedStandB,'Stand')&&strcmp(predictedStandC,'Stand')))
                   obj.behave = 'Stand';
                   obj.behaveKey = 3;
                   obj.behaveKey2 = 1;
             elseif(((strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveB,'Wave'))...
                       || (strcmp(predictedWaveA,'Wave')&&strcmp(predictedWaveC,'Wave'))...
                       || (strcmp(predictedWaveB,'Wave')&&strcmp(predictedWaveC,'Wave')))...
                       || ((strcmp(predictedWaveD,'Wave')&&strcmp(predictedWaveE,'Wave'))...
                       || (strcmp(predictedWaveD,'Wave')&&strcmp(predictedWaveF,'Wave'))...
                       || (strcmp(predictedWaveE,'Wave')&&strcmp(predictedWaveF,'Wave'))))      
                 obj.behave = 'Wave';
                 obj.behaveKey = 1;
                 obj.behaveKey2 = 1;  
            elseif ((strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkB,'Walk'))...
                       || (strcmp(predictedWalkA,'Walk')&&strcmp(predictedWalkC,'Walk'))...
                       || (strcmp(predictedWalkB,'Walk')&&strcmp(predictedWalkC,'Walk')))
                obj.behave = 'Walk';
                obj.behaveKey = 2;
                obj.behaveKey = 2;
            else
                obj.behave = 'Abnormal';
                obj.behaveKey = 4;
                obj.behaveKey2 = 3;
             end
            
            
            display('Adding hmm')
            if (length(obj.last3)< 1)
                obj.last3 = [obj.behaveKey];
                obj.STATES = hmmviterbi(obj.last3,obj.ESTTR,obj.ESTEMIT);
                obj.last3_2 = [obj.behaveKey2];
                obj.STATES2 = hmmviterbi(obj.last3,obj.ESTTR2,obj.ESTEMIT2);
            elseif (length(obj.last3)< 3)
                obj.last3(1,(length(obj.last3)+1)) = [obj.behaveKey];
                obj.last3_2(1,(length(obj.last3_2)+1)) = [obj.behaveKey2];
                obj.STATES = hmmviterbi(obj.last3,obj.ESTTR,obj.ESTEMIT);
                obj.STATES2 = hmmviterbi(obj.last3,obj.ESTTR2,obj.ESTEMIT2);
            else
                obj.last3 = [obj.last
                    
                3(1,2:3),obj.behaveKey];
                obj.STATES = hmmviterbi(obj.last3,obj.ESTTR,obj.ESTEMIT);
                obj.last3_2 = [obj.last3_2(1,2:3),obj.behaveKey2];
                obj.STATES2 = hmmviterbi(obj.last3,obj.ESTTR2,obj.ESTEMIT2);
            end
%             if (ismember(2,obj.STATES_anyW))
%                 if (ismember(2,obj.STATES))
%                     obj.reportName = 'Abnormal';
%                     obj.reportnum = 2;
%                 end
%             else
%                 obj.reportName = 'Normal';
%                 obj.reportnum = 1;
%             end
            if (ismember(2,obj.STATES))
                if (ismember(2,obj.STATES2))
                    obj.reportName = 'Abnormal';
                    obj.reportnum = 2;
                end
            else
                obj.reportName = 'Normal';
                obj.reportnum = 1;
            end

            obj.label = char(obj.reportName);
            %obj.label = strcat(char(obj.last3),char(num2str(obj.STATES)),char(num2str(obj.STATES_anyW)),char(obj.reportName)); %cell?
            %obj.label = char(obj.label);

            
        end
    end
end