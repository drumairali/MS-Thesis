#MainFile2
source('PreCompile.m')
xCusbl=[];
globalTrajvar=0;
globalTraj=[];
localTraj=[];
xCusbl(2:158,1:2)=usblData(2:158,1:2);

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
if tImu<=t && iImu<6301
  xIMU = G1D(range,localTrajvar+imuData(iImu,2),sigmaIMU,AIMU); 
  tImu=imuData(iImu+1,1);
  iImu=iImu+1;
endif
  
if tDvl<=t && iDvl<6301 
  xDVL = G1D(range,localTrajvar+dvlData(iDvl,2),sigmaDVL,ADVL); 
  tDvl=dvlData(iDvl+1,1);
  iDvl=iDvl+1;
else 
  xDVL =zeros(1,801);
  endif

if tUsbl<=t && iUsbl<158
  xUSBL = G1D(range,xCusbl(iUsbl,2)-usblDiff,sigmaUSBL,AUSBL); 
  tUsbl=xCusbl(iUsbl+1,1);
  iUsbl=iUsbl+1;
else
  xUSBL=zeros(1,801);
endif

x = [xIMU xDVL xUSBL];
x=x';


#PCBC-DIM
for i=1:itr
r=V*y;
e=x./(epsilon2+r);
y=(epsilon1+y).*(W*e);
endfor
#Decoding
localTrajvar = decode(y',centers);
localTraj=[localTraj;t localTrajvar];

globalTraj=[globalTraj;t globalTrajvar+localTrajvar];

if sum(xUSBL)>0.01
  globalTrajvar+=localTrajvar;
  usblDiff=globalTrajvar;
  localTrajvar=0;
  
endif


t=t+dt;
end

plot(gtData(1:val,2))
hold on 
plot(globalTraj(1:val,2))
hold off