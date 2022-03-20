clear all
clc
close all
pkg load image

load("data/dvlData.mat")
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

range=[-40:5:40];
centers=[-40:5:40];

ADVL=1;
sigmaDVL=10;
AUSBL=1;
sigmaUSBL=8.5;
ADGPS=1;
sigmaDGPS=5;


#Setting Weights
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
#concatination 
W = [WUSBL WDGPS WDVL];
W =bsxfun(@rdivide,W,max(1e-6,sum(abs(W),1)));
V =bsxfun(@rdivide,abs(W),max(1e-6,max(abs(W),[],2)));
V = V';
epsilon1=1e-6;
epsilon2=1e-4;
[n,m] = size(W)
yX=zeros(n,1);
yY=zeros(n,1);
yZ=zeros(n,1);

#######################Filter Processing##########################


#MainFile2iDvl=1;
iDvl=1;
iUsbl=1; % b/qs i starts from 2
iDgps=1;
t=dvlData(1,1);
tDvl=dvlData(1,1);
tUsbl=usblData(1,1);
tDGPS=dgpsData(1,1)

gxDVL=0;
gyDVL=0;
gzDVL=0;
globalTrajvarX=0;
globalTrajvarY=0;
globalTrajvarZ=0;
lastDGPSX=0;
lastDGPSY=0;
lastDGPSZ=0;
lastUsblX=0; %reference Point
lastUsblY=0;
lastUsblZ=0;
decodedX = 0;
decodedY = 0;
decodedZ = 0;
globalTraj=[];


##### for values of sensors
t1 =time
for val=1:length(dvlData) % highest rate
  
if tDvl<=t && iDvl<length(dvlData)
  gxDVL = decodedX + dvlData(iDvl,2); % convert change into global
  gyDVL = decodedY + dvlData(iDvl,3);
  gzDVL = decodedZ + dvlData(iDvl,4);
  xDVL = G1D(range,gxDVL,sigmaDVL,ADVL); 
  yDVL = G1D(range,gyDVL,sigmaDVL,ADVL);
  zDVL = G1D(range,gzDVL,sigmaDVL,ADVL);

  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;
endif
  
if tUsbl<=t && iUsbl<length(usblData) % as we are taking change so total-1
  xUSBL = G1D(range,usblData(iUsbl,2)-lastUsblX,sigmaUSBL,AUSBL); % Already a change
  yUSBL = G1D(range,usblData(iUsbl,3)-lastUsblY,sigmaUSBL,AUSBL); % Already a change
  zUSBL = G1D(range,usblData(iUsbl,4)-lastUsblZ,sigmaUSBL,AUSBL); % Already a change

  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(1,m/3);
  yUSBL=zeros(1,m/3);
  zUSBL=zeros(1,m/3);
endif

if tDGPS<=t && iDgps<length(dgpsData)
  xDGPS = G1D(range,dgpsData(iDgps,2)-lastDGPSX,sigmaDGPS,ADGPS); % Already a change
  yDGPS = G1D(range,dgpsData(iDgps,3)-lastDGPSY,sigmaDGPS,ADGPS); % Already a change
  zDGPS = G1D(range,dgpsData(iDgps,4)-lastDGPSZ,sigmaDGPS,ADGPS); % Already a change
  tDGPS=dgpsData(iDgps+1,1);
  iDgps=iDgps+1;
else
  xDGPS=zeros(1,m/3);
  yDGPS=zeros(1,m/3);
  zDGPS=zeros(1,m/3);
endif




#PCBC-DIM
xX = [xUSBL xDGPS xDVL]';
xY = [yUSBL yDGPS yDVL]';
xZ = [zUSBL zDGPS zDVL]';
[rX,yX]=getRecons(xX,W,V,yX);
[rY,yY]=getRecons(xY,W,V,yY);
[rZ,yZ]=getRecons(xZ,W,V,yZ);


#Decoding
decodedX = decode(rX(1:m/3,1)',[range]);
if sum(xUSBL)>0.001 || sum(xDGPS)>0.001 %if there is usblData
  globalTrajvarX+=decodedX; %sum b/c we are taking difference
  lastUsblX=globalTrajvarX;    %want exact usbl difference
  lastDGPSX=globalTrajvarX;   % for approching to dgps
  decodedX = 0; % reset comingVal as globalTrajvar is updated
endif

decodedY = decode(rY(1:m/3,1)',[range]);
if sum(yUSBL)>0.001 || sum(yDGPS)>0.001 %if there is usblData
  globalTrajvarY+=decodedY; %sum b/c we are taking difference
  lastUsblY=globalTrajvarY;    %want exact usbl difference
  lastDGPSY=globalTrajvarY;   % for approching to dgps  
  decodedY = 0; % reset comingVal as globalTrajvar is updated
endif

decodedZ = decode(rZ(1:m/3,1)',[range]);
if sum(zUSBL)>0.001 || sum(zDGPS)>0.001 %if there is usblData
  globalTrajvarZ+=decodedZ; %sum b/c we are taking difference
  lastUsblZ=globalTrajvarZ;    %want exact usbl difference
  lastDGPSZ=globalTrajvarZ;   % for approching to dgps
  decodedZ = 0; % reset comingVal as globalTrajvar is updated
endif



globalTraj=[globalTraj;t globalTrajvarX+decodedX globalTrajvarY+decodedY globalTrajvarZ+decodedZ];


t=dvlData(iDvl,1);
end     
t2=time;
timeofExe=t2-t1


pcbcmse=immse(gtData(:,2:4),globalTraj(:,2:4))
bprfmse=immse(gtData(1:6300,2:4),(allB_PR_F_Mus(2:4,:))')

# ploting
source("plotFile.m")