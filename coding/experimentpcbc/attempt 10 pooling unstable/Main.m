clear all
clc
# data load
load("data/compassData.mat");
load("data/odometryData.mat");
load("data/usblData.mat");
load("data/dgpsData.mat");

#setting same range and centers for both sensors
rangeUsbl=[-80:8:80];
centersUsbl=[-80:16:80];

rangeOdom=[-1:0.1:1];
centersOdom=[-1:0.2:1];

#initialize some parameters for PC/BC-DIM
sigmaOdom=5; 
sigmaUSBL=1;
[W,V] = getWV(rangeUsbl,centersUsbl,sigmaUSBL,rangeOdom,centersOdom,sigmaOdom);# eye added
[n,m]=size(W)
yX=zeros(n,1);
yY=zeros(n,1);

#Collection of each sensor at its proper time and numbering
iOdom=1; #value number of Odom measurement
iUsbl=1; 
t=usblData(1,1); #starting time 
tOdom=odometryData(1,1); #initial time of tOdom
tUsbl=usblData(1,1);     #initial time of usbl 
globalTraj=[];
fprintf('program is processing...')
tic
for val=1:length(odometryData) # till last value of 19991 value of Odometry
  
if tOdom<=t && iOdom<length(odometryData) # curr
  xOdom = odometryData(iOdom,2); 
  yOdom = odometryData(iOdom,3); 
  OdomX = G1D(rangeOdom,xOdom,sigmaOdom); 
  OdomY = G1D(rangeOdom,yOdom,sigmaOdom); 
  tOdom=odometryData(iOdom+1,1);
  iOdom=iOdom+1;
else 
  OdomX = zeros(1,length(rangeOdom));
  OdomY = zeros(1,length(rangeOdom));
endif

if tUsbl<=t && iUsbl<length(usblData) 
  UsblX = G1D(rangeUsbl,usblData(iUsbl,2),sigmaUSBL); 
  UsblY = G1D(rangeUsbl,usblData(iUsbl,3),sigmaUSBL); 
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  UsblX=zeros(1,length(rangeUsbl));
  UsblY=zeros(1,length(rangeUsbl));
endif
xX = [UsblX OdomX zeros(1,length(centersUsbl))]'; # as the both centers are same
xY = [UsblY OdomY zeros(1,length(centersUsbl))]';
[rX,yX]=getRecons(xX,W,V,yX);
[rY,yY]=getRecons(xY,W,V,yY);
decodPosX = decode(rX(1+length(rX)-length(centersUsbl):end,1)',centersUsbl); # only from 
decodPosY = decode(rX(1+length(rY)-length(centersUsbl):end,1)',centersUsbl); # Position

globalTraj=[globalTraj;t decodPosX decodPosY];
t=odometryData(iOdom,1); # next data rate value in t
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