function [VelocityDiff,oldData] = logAllData(d,oldData,JDI,JII,JTS,JWC,PDI,PII,PWC,SD,firstLoop)
        % Log data
        dataLine = [d.AbsTime,d.FrameNumber,...
            d.IsPositionTracked,d.IsSkeletonTracked,...
            JDI,JII,JTS,JWC,PDI,PII,PWC,d.RelativeFrame,... %Add Segmentation Data
            d.SkeletonTrackingID,d.TriggerIndex];
        fid = fopen('test.csv', 'w') ;
        filename = sprintf('%d_%d_%d.csv',d.AbsTime(2),d.AbsTime(3),d.AbsTime(1));
        dlmwrite(fullfile('T:\Kinect Data',filename),dataLine,'-append','delimiter',',')
        fclose(fid)
        
        if (firstLoop == 0)
            VelocityDiff = dataLine - oldData;
            fid = fopen('test.csv', 'w') ;
            filename = sprintf('%d_%d_%d_Velocity.csv',d.AbsTime(2),d.AbsTime(3),d.AbsTime(1));
            dlmwrite(fullfile('T:\Kinect Data',filename),VelocityDiff,'-append','delimiter',',');
            fclose(fid);
        else 
            VelocityDiff = [];
        end
        oldData = dataLine;
end

