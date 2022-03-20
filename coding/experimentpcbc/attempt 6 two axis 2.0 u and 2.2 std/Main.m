#Stable version of Thesis coding
clear all
clc
###### Initialization#################################################
load("data/compassData.mat");
load("data/odometryData.mat");
load("data/usblData.mat");
load("data/dgpsData.mat");

range=[-15:5:15];
centers=[-15:10:15];
totalNCRval=length(centers)
  ##
iter=15; #iterations of PCBC
#setting Input for inertial sensor and positioning
AOdom=1;
sigmaOdom=10;
AUSBL=1;
sigmaUSBL=5;

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

V = [VOdom VUSBL];
V = V';
epsilon1=1e-6;
epsilon2=1e-4;

#concatination 
W = [WOdom WUSBL];
[n,m]=size(W)
percentNRvar=50
NRVar=round(percentNRvar*totalNCRval/200)
y=zeros(n,1);

#######################Filter Processing##########################
#MainFile2iOdom=1;
iOdom=1;
iUsbl=1; % b/qs i starts from 2
t=usblData(1,1);
tOdom=odometryData(1,1);
tUsbl=usblData(1,1);

gOdom=0;
globalTrajvar=0;
lastDGPS=lastUsbl=0; %reference Point

##### for values of sensors
gXOdom=0
gYOdom=0;
globalTrajvar=[0 0];
lastUsbl=[0 0]; %reference Point
globalTraj=[];
tic

fprintf('program is processing...')
for val=1:length(odometryData) % highest rate
if tOdom<=t && iOdom<length(odometryData)
  gXOdom = gXOdom + odometryData(iOdom,2); % convert change into global
  gYOdom = gYOdom + odometryData(iOdom,3); % convert change into global
  xOdom(1,:) = G1D(range,gXOdom,sigmaOdom,AOdom); 
  xOdom(2,:) = G1D(range,gYOdom,sigmaOdom,AOdom); 
  tOdom=odometryData(iOdom+1,1);
  iOdom=iOdom+1;
else 
  xOdom = zeros(2,m/2);
endif

if tUsbl<=t && iUsbl<length(usblData) % as we are taking change so total-1
  xUSBL(1,:) = G1D(range,usblData(iUsbl,2)-lastUsbl(1,1),sigmaUSBL,AUSBL); % Already a change
  xUSBL(2,:) = G1D(range,usblData(iUsbl,3)-lastUsbl(1,2),sigmaUSBL,AUSBL); % Already a change
  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(2,m/2);
endif
x = [xOdom xUSBL];
x=x';
#PCBC-DIM
for xyz=1:2

for i=1:iter

r=V*y;
e=x(:,xyz)./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
comingVal(1,xyz) = decode(r(1:m/2)',range);
if sum(xUSBL(xyz,:))>0.001  %if there is usblData
  globalTrajvar(1,xyz)+=comingVal(1,xyz); %sum b/c we are taking difference
  lastUsbl(1,xyz)=globalTrajvar(1,xyz);    %want exact usbl difference
  
  gXOdom=0;
  gYOdom=0; %reset global Odom value
  comingVal(1,xyz) = 0; % reset comingVal as globalTrajvar is updated
  percentNRvar=25;
endif
%because usbl and dgps are positioning sensors
end
globalTraj=[globalTraj;t globalTrajvar+comingVal];
t=odometryData(iOdom,1);
end       
toc
figure
hold on
plot(globalTraj(:,2),globalTraj(:,3))
plot(dgpsData(:,2),dgpsData(:,3))
hold off
#xt2=globalTraj;
#save xt2.mat xt2;
#x3=globalTraj(:,2);
#save x3.mat x3;
allpcbc=globalTraj;
    times=dgpsData(:,1);
  errorpcbc = [];
  for i = 1 : length(globalTraj)
    t = allpcbc(i,1);
    [m ix] = min(abs(times.-t));
    errorpcbc = [errorpcbc; [dgpsData(ix,:) allpcbc(i,:)]];
  endfor
  
errorpcbc(:,7) = (((errorpcbc(:,2)-errorpcbc(:,5)).^2 + (errorpcbc(:,3)-errorpcbc(:,6)).^2)/2).^0.5;
mean(errorpcbc(:,7))
std(errorpcbc(:,7))