#mX 
#Stable version of Thesis coding
clear all
clc

load("imuData.mat")
load("dvlData.mat")
load("usblData.mat")
load("dgpsData.mat")
load("gtData.mat")
load("altimeterData.mat")

#try putting values in inertial and global sensor
XlocationIMU=imuData(1,2);
XlocationDVL=dvlData(1,2);
XlocationUSBL=usblData(1,2);
#xUSBL will be zeros(1,801) %when no usblData


range=[-40:0.1:40];
centers=[-40:0.2:40];

iter=25;
#setting Input for inertial sensor and positioning
AIMU=0.1;
sigmaIMU=30;
ADVL=0.1;
sigmaDVL=2;
AUSBL=40;
sigmaUSBL=0.1;

#setting input for positioning sensor
xIMU = G1D(range,XlocationIMU,sigmaIMU,AIMU); 
xDVL = G1D(range,XlocationDVL,sigmaDVL,ADVL); 

xUSBL = G1D(range,XlocationUSBL,sigmaUSBL,AUSBL); 
#xUSBL = zeros(1,801); % only when no usblData
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
#some Variable initialization gor pcbc
VUSBL=bsxfun(@rdivide,abs(WUSBL),max(1e-6,max(abs(WUSBL),[],2)));
VIMU =bsxfun(@rdivide,abs(WIMU),max(1e-6,max(abs(WIMU),[],2)));
VDVL =bsxfun(@rdivide,abs(WDVL),max(1e-6,max(abs(WDVL),[],2)));
V = [VIMU VDVL VUSBL];
V = V';
y=zeros(401,1);
epsilon1=1e-6;
epsilon2=1e-4;

  
#concatination 
W = [WIMU WUSBL WUSBL];
x = [xIMU xDVL xUSBL];
x=x';


#PCBC-DIM
for i=1:iter
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
localTrajvar = decode(y',centers)
globalTrajvar=localTrajvar;
usblDiff=localTrajvar;
#source('mainFile2.m')
kk=0


source('PreCompile.m')
#MainFile2
kk
xCusbl=[];
globalTrajvar=0;
globalTraj=[];
localTraj=[];

xCusbl(2:158,1:4)=usblData(2:158,1:4);

iImu=2;
iDvl=2;
iUsbl=2;
t=imuData(2,1);
tImu=imuData(2,1);
tDvl=dvlData(2,1);
tUsbl=xCusbl(2,1);
dt=imuData(2,1)-imuData(1,1);
for val=1:6300
  val
if tImu<=t && iImu<6300
  xIMU = G1D(range,imuData(iImu,2),sigmaIMU,AIMU); 
  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
endif
  
if tDvl<=t && iDvl<6301 
  xDVL = G1D(range,dvlData(iDvl,2),sigmaDVL,ADVL); 
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;
else 
  xDVL =zeros(1,801);
  endif

if tUsbl<=t && iUsbl<158
  xUSBL = G1D(range,xCusbl(iUsbl,2)-xCusbl(iUsbl-1,2),sigmaUSBL,AUSBL); 
  
  if 806<=t && iDvl<6301 && t<=1906 # to overcome below water abruptness
  xDVL = G1D(range,localTrajvar,30,40); 
  endif
  
  tUsbl=xCusbl(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(1,801);
endif

x = [xIMU xDVL xUSBL];
x=x';


#PCBC-DIM
for i=1:iter
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
comingVal = decode(y',centers);

if sum(xUSBL)>0.01
  globalTrajvar+=comingVal;
  usblDiff=globalTrajvar;
  localTrajvar=0;
endif
localTrajvar=localTrajvar+comingVal;

globalTraj=[globalTraj;t globalTrajvar+localTrajvar];


t=t+dt;
end
figure
plot(gtData(1:val,2))
hold on 
plot(globalTraj(1:val-1,2))
hold off