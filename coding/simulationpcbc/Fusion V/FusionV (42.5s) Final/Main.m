#Stable version of Thesis coding
clear all
clc
###### Initialization#################################################

 %2-4 1 is time x=2,y=3,z=4
pkg load image

load("imuData.mat")
load("dvlData.mat")
load("usblData.mat")
load("dgpsData.mat")
load("gtData.mat")
load("bprfsim.mat")

% adding non-Gaussian Noise to the USBL sensor x and y

#xUSBL will be zeros(1,801) %when no usblData


range=[-40:5:40];
centers=[-40:10:40];

iter=10; #iterations of PCBC
#setting Input for inertial sensor and positioning
AIMU=1;
sigmaIMU=5;
ADVL=1;
sigmaDVL=5;
AUSBL=1;
sigmaUSBL=5;
ADGPS=1;
sigmaDGPS=5;


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

V = [VIMU VDVL VUSBL VDGPS];
V = V';
epsilon1=1e-6;
epsilon2=1e-4;

  
#concatination 
W = [WIMU WDVL WUSBL WDGPS];
[n,m] = size(W)
y=zeros(n,1);

#######################Filter Processing##########################


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

gXIMU=gYIMU=gZIMU=0;
gXDVL=gYDVL=gZDVL=0;
globalTrajvar=[0 0 0];
lastDGPS=lastUsbl=[0 0 0]; %reference Point
globalTraj=[];


##### for values of sensors
t1 =time
for val=1:length(imuData) % highest rate
  
if tImu<=t && iImu<length(imuData)
  gXIMU = gXIMU + imuData(iImu,2); % convert change into global
  gYIMU = gYIMU + imuData(iImu,3);
  gZIMU = gZIMU + imuData(iImu,4);
  xIMU(1,:) = G1D(range,gXIMU,sigmaIMU,AIMU); 
  xIMU(2,:) = G1D(range,gYIMU,sigmaIMU,AIMU);
  xIMU(3,:) = G1D(range,gZIMU,sigmaIMU,AIMU);

  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
endif
  
if tDvl<=t && iDvl<length(dvlData)
  gXDVL = gXDVL + dvlData(iDvl,2); % convert change into global
  gYDVL = gYDVL + dvlData(iDvl,3); % convert change into global
 gZDVL = gZDVL + dvlData(iDvl,4); % convert change into global

  xDVL(1,:) = G1D(range,gXDVL,sigmaDVL,ADVL); 
  xDVL(2,:) = G1D(range,gYDVL,sigmaDVL,ADVL); 
  xDVL(3,:) = G1D(range,gZDVL,sigmaDVL,ADVL); 
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;

  endif

if tUsbl<=t && iUsbl<length(usblData) % as we are taking change so total-1
  xUSBL(1,:) = G1D(range,usblData(iUsbl,2)-lastUsbl(1,1),sigmaUSBL,AUSBL); % Already a change
  xUSBL(2,:) = G1D(range,usblData(iUsbl,3)-lastUsbl(1,2),sigmaUSBL,AUSBL); % Already a change
  xUSBL(3,:) = G1D(range,usblData(iUsbl,4)-lastUsbl(1,3),sigmaUSBL,AUSBL); % Already a change

  tUsbl=usblData(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(3,m/4);
endif

if tDGPS<=t && iDgps<length(dgpsData)
  xDGPS(1,:) = G1D(range,dgpsData(iDgps,2)-lastDGPS(1,1),sigmaDGPS,ADGPS); % Already a change
  xDGPS(2,:) = G1D(range,dgpsData(iDgps,3)-lastDGPS(1,2),sigmaDGPS,ADGPS); % Already a change
  xDGPS(3,:) = G1D(range,dgpsData(iDgps,4)-lastDGPS(1,3),sigmaDGPS,ADGPS); % Already a change
  tDGPS=dgpsData(iDgps+1,1);
  iDgps=iDgps+1;
else
  xDGPS=zeros(3,m/4);
endif




x = [xIMU xDVL xUSBL xDGPS];
x=x';

#PCBC-DIM
for xyz=1:3
for i=1:iter
r=V*y;
e=x(:,xyz)./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
comingVal(1,xyz) = decode(r',[range range range range]);
if sum(xUSBL(xyz,:))>0.1 || sum(xDGPS(xyz,:))>0.1 %if there is usblData
  globalTrajvar(1,xyz)+=comingVal(1,xyz); %sum b/c we are taking difference
  lastUsbl(1,xyz)=globalTrajvar(1,xyz);    %want exact usbl difference
  lastDGPS(1,xyz)=globalTrajvar(1,xyz);   % for approching to dgps
  gXIMU=gYIMU=gZIMU=0; %reset global IMU value
  gXDVL=gYDVL=gZDVL=0; %reset global DVL value
  
  comingVal(1,xyz) = 0; % reset comingVal as globalTrajvar is updated
endif

%because usbl and dgps are positioning sensors

endfor


globalTraj=[globalTraj;t globalTrajvar+comingVal];


t=imuData(iImu,1);
end     
t2=time;
timeofExe=t2-t1


pcbcmse=immse(gtData(:,2:4),globalTraj(:,2:4))
bprfmse=immse(gtData(1:6300,2:4),(allB_PR_F_Mus(2:4,:))')


allDgps=dgpsData(:,1:4)';
allPCBCDIM=globalTraj';
###ploting

allUsbl=usblData(:,1:4)';
gtData = gtData';

 figure(2) #BPRF
  hold on;
  title("B-PR-F Neural Network");    
  
  plot3 (gtData(2,:), gtData(3,:), gtData(4,:), 'g',"LineWidth", 1);
  if size(allDgps,2) > 0
    plot3 (allDgps(2,:), allDgps(3,:), allDgps(4,:), 'ok',"LineWidth", 2);
  endif
  if size(allUsbl,2) > 0
    plot3 (allUsbl(2,:), allUsbl(3,:), allUsbl(4,:), '.k',"LineWidth", 2);
  endif
  
  n = size(allB_PR_F_Mus,2);
  p = c = allB_PR_F_Mus(:,1);
  i = 1;
  flag = 1;
  while i<n
    while c(end) == p(end) && i<n
      c = allB_PR_F_Mus(:,i);
      i = i + 1;
    endwhile
    if p(end) == 1
        plot3 (allB_PR_F_Mus(2,flag:i-1), allB_PR_F_Mus(3,flag:i-1), allB_PR_F_Mus(4,flag:i-1), 'b',"LineWidth", 1);
    else
        plot3 (allB_PR_F_Mus(2,flag:i-1), allB_PR_F_Mus(3,flag:i-1), allB_PR_F_Mus(4,flag:i-1), 'r',"LineWidth", 1);
    endif
    flag = i;
    p = c;
  endwhile
  if p(end) == 1
      plot3 (allB_PR_F_Mus(2,flag-1:flag), allB_PR_F_Mus(3,flag-1:flag), allB_PR_F_Mus(4,flag-1:flag), 'b',"LineWidth", 1);
  else
      plot3 (allB_PR_F_Mus(2,flag-1:flag), allB_PR_F_Mus(3,flag-1:flag), allB_PR_F_Mus(4,flag-1:flag), 'r',"LineWidth", 1);
  endif
  
  v = [-40,35];
set(gca, "linewidth", 2, "fontsize", 20)
  legend("GT", "DGPS", "USBL","Behavour1", "Behavour2");
  view(v);
hold off
 
figure(1) # PCBC-DIM

  hold on;
  title("PC/BC-DIM Neural Network");    
  
  plot3 (gtData(2,:), gtData(3,:), gtData(4,:), 'g',"LineWidth", 1);
  if size(allDgps,2) > 0
    plot3 (allDgps(2,:), allDgps(3,:), allDgps(4,:), 'ok',"LineWidth", 2);
  endif
  if size(allUsbl,2) > 0
    plot3 (allUsbl(2,:), allUsbl(3,:), allUsbl(4,:), '.k',"LineWidth", 1);
  endif
  
  plot3 (allPCBCDIM(2,:), allPCBCDIM(3,:), allPCBCDIM(4,:), 'b',"LineWidth", 2);
   
  
  v = [-40,35];
set(gca, "linewidth", 2, "fontsize", 20)
  legend("GT", "DGPS", "USBL","PC/BC-DIM");
  view(v);
hold off
hold off
  
  
   
  figure(3);
  hold on;
  title("Time evolution of RMS error");
  gtData = gtData(:,1:end);
  err1 =  allB_PR_F_Mus(2:4,1:6299) - gtData(2:4,1:6299);
  err1 = (sum((err1.*err1),1)/3).^0.5;
  plot(gtData(1,1:6299), err1(1,1:6299), "r");  

  
  meanError = mean(err1);
  stdError = std(err1);
  display(strcat("BPRF RMS error: ", num2str(meanError)));
  display(strcat("BPRF stdev error: : ", num2str(stdError)));
  
  err1 =  allPCBCDIM(2:4,1:6299) - gtData(2:4,1:6299);
  err1 = (sum((err1.*err1),1)/3).^0.5;
  plot(gtData(1,1:6299), err1(1,1:6299), "b");  
  xlabel("Time in sec");
  ylabel("Error in m");
  
  meanError = mean(err1);
  stdError = std(err1);
  display(strcat("PCBC RMS error: ", num2str(meanError)));
  display(strcat("PCBC stdev error: : ", num2str(stdError)));
  legend("B-PR-F", "PC/BC-DIM");
 set(gca, "linewidth", 2, "fontsize", 20)

hold off




figure(5)
plot(gtData(4,:))
hold on
plot(allPCBCDIM(4,:),"LineWidth", 1)
set(gca, "linewidth", 2, "fontsize", 20)
legend("GT", "PC/BC-DIM");

hold off

figure(6)
plot(gtData(4,:))
hold on
plot(allB_PR_F_Mus(4,:),"LineWidth", 1)
set(gca, "linewidth", 2, "fontsize", 20)
 legend("GT", "B-PR-F");

hold off
figure
plot(range,xIMU(2,:))
 hold on
 plot(range,xDVL(2,:))
 plot([range range range range],r)
 plot(range,xUSBL(2,:))

