function y  = label4Stage2b(thisData, predictions)

    p = cell2table(predictions);
%     p = table2array(predictedStand);
%     A = VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60);
    A = thisData;
    x = array2table(A);
    y = [x, p];
    y.Properties.VariableNames(1,61) = {'Var63'};
    y.Properties.VariableNames(1,62) = {'Var64'};
    y.Properties.VariableNames(1,63) = {'Var65'};
    y.Properties.VariableNames(1,64) = {'Var66'};
    y.Properties.VariableNames(1,65) = {'Var67'};
    y.Properties.VariableNames(1,66) = {'Var68'};

end

