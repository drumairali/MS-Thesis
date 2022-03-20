
load "Ximu.mat"
load "imuData.mat"
load "gtData.mat"
load "usblData.mat"

figure(4)
 plot(imuData(1:100,2),'o')
figure(2) 
plot(imuData(1:100,3),'-')
figure(3)
 plot(imuData(1:100,4),'-')

hold off