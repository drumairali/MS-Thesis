#Stable version of Thesis coding
clear all
clc
###### Initialization#################################################


axis=2; %2-3 1 is time x=2,y=3

load("data/compassData.mat");
load("data/odometryData.mat");
load("data/usblData.mat");
load("data/dgpsData.mat");
load("bprf.mat")



range=[-15:1:15];
centers=[-15:2:15];
totalNCRval=length(centers)
  ##
iter=15; #iterations of PCBC
#setting Input for inertial sensor and positioning
AOdom=1;
sigmaOdom=2;
AUSBL=1;
sigmaUSBL=2;


#xUSBL = zeros(1,801); % only when no usblData
#Setting Weights
WOdom=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaOdom,AOdom);
  WOdom=[WOdom;WG1D];
endfor



WUSBL=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaUSBL,AUSBL);
  WUSBL=[WUSBL;WG1D];
endfor

#some Variable initialization gor pcbc
VUSBL=bsxfun(@rdivide,abs(WUSBL),max(1e-6,max(abs(WUSBL),[],2)));
VOdom =bsxfun(@rdivide,abs(WOdom),max(1e-6,max(abs(WOdom),[],2)));

V = [VOdom VUSBL];
V = V';
epsilon1=1e-6;
epsilon2=1e-4;

  
#concatination 
W = [WOdom WUSBL];
[n,m]=size(W)
percentNRvar=50
NRVar=round(percentNRvar*totalNCRval/200)
y=zeros(length(round(length(V(1,:))/2-NRVar:length(V(1,:))/2+NRVar)),1);

#######################Filter Processing##########################


#MainFile2iOdom=1;
iOdom=1;
iUsbl=1; % b/qs i starts from 2
t=usblData(1,1);
tOdom=odometryData(1,1);
tUsbl=usblData(1,1);

gOdom=0;
globalTrajvar=0;
lastDGPS=lastUsbl=0; %reference Point
globalTraj=[];


##### for values of sensors
tic
for val=1:length(odometryData) % highest rate
 
if tOdom<=t && iOdom<length(odometryData)
  gOdom = gOdom + odometryData(iOdom,axis); % convert change into global
  xOdom = G1D(range,gOdom,sigmaOdom,AOdom); 
  tOdom=odometryData(iOdom+1,1);
  iOdom=iOdom+1;
else 
  xOdom = zeros(1,m/2);

endif
  

if tUsbl<=t && iUsbl<length(usblData) % as we are taking change so total-1
  xUSBL = G1D(range,usblData(iUsbl,axis)-lastUsbl,sigmaUSBL,AUSBL); % Already a change
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(1,m/2);
endif




x = [xOdom xUSBL];
x=x';


#PCBC-DIM

#PCBC-DIM
for i=1:iter
r=V(:,round(length(V(1,:))/2-NRVar:length(V(1,:))/2+NRVar))*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W(round(length(V(1,:))/2-NRVar:length(V(1,:))/2+NRVar),:)*e);
endfor
#Decoding
comingVal = decode((r(1:round(length(r)/2)))',range);


if sum(xUSBL)>0.001  %if there is usblData
  globalTrajvar+=comingVal; %sum b/c we are taking difference
  lastUsbl=globalTrajvar;    %want exact usbl difference
  
  gOdom=0; %reset global Odom value
  comingVal = 0; % reset comingVal as globalTrajvar is updated
  percentNRvar=20;
endif

percentNRvar=percentNRvar+0.01;
NRVar=round(percentNRvar*totalNCRval/200);
y=zeros(length(round(length(V(1,:))/2-NRVar:length(V(1,:))/2+NRVar)),1);

%because usbl and dgps are positioning sensors

globalTraj=[globalTraj;t globalTrajvar+comingVal];


t=odometryData(iOdom,1);
end       
toc
figure
plot(allB_PR_F(:,axis))
title("below is bprf and red is pcbc")
hold on
plot(globalTraj(:,2))
hold off
#xt2=globalTraj;
#save xt2.mat xt2;
#x3=globalTraj(:,2);
#save x3.mat x3;
allpcbc=globalTraj;
    times=dgpsData(:,1);
  errorpcbc = [];
  for i = 1 : length(globalTraj)
    t = allpcbc(i,1);
    [m ix] = min(abs(times.-t));
    errorpcbc = [errorpcbc; [dgpsData(ix,:) allpcbc(i,:)]];
  endfor
   
  errorNow = abs(mean(errorpcbc(:,axis)-errorpcbc(:,5)));

  errorNow