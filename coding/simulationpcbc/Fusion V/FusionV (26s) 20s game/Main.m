#Stable version of Thesis coding
clear all
clc
###### Initialization#################################################


axis=2; %2-4 1 is time x=2,y=3,z=4


load("imuData.mat")
load("dvlData.mat")
load("usblData.mat")
load("dgpsData.mat")
load("gtData.mat")
load("altimeterData.mat")

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


range=[-40:15:40];
centers=[-40:20:40];

iter=30; #iterations of PCBC
#setting Input for inertial sensor and positioning
AIMU=1;
sigmaIMU=10;
ADVL=1;
sigmaDVL=10;
AUSBL=1;
sigmaUSBL=10;
ADGPS=1;
sigmaDGPS=10;


#xUSBL = zeros(1,801); % only when no usblData
#Setting Weights
WIMU=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaIMU,AIMU)./sum(G1D(range,centers(iw),sigmaIMU,AIMU));
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

gIMU=0;
gDVL=0;
globalTrajvar=0;
lastDGPS=lastUsbl=0; %reference Point
globalTraj=[];


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
  xUSBL = G1D(range,usblData(iUsbl,axis)-lastUsbl,sigmaUSBL,AUSBL); % Already a change
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(1,m/4);
endif

if tDGPS<=t && iDgps<length(dgpsData)
  xDGPS = G1D(range,dgpsData(iDgps,axis)-lastDGPS,sigmaDGPS,ADGPS); % Already a change
  tDGPS=dgpsData(iDgps+1,1);
  iDgps=iDgps+1;
else
  xDGPS=zeros(1,m/4);
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
