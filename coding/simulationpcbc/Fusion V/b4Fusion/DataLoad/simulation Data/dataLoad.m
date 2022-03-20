load 'usblData.mat'
load 'dgpsData.mat'
load 'gtData.mat'
load 'imuData.mat'
load 'dvlData.mat'
load 'altimeterData.mat'
temp =[]
tempd=[]
x2=usblData(1,2:4)+imuData(1,2:4)
x1=dvlData(1,2:4)
for i = 1:6301
    temp = [temp; x2];
  x2 = x2 + (imuData(i,2:4) );
endfor

for i = 1:6301
    tempd = [tempd; x1];
  x1 = x1 + (dvlData(i,2:4) );
endfor
plot3(temp(:,1),temp(:,2),temp(:,3))
hold on
plot3(gtData(:,2),gtData(:,3),gtData(:,4))
figure
plot3(tempd(:,1),tempd(:,2),tempd(:,3))
hold off