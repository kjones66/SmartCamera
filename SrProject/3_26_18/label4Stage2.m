function y  = label4Stage2(thisData, predictedStand)

    p = cell2table(predictedStand);
%     p = table2array(predictedStand);
%     A = VelocityDiffJWC(1,(person(i)-1)*60+1:person(i)*60);
    A = thisData;
    x = array2table(A);
    y = [x, p];
    y.Properties.VariableNames(1,61) = {'Var63'};
    y.Properties.VariableNames(1,62) = {'Var64'};
    y.Properties.VariableNames(1,63) = {'Var65'};

end

