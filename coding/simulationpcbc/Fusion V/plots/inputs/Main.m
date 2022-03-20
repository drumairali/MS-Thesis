#Stable version of Thesis coding
clear all
clc
###### Initialization#################################################

 %2-4 1 is time x=2,y=3,z=4
pkg load image

load("data/imuData.mat")
load("data/dvlData.mat")
load("data/usblData.mat")
load("data/dgpsData.mat")
load("data/gtData.mat")
load("data/bprfsim.mat")

% adding non-Gaussian Noise to the USBL sensor x and y
usblData(10,2:3) = [-150 -100];
usblData(20,2:3) = [-150 -100];
usblData(40,2:3) = [-150 -100];
usblData(60,2:3) = [-150 -100];
usblData(80,2:3) = [-150 -100];
usblData(100,2:3) = [-150 -100];
usblData(120,2:3) = [-150 -100];
usblData(140,2:3) = [-150 -100]; 


#xUSBL will be zeros(1,801) %when no usblData


range=[-40:0.5:40]; #just to gaussian smooth
centers=[-40:0.10:40];

iter=10; #iterations of PCBC
#setting Input for inertial sensor and positioning
AIMU=1;
sigmaIMU=1;
ADVL=1;
sigmaDVL=5;
AUSBL=1;
sigmaUSBL=5;
ADGPS=1;
sigmaDGPS=5;


#Setting Weights
WIMU=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaIMU,AIMU);
  WIMU=[WIMU;WG1D];
endfor

WDVL=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaDVL,ADVL);
  WDVL=[WDVL;WG1D];
endfor


WUSBL=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaUSBL,AUSBL);
  WUSBL=[WUSBL;WG1D];
endfor


WDGPS=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaDGPS,ADGPS);
  WDGPS=[WDGPS;WG1D];
endfor

#some Variable initialization gor pcbc
VUSBL=bsxfun(@rdivide,abs(WUSBL),max(1e-6,max(abs(WUSBL),[],2)));
VIMU =bsxfun(@rdivide,abs(WIMU),max(1e-6,max(abs(WIMU),[],2)));
VDVL =bsxfun(@rdivide,abs(WDVL),max(1e-6,max(abs(WDVL),[],2)));
VDGPS =bsxfun(@rdivide,abs(WDGPS),max(1e-6,max(abs(WDGPS),[],2)));

V = [VIMU VDVL VUSBL VDGPS];
V = V';
epsilon1=1e-6;
epsilon2=1e-4;

  
#concatination 
W = [WIMU WDVL WUSBL WDGPS];
[n,m] = size(W)
y=zeros(n,1);

#######################Filter Processing##########################


#MainFile2iImu=1;
iImu=1;
iDvl=1;
iUsbl=1; % b/qs i starts from 2
iDgps=1;
t=imuData(1,1);
tImu=imuData(1,1);
tDvl=dvlData(1,1);
tUsbl=usblData(1,1);
tDGPS=dgpsData(1,1)

gXIMU=gYIMU=gZIMU=0;
gXDVL=gYDVL=gZDVL=0;
globalTrajvar=[0 0 0];
lastDGPS=lastUsbl=[0 0 0]; %reference Point
globalTraj=[];


##### for values of sensors
t1 =time
for val=1:121 % highest rate
  
if tImu<=t && iImu<length(imuData)
  gXIMU = gXIMU + imuData(iImu,2); % convert change into global
  gYIMU = gYIMU + imuData(iImu,3);
  gZIMU = gZIMU + imuData(iImu,4);
  xIMU(1,:) = G1D(range,gXIMU,sigmaIMU,AIMU); 
  xIMU(2,:) = G1D(range,gYIMU,sigmaIMU,AIMU);
  xIMU(3,:) = G1D(range,gZIMU,sigmaIMU,AIMU);

  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
endif
  
if tDvl<=t && iDvl<length(dvlData)
  gXDVL = gXDVL + dvlData(iDvl,2); % convert change into global
  gYDVL = gYDVL + dvlData(iDvl,3); % convert change into global
 gZDVL = gZDVL + dvlData(iDvl,4); % convert change into global

  xDVL(1,:) = G1D(range,gXDVL,sigmaDVL,ADVL); 
  xDVL(2,:) = G1D(range,gYDVL,sigmaDVL,ADVL); 
  xDVL(3,:) = G1D(range,gZDVL,sigmaDVL,ADVL); 
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;

  endif

if tUsbl<=t && iUsbl<length(usblData) % as we are taking change so total-1
  xUSBL(1,:) = G1D(range,usblData(iUsbl,2)-lastUsbl(1,1),sigmaUSBL,AUSBL); % Already a change
  xUSBL(2,:) = G1D(range,usblData(iUsbl,3)-lastUsbl(1,2),sigmaUSBL,AUSBL); % Already a change
  xUSBL(3,:) = G1D(range,usblData(iUsbl,4)-lastUsbl(1,3),sigmaUSBL,AUSBL); % Already a change

  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(3,m/4);
endif

if tDGPS<=t && iDgps<length(dgpsData)
  xDGPS(1,:) = G1D(range,dgpsData(iDgps,2)-lastDGPS(1,1),sigmaDGPS,ADGPS); % Already a change
  xDGPS(2,:) = G1D(range,dgpsData(iDgps,3)-lastDGPS(1,2),sigmaDGPS,ADGPS); % Already a change
  xDGPS(3,:) = G1D(range,dgpsData(iDgps,4)-lastDGPS(1,3),sigmaDGPS,ADGPS); % Already a change
  tDGPS=dgpsData(iDgps+1,1);
  iDgps=iDgps+1;
else
  xDGPS=zeros(3,m/4);
endif




x = [xIMU xDVL xUSBL xDGPS];
x=x';

#PCBC-DIM
for xyz=1:3
for i=1:iter
r=V*y;
e=x(:,xyz)./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor

#Decoding
comingVal(1,xyz) = decode(r(1:m/4,1)',[range]);
if sum(xUSBL(xyz,:))>0.1 || sum(xDGPS(xyz,:))>0.1 %if there is usblData
  globalTrajvar(1,xyz)+=comingVal(1,xyz); %sum b/c we are taking difference
  lastUsbl(1,xyz)=globalTrajvar(1,xyz);    %want exact usbl difference
  lastDGPS(1,xyz)=globalTrajvar(1,xyz);   % for approching to dgps
  gXIMU=gYIMU=gZIMU=0; %reset global IMU value
  gXDVL=gYDVL=gZDVL=0; %reset global DVL value
  
  comingVal(1,xyz) = 0; % reset comingVal as globalTrajvar is updated
endif
%because usbl and dgps are positioning sensors

endfor


globalTraj=[globalTraj;t globalTrajvar+comingVal];


t=imuData(iImu,1);
end     
# ploting
source("printing.m")