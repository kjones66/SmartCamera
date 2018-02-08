function [VelocityDiff,oldData] = logAllData(d,numberOfPeople,person,oldData,JDI,JII,JTS,JWC,PDI,PII,PWC,SD,firstLoop)
        % Log data
        dataLine = [d.AbsTime,d.FrameNumber,...
            d.IsPositionTracked,d.IsSkeletonTracked,...
            JDI,JII,JTS,JWC,PDI,PII,PWC,d.RelativeFrame,... %Add Segmentation Data
            d.SkeletonTrackingID,d.TriggerIndex];
        fid = fopen('test.csv', 'w') ;
        filename = sprintf('%d_%d_%d.csv',d.AbsTime(2),d.AbsTime(3),d.AbsTime(1));
        dlmwrite(fullfile('C:\Users\aweber13\Desktop',filename),dataLine,'-append','delimiter',',')
        %dlmwrite(fullfile('T:\Kinect Data',filename),dataLine,'-append','delimiter',',')
        fclose(fid)
        
        
        if (numberOfPeople > 1)
            
            dataDist = [];
            for i = 1:numberOfPeople
                line = [];
                for j = (i+1):numberOfPeople
                    % xyz difference between two people's (hip center,
                    % spine, shoulder center)
                    line = [line, JWC((person(i)-1)*60+1:person(i)*60-51)-JWC((person(j)-1)*60+1:person(j)*60-51)];
                    fid = fopen('test.csv', 'w') ;
                    filename = sprintf('%d_%d_%dIndivDistances.csv',d.AbsTime(2),d.AbsTime(3),d.AbsTime(1));
                    dlmwrite(fullfile('C:\Users\aweber13\Desktop',filename),line,'-append','delimiter',',')
                end
                dataDist = [dataDist,line]
            end
            fclose(fid)
            fid = fopen('test.csv', 'w') ;
            filename = sprintf('%d_%d_%dAllDistances.csv',d.AbsTime(2),d.AbsTime(3),d.AbsTime(1));
            dlmwrite(fullfile('C:\Users\aweber13\Desktop',filename),dataDist,'-append','delimiter',',')
            fclose(fid)
        end
        
        if (firstLoop == 0)
            VelocityDiff = dataLine - oldData;
            fid = fopen('test.csv', 'w') ;
            filename = sprintf('%d_%d_%d_Velocity.csv',d.AbsTime(2),d.AbsTime(3),d.AbsTime(1));
           % dlmwrite(fullfile('C:\Users\aweber13\Desktop',filename),dataLine,'-append','delimiter',',')
            %dlmwrite(fullfile('T:\Kinect Data',filename),VelocityDiff,'-append','delimiter',',');
            fclose(fid);
        else 
            VelocityDiff = [];
        end
        oldData = dataLine;
end

