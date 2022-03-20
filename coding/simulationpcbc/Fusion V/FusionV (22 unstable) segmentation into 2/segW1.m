function [W,V]=segW1(range,centers)
  

#setting Input for inertial sensor and positioning
global AIMU
global sigmaIMU
global ADVL
global sigmaDVL
global AUSBL
global sigmaUSBL
global ADGPS
global sigmaDGPS


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
#concatination 
W = [WIMU WDVL WUSBL WDGPS];

V = [VIMU VDVL VUSBL VDGPS];
V = V';
endfunction
