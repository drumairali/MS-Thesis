  clear all
clc
# data load
load("data/compassData.mat");
load("data/odometryData.mat");
load("data/usblData.mat");
load("data/dgpsData.mat");

#setting same range and centers for both sensors
range=[-80:5:80]; # -14 to 14 
centers=[-80:5:80];

#initialize some parameters for PC/BC-DIM
sigmaUSBL=10;

[W,V] = getWV(range,centers,sigmaUSBL);
[n,m]=size(W)
yX=zeros(n,1);
yY=zeros(n,1);

#Collection of each sensor at its proper time and numbering
iUsbl=1; 
tUsbl=usblData(1,1);     #initial time of usbl 
t=usblData(1,1)
globalTraj=[];
 fprintf('program is processing...')
tic
for val=1:length(usblData)-1 # till last value of 19991 value of Odometry

if tUsbl<=t && iUsbl<length(usblData) 
  UsblX = G1D(range,usblData(iUsbl,2),sigmaUSBL); 
  UsblY = G1D(range,usblData(iUsbl,3),sigmaUSBL); 
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  UsblX=zeros(1,m);
  UsblY=zeros(1,m);
endif
xX = [UsblX]';
xY = [UsblY]';
[rX,yX]=getRecons(xX,W,V,yX);
[rY,yY]=getRecons(xY,W,V,yY);
decodPosX = decode(rX(1:length(range),1)',range); # Position
decodPosY = decode(rY(1:length(range),1)',range); # Position
  
globalTraj=[globalTraj;t decodPosX decodPosY];

t=usblData(iUsbl,1); # next data rate value in t

end       
toc

# here code ends remaining is ploting and error











#plot globalTraj
figure
hold on
plot(globalTraj(:,2),globalTraj(:,3))
plot(dgpsData(:,2),dgpsData(:,3))
hold off

# Find the error of pcbc 
allpcbc=globalTraj;
times=dgpsData(:,1);
errorpcbc = [];
for i = 1 : length(globalTraj)
t = allpcbc(i,1);
[m ix] = min(abs(times.-t));
errorpcbc = [errorpcbc; [dgpsData(ix,:) allpcbc(i,:)]];
endfor
errorpcbc(:,7) = (((errorpcbc(:,2)-errorpcbc(:,5)).^2 + (errorpcbc(:,3)-errorpcbc(:,6)).^2)/2).^0.5;
meanTraj=mean(errorpcbc(:,7))
stdDevTraj=std(errorpcbc(:,7))