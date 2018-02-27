function [JDI,JII,JTS,JWC,PDI,PII,PWC,SD] = transformData (d)
    JDI = [];
    JII = [];
    JTS = [];
    JWC = [];
    PDI = [];
    PII = [];
    PWC = [];
    SD = [];
    for i = 1:6
        JDI = [JDI, daTr20by2(d.JointDepthIndices(:,:,i))];
        JII = [JII, daTr20by2(d.JointImageIndices(:,:,i))];
        for j = 1:20
            JWC = [JWC, d.JointWorldCoordinates(j,:,i)];
        end
        PDI = [PDI,d.PositionDepthIndices(1,i),d.PositionDepthIndices(2,i)];
        PII = [PII,d.PositionImageIndices(1,i),d.PositionImageIndices(2,i)];
        PWC = [PWC,d.PositionWorldCoordinates(1,i),...
            d.PositionWorldCoordinates(2,i),d.PositionWorldCoordinates(3,i)];
    end
    for i = 1:20
        JTS = [JTS, d.JointTrackingState(i,:)];
    end
end
