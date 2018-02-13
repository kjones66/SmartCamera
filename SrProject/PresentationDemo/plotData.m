function [] = plotData(skeletonJoints,numberOfPeople,allPlaces)
       allLabels = [];
       lineOptions = [{':o'}, {':go'},{':ko'}, {':ro'}, {':po'}, {':yo'}];
       hold on;
       for i = 1:numberOfPeople
           plot(skeletonJoints(:,1,i),skeletonJoints(:,2,i),'*');
       end
       hold off;
       allPlaces = char(allPlaces)
       %legend(allPlaces);
end

