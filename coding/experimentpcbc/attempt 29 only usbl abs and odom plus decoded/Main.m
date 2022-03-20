  clear all
clc
# data load
load("data/compassData.mat");
load("data/odometryData.mat");
load("data/usblData.mat");
load("data/dgpsData.mat");

#setting same rangeUsbl and centersUsbl for both sensors
rangeUsbl=[-80:5:80]; 
centersUsbl=[-80:5:80];
rangeOdom=[-80:5:80];
centersOdom=[-80:5:80];

#initialize some parameters for PC/BC-DIM
sigmaUsbl=5;
sigmaOdom=5;
[W,V] = getWV(rangeUsbl,centersUsbl,sigmaUsbl,rangeOdom,centersOdom,sigmaOdom);
[n,m]=size(W)
yX=zeros(n,1);
yY=zeros(n,1);

#Collection of each sensor at its proper time and numbering
iUsbl=1; 
tUsbl=usblData(1,1);     #initial time of usbl 
iOdom=1;
tOdom=odometryData(1,1);
t=odometryData(1,1)
globalTraj=[];
 fprintf('program is processing...')
tic
decodPosX=0;
decodPosY=0;
for val=1:length(odometryData)-1 # till last value of 19991 value of Odometry

if tOdom<=t && iOdom<length(odometryData) 
  AcumOdX=decodPosX+odometryData(iOdom,2);
  AcumOdY=decodPosY+odometryData(iOdom,3);
  OdomX = G1D(rangeOdom,AcumOdX,sigmaOdom); 
  OdomY = G1D(rangeOdom,AcumOdY,sigmaOdom); 
  tOdom=odometryData(iOdom+1,1);
  iOdom=iOdom+1;
else
  OdomX=zeros(1,m/2);
  OdomY=zeros(1,m/2);
endif

if tUsbl<=t && iUsbl<length(usblData) 
  UsblX = G1D(rangeUsbl,usblData(iUsbl,2),sigmaUsbl); 
  UsblY = G1D(rangeUsbl,usblData(iUsbl,3),sigmaUsbl); 
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  UsblX=zeros(1,m/2);
  UsblY=zeros(1,m/2);
endif

xX = [UsblX OdomX]';
xY = [UsblY OdomY]';
[rX,yX]=getRecons(xX,W,V,yX);
[rY,yY]=getRecons(xY,W,V,yY);
decodPosX = decode(rX(1:length(rangeUsbl),1)',rangeUsbl); # Position
decodPosY = decode(rY(1:length(rangeUsbl),1)',rangeUsbl); # Position
  
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