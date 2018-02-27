function [data] = catFile(filename, catStr)
    A = csvread(filename);
    A = array2table(A);
    x = [];
    for i = 1:height(A)
        x = [x;A(i,:),{catStr}];  
    end
    data = x;
end
