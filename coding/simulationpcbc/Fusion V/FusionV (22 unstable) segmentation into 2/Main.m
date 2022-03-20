#Stable version of Thesis coding
clear all
clc
###### Initialization#################################################


axis=3; %2-4 1 is time x=2,y=3,z=4


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

global AIMU=1;
global sigmaIMU=20;
global ADVL=1;
global sigmaDVL=5;
global AUSBL=1;
global sigmaUSBL=1;
global ADGPS=1;
global sigmaDGPS=0.1;

range=[-15:0.1:15];
centers=[-15:0.2:15];

[W,V] =segW1(range,centers);

[n,m]=size(W);
y=zeros(n,1);
epsilon1=1e-6;
epsilon2=1e-4;
iter=25; #iterations of PCBC

  

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
globalTrajvarspec=0;
globalTraj=[];
range2=[-40:0.1:40];
centers2=[-40:0.2:40];
[W2,V2] =segW1(range2,centers2); %segW1 is name of function
[n2,m2]=size(W2);
y2=zeros(n2,1);

range1=[-15:0.1:15];
centers1=[-15:0.2:15];
[W1,V1] =segW1(range1,centers1);
[n1,m1]=size(W1);
y1=zeros(n1,1);


sW=1; %for initialization
##### for values of sensors
for val=1:length(imuData) % highest rate
  val
if sW==1
  if tImu<=t && iImu<length(imuData)
  gIMU = gIMU + imuData(iImu,axis); % convert change into global
  xIMU = G1D(range1,gIMU,sigmaIMU,AIMU); 
  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
  endif
  
if tDvl<=t && iDvl<length(dvlData)
  gDVL = gDVL + dvlData(iDvl,axis); % convert change into global
  xDVL = G1D(range1,gDVL,sigmaDVL,ADVL); 
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;
  endif

if tUsbl<=t && iUsbl<length(usblData) % as we are taking change so total-1
  
  xUSBL = G1D(range1,usblData(iUsbl,axis)-globalTrajvarspec,sigmaUSBL,AUSBL); % Already a change
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(1,m1/4);
endif

if tDGPS<=t && iDgps<length(dgpsData)
  xDGPS = G1D(range1,dgpsData(iDgps,axis)-lastDGPS,sigmaDGPS,ADGPS); % Already a change
  tDGPS=dgpsData(iDgps+1,1);
  iDgps=iDgps+1;
else
  xDGPS=zeros(1,m/4);
endif




x = [xIMU xDVL xUSBL xDGPS];
x=x';


#PCBC-DIM
for i=1:iter
r=V1*y1;
e=x./(epsilon2+r);
y1=(epsilon1+y1).*(W1*e);
endfor
#Decoding
comingVal = decode(y1',centers1);

  endif

if sW==2
  if tImu<=t && iImu<length(imuData)
  gIMU = gIMU + imuData(iImu,axis); % convert change into global
  xIMU = G1D(range2,gIMU,sigmaIMU,AIMU); 
  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
endif
  
if tDvl<=t && iDvl<length(dvlData)
  gDVL = gDVL + dvlData(iDvl,axis); % convert change into global
  xDVL = G1D(range2,gDVL,sigmaDVL,ADVL); 
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;
  endif

if tUsbl<=t && iUsbl<length(usblData) % as we are taking change so total-1
  
  xUSBL = G1D(range2,usblData(iUsbl,axis)-globalTrajvarspec,sigmaUSBL,AUSBL); % Already a change
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(1,m2/4);
endif

if tDGPS<=t && iDgps<length(dgpsData)
  xDGPS = G1D(range2,dgpsData(iDgps,axis)-lastDGPS,sigmaDGPS,ADGPS); % Already a change
  tDGPS=dgpsData(iDgps+1,1);
  iDgps=iDgps+1;
else
  xDGPS=zeros(1,m2/4);
endif




x = [xIMU xDVL xUSBL xDGPS];
x=x';


#PCBC-DIM
for i=1:iter
r=V2*y2;
e=x./(epsilon2+r);
y2=(epsilon1+y2).*(W2*e);
endfor
#Decoding
comingVal = decode(y2',centers2);

  endif



if comingVal >12 || comingVal <-12
  sW==2
endif


if comingVal <12 || comingVal >-12
  sW==1;
  endif

if sum(xUSBL)>0.01 || sum(xDGPS)>0.01 %if there is usblData
  globalTrajvar+=comingVal; %sum b/c we are taking difference
  lastUsbl=usblData(iUsbl-1,axis);    %want exact usbl difference
  lastDGPS=globalTrajvar;   % for approching to dgps
  gIMU=0; %reset global IMU value
  gDVL=0; %reset global DVL value
  comingVal = 0; % reset comingVal as globalTrajvar is updated
endif


%because usbl and dgps are positioning sensors

globalTraj=[globalTraj;t globalTrajvar+comingVal];
globalTrajvarspec=globalTraj(iImu-1,2);

t=imuData(iImu,1);

end       
figure
plot(gtData(1:val,axis))
hold on 
plot(globalTraj(1:val-1,2))
hold off
