load 'usblData.mat'
load 'dgpsData.mat'
load 'gtData.mat'
load 'imuData.mat'
load 'dvlData.mat'
load 'altimeterData.mat'


altiData = zeros(1490,3);
altiData(:,3) = altimeterData(:,2);
my_Imu = imuData(:,2:4)+gtData(:,2:4); 
my_dvl = dvlData(:,2:4)+gtData(:,2:4);


hold on

scatter3(dgpsData(:,2),dgpsData(:,3),dgpsData(:,4))
scatter3(usblData(:,2),usblData(:,3),usblData(:,4))


scatter3(gtData(:,2),gtData(:,3),gtData(:,4))
scatter3(altiData(:,1),altiData(:,2),altiData(:,3))

scatter3(my_Imu(:,1),my_Imu(:,2),my_Imu(:,3))
scatter3(my_Dvl(:,1),my_(:,2),my_Imu(:,3))


hold off