
fid = fopen('test.csv', 'w') ;
sprintf('Data2.csv');
d = depthMetaData;
[JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d);

dlmwrite('Data2.csv',[d.AbsTime,d.FrameNumber,...
    d.IsPositionTracked,d.IsSkeletonTracked,...
    JDI,JII,JWC,PDI,PII,PWC,d.RelativeFrame,... %Add Segmentation Data
    d.SkeletonTrackingID,d.TriggerIndex],'-append','delimiter',',')
fclose(fid)
