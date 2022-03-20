clear all
clc
range=[1:5:41];
centers=[1:10:41];

#setting Input for inertial sensor and positioning
AIMU=1;
sigmaIMU=1;


#xUSBL = zeros(1,801); % only when no usblData
#Setting Weights
WIMU=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaIMU,AIMU);
  WIMU=[WIMU;WG1D];
endfor

#some Variable initialization gor pcbc
VIMU =bsxfun(@rdivide,abs(WIMU),max(1e-6,max(abs(WIMU),[],2)));

V = VIMU';
epsilon1=1e-6;
epsilon2=1e-4;
  
#concatination 
W = WIMU;
[n,m]=size(W)
y=zeros(n,1);

#######################Filter Processing##########################

for ivalues = 1:41

x =   WG1D = G1D(range,ivalues,sigmaIMU,AIMU);
x=x';


#PCBC-DIM
for i=1:2000
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
comingVal(ivalues) = decode(y',centers);
endfor