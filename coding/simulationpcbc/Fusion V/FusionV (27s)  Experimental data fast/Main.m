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



range=[-10:1:10];
centers=[-10:2:10];

iter=15; #iterations of PCBC
#setting Input for inertial sensor and positioning
AOdom=1;
sigmaOdom=1;
AUSBL=1;
sigmaUSBL=1;


#xUSBL = zeros(1,801); % only when no usblData
#Setting Weights
WOdom=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaOdom,AOdom)./sum(G1D(range,centers(iw),sigmaOdom,AOdom));
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
y=zeros(n,1);

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
for val=1:length(odometryData) % highest rate
  val
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
for i=1:iter
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
comingVal = decode(y',centers);

if sum(xUSBL)>0.001  %if there is usblData
  globalTrajvar+=comingVal; %sum b/c we are taking difference
  lastUsbl=globalTrajvar;    %want exact usbl difference
  
  gOdom=0; %reset global Odom value
  comingVal = 0; % reset comingVal as globalTrajvar is updated
endif


%because usbl and dgps are positioning sensors

globalTraj=[globalTraj;t globalTrajvar+comingVal];


t=odometryData(iOdom,1);
end       

figure
plot(allB_PR_F(:,axis))
title("below is bprf and red is pcbc")
hold on
plot(globalTraj(:,2))
hold off
