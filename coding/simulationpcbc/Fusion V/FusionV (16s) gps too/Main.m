#Stable version of Thesis coding
clear all
clc
###### Initialization#################################################


axis=2+1+1; %2-4


load("imuData.mat")
load("dvlData.mat")
load("usblData.mat")
load("dgpsData.mat")
load("gtData.mat")
load("altimeterData.mat")

#try putting values in inertial and global sensor
XlocationIMU=imuData(1,axis);
XlocationDVL=dvlData(1,axis);
XlocationUSBL=usblData(1,axis);
#xUSBL will be zeros(1,801) %when no usblData


range=[-40:0.1:40];
centers=[-40:0.2:40];

iter=25; #iterations of PCBC
#setting Input for inertial sensor and positioning
AIMU=1;
sigmaIMU=20;
ADVL=1;
sigmaDVL=5;
AUSBL=1;
sigmaUSBL=1;
ADGPS=1;
sigmaDGPS=0.1;

#setting input for positioning sensor
xIMU = G1D(range,XlocationIMU,sigmaIMU,AIMU); 
xDVL = G1D(range,XlocationDVL,sigmaDVL,ADVL); 
xUSBL = G1D(range,XlocationUSBL,sigmaUSBL,AUSBL); 
xDGPS = zeros(1,801); 

#xUSBL = zeros(1,801); % only when no usblData
#Setting Weights
WIMU=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaIMU,AIMU)./sum(G1D(range,XlocationIMU,sigmaIMU,AIMU));
  WIMU=[WIMU;WG1D];
endfor

WDVL=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaDVL,ADVL)./sum(G1D(range,XlocationDVL,sigmaDVL,ADVL));
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
y=zeros(401,1);
epsilon1=1e-6;
epsilon2=1e-4;

  
#concatination 
W = [WIMU WUSBL WUSBL WDGPS];
x = [xIMU xDVL xUSBL xDGPS];
x=x';


#PCBC-DIM
for i=1:iter
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
globalTraj=[];
globalTrajvar=0;
t=0;
lastUsbl=globalTrajvar=decode(y',centers)
globalTraj=[globalTraj; t globalTrajvar]

#######################Filter Processing##########################


#MainFile2
xCusbl=[];
localTraj=[];
xCusbl(2:158,1:4)=usblData(2:158,1:4);
iImu=2;
iDvl=2;
iUsbl=1; % b/qs i starts from 2
iDgps=1;
t=imuData(2,1);
tImu=imuData(2,1);
tDvl=dvlData(2,1);
tUsbl=xCusbl(2,1);
tDGPS=dgpsData(1,1)
dt=imuData(2,1)-imuData(1,1);

gIMU=0;
gDVL=0;


##### for values of sensors
for val=1:length(imuData) % highest rate
  val
if tImu<=t && iImu<length(imuData)
  gIMU = gIMU + imuData(iImu,axis); % convert change into global
  xIMU = G1D(range,gIMU,sigmaIMU,AIMU); 
  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
endif
  
if tDvl<=t && iDvl<length(dvlData)
  gDVL = gDVL + dvlData(iDvl,axis); % convert change into global
  xDVL = G1D(range,gDVL,sigmaDVL,ADVL); 
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;
  endif

if tUsbl<=t && iUsbl<length(usblData) % as we are taking change so total-1
  xUSBL = G1D(range,usblData(iUsbl+1,axis)-lastUsbl,sigmaUSBL,AUSBL); % Already a change
  tUsbl=xCusbl(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(1,801);
endif

if tDGPS<=t && iDgps<length(dgpsData)
  xDGPS = G1D(range,dgpsData(iDgps,axis)-lastDGPS,sigmaDGPS,ADGPS); % Already a change
  tDGPS=dgpsData(iDgps+1,1);
  iDgps=iDgps+1;
else
  xDGPS=zeros(1,801);
endif




x = [xIMU xDVL xUSBL xDGPS];
x=x';


#PCBC-DIM
for i=1:iter
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
comingVal = decode(y',centers);

if sum(xUSBL)>0.01 || sum(xDGPS)>0.01 %if there is usblData
  globalTrajvar+=comingVal; %sum b/c we are taking difference
  lastUsbl=globalTrajvar;    %want exact usbl difference
  lastDGPS=globalTrajvar;   % for approching to dgps
  gIMU=0; %reset global IMU value
  gDVL=0; %reset global DVL value
  comingVal = 0; % reset comingVal as globalTrajvar is updated
endif


%because usbl and dgps are positioning sensors

globalTraj=[globalTraj;t globalTrajvar+comingVal];


t=imuData(iImu,1);
end       
figure
plot(gtData(1:val,axis))
hold on 
plot(globalTraj(1:val,2))
hold off
