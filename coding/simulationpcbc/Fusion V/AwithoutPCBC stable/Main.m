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


#xUSBL = zeros(1,801); % only when no usblData
#Setting Weights

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
  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
endif
  
if tDvl<=t && iDvl<length(dvlData)
  gDVL = gDVL + dvlData(iDvl,axis); % convert change into global
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;
  endif

if tUsbl<=t && iUsbl<length(usblData) % as we are taking change so total-1
  xUSBL = usblData(iUsbl,axis)-lastUsbl;% Already a change
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=0;
endif

if tDGPS<=t && iDgps<length(dgpsData)
  xDGPS = dgpsData(iDgps,axis)-lastDGPS; % Already a change
  tDGPS=dgpsData(iDgps+1,1);
  iDgps=iDgps+1;
else
  xDGPS=0;
endif




comingVal = (gDVL + gIMU)/2;

if xUSBL!=0  %if there is usblData
  comingVal = xUSBL
  globalTrajvar+=comingVal; %sum b/c we are taking difference
  lastUsbl=globalTrajvar;    %want exact usbl difference
  lastDGPS=globalTrajvar;   % for approching to dgps
  gIMU=0; %reset global IMU value
  gDVL=0; %reset global DVL value
  comingVal = 0; % reset comingVal as globalTrajvar is updated
  globalTraj=[globalTraj;t globalTrajvar];

endif


%because usbl and dgps are positioning sensors
if xUSBL==0
globalTraj=[globalTraj;t globalTrajvar+comingVal];
endif

t=imuData(iImu,1);
end       
figure
plot(gtData(1:val,axis))
hold on 
plot(globalTraj(1:val-5,2))
hold off
