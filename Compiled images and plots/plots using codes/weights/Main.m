#Stable version of Thesis coding
clear all
clc
###### Initialization#################################################

 %2-4 1 is time x=2,y=3,z=4
pkg load image



#xUSBL will be zeros(1,801) %when no usblData


range=[-40:5:40];
centers=[-40:10:40];

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
source('printing.m')