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
  xIMU = G1D(range,imuData(iImu,axis),sigmaIMU,AIMU); 
  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
endif
  
if tDvl<=t && iDvl<6301 
  xDVL = G1D(range,dvlData(iDvl,axis),sigmaDVL,ADVL); 
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;
else 
  xDVL =zeros(1,801);
  endif

if tUsbl<=t && iUsbl<158
  xUSBL = G1D(range,xCusbl(iUsbl,axis)-xCusbl(iUsbl-1,axis),sigmaUSBL,AUSBL); 
  
  if 774<=t && iDvl<6301 && t<=2015 # to overcome below water abruptness
  xDVL = G1D(range,localTrajvar,30,20); 
  endif
  #threshold 41.99
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
plot(gtData(1:val,axis))
hold on 
plot(globalTraj(1:val-1,2))
hold off