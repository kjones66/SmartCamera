function [data] = LabelData(filename, catStr1, catStr2)
    A = csvread(filename);
    A = array2table(A);
    x = [];
    for i = 1:height(A)
        x = [x;A(i,:),{catStr1},{catStr2}];  
    end
    data = x;
end