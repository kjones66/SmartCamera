% load data
name = table2array(jwcstandingposition(1:200,1:60));
x = zeros(200,20);
y = zeros(200,20);
z = zeros(200,20);
% joint = [x y z];
% joints = [];
i = 1;
j = 1;
while  j < 60 
     x(:,i) = name(:,j);
     y(:,i) = name(:,j+1);
     z(:,i) = name(:,j+2);
     j = j+3;
     i = i + 1;
end

% for i = 1:3:rows(name)
%     
% end
currentLabel = [];
hold on
for i = 1:20
   scatter3(x(i,:),y(i,:),z(i,:))
   currentLabel = [currentLabel ; "Joint " + num2str(i)]; 
end
xlabel('x')
ylabel('y')
zlabel('z')
title('Position Data')
legend(currentLabel)
