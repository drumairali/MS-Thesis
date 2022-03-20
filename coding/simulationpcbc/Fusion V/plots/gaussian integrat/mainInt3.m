




#just for achieving desired plots




clear all
clc
###### Initialization#################################################


clear clc
#xUSBL will be zeros(1,801) %when no usblData


range=[-40:0.5:40];
centers=[-40:1:40];

iter=10; #iterations of PCBC
#setting Input for inertial sensor and positioning
AIMU=1;
sigmaIMU=2;
ADVL=1;
sigmaDVL=5;
AUSBL=1
sigmaUSBL=6;






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



VIMU =bsxfun(@rdivide,abs(WIMU),max(1e-6,max(abs(WIMU),[],2)));
VDVL =bsxfun(@rdivide,abs(WDVL),max(1e-6,max(abs(WDVL),[],2)));
VUSBL =bsxfun(@rdivide,abs(WUSBL),max(1e-6,max(abs(WUSBL),[],2)));

V = [VIMU VDVL VUSBL];
V = V';
epsilon1=1e-6;
epsilon2=1e-4;

  
#concatination 
W = [WIMU WDVL WUSBL];
[n,m] = size(W)
y=zeros(n,1);

#######################Filter Processing##########################




##### for values of sensors
xIMU =G1D(range,5,sigmaIMU,AIMU)
xDVL =G1D(range,-5,sigmaDVL,ADVL)
xUSBL=G1D(range,-10,sigmaUSBL,AUSBL)




x = [xIMU xDVL xUSBL];
x=x';

#PCBC-DIM
for i=1:25
r=V*y;
e=x(:,1)./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor

#Decoding
comingVal(1,1) = decode(r(1:m/3,1)',[range]);



     


# ploting
hold on
subplot(3,1,1)
hold on
plot([range ]',xIMU,"LineWidth", 2)
plot([range ]',xDVL,"LineWidth", 2)
plot([range ]',xUSBL,"LineWidth", 2)
hold off
title('inputs')
set(gca, "linewidth", 1, "fontsize", 20)

subplot(3,1,2)
plot(centers',y,"LineWidth", 2)
title('prediction')
set(gca, "linewidth", 1, "fontsize", 20)

subplot(3,1,3)
plot([range]',r(1:m/3,1),"LineWidth", 2)
title('reconstruted input')
set(gca, "linewidth", 1, "fontsize", 20)

hold off