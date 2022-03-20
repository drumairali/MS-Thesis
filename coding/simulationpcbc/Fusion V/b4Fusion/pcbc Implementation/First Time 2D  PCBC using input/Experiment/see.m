 
load("data/compassData.mat");
load("data/odometryData.mat");
load("data/usblData.mat");
load("data/dgpsData.mat");

 
 plot(dgpsData(:,2),dgpsData(:,3))
 hold on
 scatter(usblData(:,2),usblData(:,3))
 hold off