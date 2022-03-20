  clear all
clc
# data load
load("data/compassData.mat");
load("data/usblData.mat");
load("data/dgpsData.mat");
load("data/odometryData.mat");
load("data/filterDeadReckoning.mat");
source("filterDeadReckoning.m");

# deadreckoning means odometryData in accumulated format
#odometryData=[allDeadReckoning(1:end-1,1) allDeadReckoning(2:end,2)-allDeadReckoning(1:end-1,2) allDeadReckoning(2:end,3)-allDeadReckoning(1:end-1,3)];
#setting same range and centers for both sensors
range=[-14:1:14]; # -14 to 14 
centers=[-14:1:14];

#initialize some parameters for PC/BC-DIM
sigmaOdom=3.5; 
sigmaUSBL=0.5;

priorMean=0;
priorStd=5;
priorDist=G1D([range],priorMean,priorStd);

[W,V] = getWV(range,centers,sigmaOdom,sigmaUSBL,priorDist);
[n,m]=size(W)
yX=zeros(n,1);
yY=zeros(n,1);

#Collection of each sensor at its proper time and numbering
iOdom=1; #value number of Odom measurement
iUsbl=1; 
iCompass=1;
tCompass=compassData(iCompass,1);
thetaIni = compassData(iCompass,2);

tOdom=odometryData(1,1); #initial time of tOdom
tUsbl=usblData(1,1);     #initial time of usbl 
t=tOdom
tempSavPosX=0;
tempSavPosY=0; # this is accomulated position before saving to globalTraj
lastUsblX=0;
lastUsblY=0; 
globalTraj=[];
decodPosX=0;
decodPosY=0;
 fprintf('program is processing...')
tic
for val=1:length(odometryData)-1 # till last value of 19991 value of Odometry
if (tCompass <= t)&&(iCompass < length(compassData))
    
  measurement = wrapTo2Pi(compassData(iCompass,2)-thetaIni);    

  filterReadCompass([tCompass measurement]);
      
  iCompass = iCompass + 1;        
  tCompass = compassData(iCompass, 1);

  endif

if tOdom<=t && iOdom<length(odometryData) # curr
  #sir here i used those values are odom which comes by mutiplying with angle etc
  measurement = odometryData(iOdom,:);    
  currentOdomXY=filterReadOdometry(measurement);   
  currentOdomX=currentOdomXY(1);
  currentOdomY=currentOdomXY(2);
  gXOdom = decodPosX+currentOdomX;
  gYOdom = decodPosY+currentOdomY ;
  OdomX = G1D(range,gXOdom,sigmaOdom); 
  OdomY = G1D(range,gYOdom,sigmaOdom); 
  tOdom=odometryData(iOdom+1,1);
  iOdom=iOdom+1;
  
else 
  OdomX = zeros(1,m/2);
  OdomY = zeros(1,m/2);
endif

if tUsbl<=t && iUsbl<length(usblData) 
  UsblX = G1D(range,usblData(iUsbl,2)-lastUsblX,sigmaUSBL); 
  UsblY = G1D(range,usblData(iUsbl,3)-lastUsblY,sigmaUSBL); 
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  UsblX=zeros(1,m/2);
  UsblY=zeros(1,m/2);
endif

  xX = [OdomX UsblX]';
  xY = [OdomY UsblY]';
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
endif

globalTraj=[globalTraj;t tempSavPosX+decodPosX tempSavPosY+decodPosY];
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