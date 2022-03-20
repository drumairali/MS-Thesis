clear all
clc
# data load
load("data/compassData.mat");
load("data/odometryData.mat");
load("data/usblData.mat");
load("data/dgpsData.mat");

#setting same range and centers for both sensors
range=[-15:1:15];
centers=[-15:2:15];

#initialize some parameters for PC/BC-DIM
sigmaOdom=5; 
sigmaUSBL=1;
[W,V] = getWV(range,centers,sigmaOdom,sigmaUSBL);
[n,m]=size(W)
y=zeros(n,1);

#Collection of each sensor at its proper time and numbering
iOdom=1; #value number of Odom measurement
iUsbl=1; 
t=usblData(1,1); #starting time 
tOdom=odometryData(1,1); #initial time of tOdom
tUsbl=usblData(1,1);     #initial time of usbl 

tempSavPos=[0 0]; # this is accomulated position before saving to globalTraj
lastUsbl=[0 0]; 
globalTraj=[];
decodPos=[0 0];
fprintf('program is processing...')
tic
for val=1:length(odometryData) # till last value of 19991 value of Odometry
  
if tOdom<=t && iOdom<length(odometryData) # curr
  gXOdom = decodPos(1,1) + odometryData(iOdom,2); 
  gYOdom = decodPos(1,2) + odometryData(iOdom,3); 
  xOdom(1,:) = G1D(range,gXOdom,sigmaOdom); 
  xOdom(2,:) = G1D(range,gYOdom,sigmaOdom); 
  tOdom=odometryData(iOdom+1,1);
  iOdom=iOdom+1;
else 
  xOdom = zeros(2,m/2);
endif

if tUsbl<=t && iUsbl<length(usblData) 
  xUSBL(1,:) = G1D(range,usblData(iUsbl,2)-lastUsbl(1,1),sigmaUSBL); 
  xUSBL(2,:) = G1D(range,usblData(iUsbl,3)-lastUsbl(1,2),sigmaUSBL); 
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(2,m/2);
endif
x = [xOdom xUSBL];
x=x';

for xyLoop=1:2 # for loop for x and y axis 
[r,y]=getRecons(x,W,V,y,xyLoop);
decodPos(1,xyLoop) = decode(r(1:m/2)',range); # Position
if sum(xUSBL(xyLoop,:))>0.001  # when usbl comes reset odometry accomulation to zero
  tempSavPos(1,xyLoop)+=decodPos(1,xyLoop);
  lastUsbl(1,xyLoop)=tempSavPos(1,xyLoop);   
  decodPos(1,xyLoop) = 0; 
endif
end
globalTraj=[globalTraj;t tempSavPos+decodPos];
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