#Stable version of Thesis coding
clear all
clc
###### Initialization#################################################
tic

range=[-100:1:100];
centers=[-100:2:100];
totalNCRval=length(centers)
percentNRvar=99  ##
NRVar=percentNRvar*totalNCRval/200

iter=15; #iterations of PCBC
#setting Input for inertial sensor and positioning
AOdom=1;
sigmaOdom=2;
AUSBL=1;
sigmaUSBL=2;

xOdom = G1D(range,50,sigmaUSBL,AUSBL);
xUSBL = G1D(range,70,sigmaUSBL,AUSBL);


#xUSBL = zeros(1,801); % only when no usblData
#Setting Weights
WOdom=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaOdom,AOdom);
  WOdom=[WOdom;WG1D];
endfor



WUSBL=[];
[ext,wn]=size(centers);
for iw=1:wn
  WG1D = G1D(range,centers(iw),sigmaUSBL,AUSBL);
  WUSBL=[WUSBL;WG1D];
endfor

#some Variable initialization gor pcbc
VUSBL=bsxfun(@rdivide,abs(WUSBL),max(1e-6,max(abs(WUSBL),[],2)));
VOdom =bsxfun(@rdivide,abs(WOdom),max(1e-6,max(abs(WOdom),[],2)));

V = [VOdom VUSBL]';
epsilon1=1e-6;
epsilon2=1e-4;

  
#concatination 
W = [WOdom WUSBL];
V = [VOdom VUSBL]';

[n,m]=size(W)
NRVar=percentNRvar*totalNCRval/200


y=zeros(length(round(length(V(1,:))/2-NRVar:length(V(1,:))/2+NRVar)),1);

xOdom = G1D(range,50,sigmaUSBL,AUSBL);

xUSBL = G1D(range,70,sigmaUSBL,AUSBL);



x = [xOdom xUSBL];
x=x';

#PCBC-DIM
for i=1:iter
r=V(:,round(length(V(1,:))/2-NRVar:length(V(1,:))/2+NRVar))*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W(round(length(V(1,:))/2-NRVar:length(V(1,:))/2+NRVar),:)*e);
endfor
#Decoding
comingVal = decode((r(1:round(length(r)/2)))',range)

toc