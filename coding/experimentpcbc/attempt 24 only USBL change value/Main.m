clear all
clc
# data load
load("data/usblData.mat");
load("data/dgpsData.mat");

#setting same range and centers for both sensors
range=[-14:1:14]; # -14 to 14 
centers=[-14:1:14];

#initialize some parameters for PC/BC-DIM
sigmaUSBL=1;

[W,V] = getWV(range,centers,sigmaUSBL);
[n,m]=size(W)
yX=zeros(n,1);
yY=zeros(n,1);
tUsbl=usblData(1,1);     #initial time of usbl 
t=tUsbl
iUsbl=1;
tempSavPosX=0;
tempSavPosY=0; # this is accomulated position before saving to globalTraj
lastUsblX=0;
lastUsblY=0; 
globalTraj=[];
decodPosX=0;
decodPosY=0;
 fprintf('program is processing...')
tic
for val=1:length(usblData)-1 # till last value of 19991 value of Odometry

if tUsbl<=t && iUsbl<length(usblData) 
  UsblX = G1D(range,usblData(iUsbl,2)-lastUsblX,sigmaUSBL); 
  UsblY = G1D(range,usblData(iUsbl,3)-lastUsblY,sigmaUSBL); 
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
endif


xX = [UsblX]';
xY = [UsblY]';
[rX,yX]=getRecons(xX,W,V,yX);
[rY,yY]=getRecons(xY,W,V,yY);
decodPosX = decode(rX(1:length(range),1)',range); # Position
decodPosY = decode(rY(1:length(range),1)',range); # Position

if sum(UsblX)>0.001  # when usbl comes reset odometry accomulation to zero
 tempSavPosX+=decodPosX;
  lastUsblX=tempSavPosX;   
  decodPosX = 0; 
endif
if sum(UsblY)>0.001  # when usbl comes reset odometry accomulation to zero
  tempSavPosY+=decodPosY;
  lastUsblY=tempSavPosY;   
  decodPosY = 0; 
  
globalTraj=[globalTraj;t tempSavPosX+decodPosX tempSavPosY+decodPosY];
endif
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