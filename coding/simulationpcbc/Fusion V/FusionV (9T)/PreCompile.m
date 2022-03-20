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

#setting Input for inertial sensor
sigmaIMU=1;
sigmaDVL=0.5;
AIMU=0.1;
ADVL=10;
xIMU = G1D(range,XlocationIMU,sigmaIMU,AIMU); 
xDVL = G1D(range,XlocationDVL,sigmaDVL,ADVL); 
#setting input for positioning sensor
sigmaUSBL=0.1;
AUSBL=40;
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
for i=1:25  
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
localTrajvar = decode(y',centers)
globalTrajvar=localTrajvar;
usblDiff=localTrajvar;