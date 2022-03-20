
Ximu=zeros(6301,4)
temp=usblData(1,2);

for i =1:6301
X = imuData(i,2);
temp = temp +X;
Ximu(i,2) = [temp];
end

temp=usblData(1,3);
for i =1:6301
X = imuData(i,3);
temp = temp +X;
Ximu(i,3) = [temp];
end

temp=usblData(1,4);
for i =1:6301
X = imuData(i,4);
temp = temp +X;
Ximu(i,4) = [temp];
end

for i =1:6301
Ximu(i,1)  = imuData(i,1);


end





figure(2)
 plot(Ximu(1:end,2),Ximu(1:end,3),'-')
 hold on
 
 
 
 
 
 
 
 

 